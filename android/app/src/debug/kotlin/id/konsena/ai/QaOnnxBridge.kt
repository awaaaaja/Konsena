package id.konsena.ai

import android.app.Activity
import android.os.Handler
import android.os.Looper
import ai.onnxruntime.OnnxTensor
import ai.onnxruntime.OrtEnvironment
import ai.onnxruntime.OrtSession
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import java.nio.LongBuffer
import java.security.MessageDigest
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean
import org.json.JSONObject

/** Debug-only tensor / explicitly opted-in experimental NLI. No release channel. */
class QaOnnxBridge(activity: Activity, messenger: BinaryMessenger) {
    private val worker = Executors.newSingleThreadExecutor()
    private val busy = AtomicBoolean(false)
    private val main = Handler(Looper.getMainLooper())
    private val hashes = mapOf(
        "consent_nli" to "ef57b36f620e94bb2ed0d0f153191a0d636fa0e25cddc3459d353c526f1335ca",
        "dark_pattern" to "62a274110e7b70a34872b357c7091fbf2f442f9d62cf5cd2fb0afd3a1b901229",
        "privacy_classifier" to "15fbfb2da162cb196b0b7a0526840e983caaa5a7d18029c61bfea304d812f41e",
    )
    init {
        MethodChannel(messenger, "id.konsena/onnx_qa").setMethodCallHandler { call, result ->
            if (call.method !in listOf("runTensor", "analyzePair")) { result.notImplemented(); return@setMethodCallHandler }
            val id = call.argument<String>("modelId")
            if (!hashes.containsKey(id)) { result.error("QUARANTINED", "Model not allowed in QA", null); return@setMethodCallHandler }
            if (!busy.compareAndSet(false, true)) { result.error("BUSY", "One inference at a time", null); return@setMethodCallHandler }
            worker.execute {
                val tensors = mutableMapOf<String, OnnxTensor>()
                try {
                    val file = File(activity.filesDir, "model_qa/$id/model.onnx")
                    require(file.isFile && file.length() in 1..600000000L)
                    val hash = MessageDigest.getInstance("SHA-256")
                    file.inputStream().use { input ->
                        val chunk = ByteArray(1024 * 1024)
                        var count = input.read(chunk)
                        while (count >= 0) { if (count > 0) hash.update(chunk, 0, count); count = input.read(chunk) }
                    }
                    require(hash.digest().joinToString("") { "%02x".format(it) } == hashes[id])
                    val env = OrtEnvironment.getEnvironment().apply { setTelemetry(false) }
                    if (call.method == "analyzePair") {
                        require(id == "consent_nli")
                        val premise = call.argument<String>("premise") ?: error("Missing clause")
                        val hypothesis = call.argument<String>("hypothesis") ?: error("Missing permission statement")
                        require(premise.length in 1..100000 && hypothesis.length in 1..1000)
                        val tokenizerFile = File(file.parentFile, "tokenizer.json")
                        val tokenizerBytes = tokenizerFile.readBytes()
                        val tokenizerHash = MessageDigest.getInstance("SHA-256").digest(tokenizerBytes).joinToString("") { "%02x".format(it) }
                        require(tokenizerHash == "c2c0e4d392f08c2c2eb950156eb26e4e5ddd15b557faa45ed6a0decaf45b5f98")
                        val encoded = QaWordPiece(JSONObject(String(tokenizerBytes, Charsets.UTF_8))).encode(premise, hypothesis)
                        tensors["input_ids"] = OnnxTensor.createTensor(env, LongBuffer.wrap(encoded.first), longArrayOf(1, 256))
                        tensors["attention_mask"] = OnnxTensor.createTensor(env, LongBuffer.wrap(encoded.second), longArrayOf(1, 256))
                    } else if (id == "dark_pattern") {
                        val bytes = call.argument<ByteArray>("pixels") ?: error("Missing pixels")
                        require(bytes.size == 3 * 224 * 224 * 4)
                        val floats = ByteBuffer.wrap(bytes).order(ByteOrder.LITTLE_ENDIAN).asFloatBuffer()
                        for (i in 0 until floats.limit()) require(floats.get(i).isFinite())
                        tensors["pixel_values"] = OnnxTensor.createTensor(env, floats, longArrayOf(1, 3, 224, 224))
                    } else {
                        for (name in listOf("input_ids", "attention_mask")) {
                            val values = call.argument<List<Number>>(name) ?: error("Missing tensor")
                            require(values.size == 256)
                            tensors[name] = OnnxTensor.createTensor(env, LongBuffer.wrap(values.map { it.toLong() }.toLongArray()), longArrayOf(1, 256))
                        }
                    }
                    val start = System.nanoTime()
                    OrtSession.SessionOptions().use { options ->
                        options.setIntraOpNumThreads(2)
                        options.setInterOpNumThreads(1)
                        // Bound lifetime: exactly one session and its tensors per call.
                        env.createSession(file.absolutePath, options).use { session ->
                            require(session.inputNames == tensors.keys)
                            session.run(tensors).use { output ->
                                val logits = (output[0].value as Array<FloatArray>)[0]
                                require(logits.size == if (id == "dark_pattern") 2 else if (id == "consent_nli") 3 else 9)
                                require(logits.all { it.isFinite() })
                                val response = mutableMapOf<String, Any?>("status" to "QA_ONLY", "modelId" to id, "logits" to logits.map { it.toDouble() },
                                    "loadAndInferenceMs" to (System.nanoTime() - start) / 1000000.0)
                                if (call.method == "analyzePair") {
                                    val scaled = logits.map { it.toDouble() / 1.3195079107728944 }
                                    val max = scaled.max()
                                    val exps = scaled.map { kotlin.math.exp(it - max) }
                                    val sum = exps.sum()
                                    response["probabilities"] = exps.map { it / sum }
                                    response["label"] = listOf("entailment", "neutral", "contradiction")[scaled.indices.maxBy { scaled[it] }]
                                    response["modelVersion"] = "fd543a14deab68081bedc6a9f848932e69594f9993384dd16fdac6bb6900c12c"
                                }
                                main.post { result.success(response) }
                            }
                        }
                    }
                } catch (_: OutOfMemoryError) {
                    main.post { result.error("RESOURCE_LIMIT", "Model exceeded memory budget", null) }
                } catch (_: Throwable) {
                    main.post { result.error("QA_UNAVAILABLE", "Missing, corrupt, unsupported model or tensor", null) }
                } finally {
                    tensors.values.forEach { it.close() }
                    busy.set(false)
                }
            }
        }
    }
}
