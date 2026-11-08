package id.konsena.ai

import android.app.Instrumentation
import android.os.Bundle
import android.os.Debug
import ai.onnxruntime.OnnxTensor
import ai.onnxruntime.OrtEnvironment
import ai.onnxruntime.OrtSession
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.LongBuffer
import java.security.MessageDigest
import kotlin.math.abs

/** Debug-only parity for authored tensors, tokenization and calibrated labels. */
class QaModelInstrumentation : Instrumentation() {
    private var modelId = ""
    override fun onCreate(arguments: Bundle?) {
        super.onCreate(arguments)
        modelId = arguments?.getString("modelId") ?: ""
        start()
    }
    override fun onStart() {
        val bundle = Bundle()
        try {
            val expectedHashes = mapOf(
                "consent_nli" to "ef57b36f620e94bb2ed0d0f153191a0d636fa0e25cddc3459d353c526f1335ca",
                "dark_pattern" to "62a274110e7b70a34872b357c7091fbf2f442f9d62cf5cd2fb0afd3a1b901229",
                "privacy_classifier" to "15fbfb2da162cb196b0b7a0526840e983caaa5a7d18029c61bfea304d812f41e",
            )
            require(expectedHashes.containsKey(modelId))
            val root = File(targetContext.filesDir, "model_qa/$modelId")
            val model = File(root, "model.onnx")
            val hash = MessageDigest.getInstance("SHA-256")
            model.inputStream().use { input ->
                val buffer = ByteArray(1024 * 1024)
                var count = input.read(buffer)
                while (count >= 0) { if (count > 0) hash.update(buffer, 0, count); count = input.read(buffer) }
            }
            require(hash.digest().joinToString("") { "%02x".format(it) } == expectedHashes[modelId])
            val cases = JSONArray(File(root, "golden_cases.json").readText())
            val contract = JSONObject(File(root, "model_contract.json").readText())
            val labels = JSONObject(File(root, "labels.json").readText()).getJSONArray("labels")
            val tokenizer = if (modelId == "dark_pattern") null else QaWordPiece(JSONObject(File(root, "tokenizer.json").readText()))
            val env = OrtEnvironment.getEnvironment().apply { setTelemetry(false) }
            var maximum = 0.0
            val times = JSONArray()
            val startLoad = System.nanoTime()
            OrtSession.SessionOptions().use { options ->
                options.setIntraOpNumThreads(2)
                options.setInterOpNumThreads(1)
                env.createSession(model.absolutePath, options).use { session ->
                    bundle.putDouble("loadMs", (System.nanoTime() - startLoad) / 1000000.0)
                    for (i in 0 until cases.length()) {
                        val c = cases.getJSONObject(i)
                        if (tokenizer != null) {
                            val encoded = tokenizer.encode(c.getString("text"), if (c.isNull("text_pair")) null else c.getString("text_pair"))
                            for (j in 0 until 256) {
                                require(encoded.first[j] == c.getJSONArray("input_ids").getLong(j))
                                require(encoded.second[j] == c.getJSONArray("attention_mask").getLong(j))
                            }
                        }
                        val tensors = mutableMapOf<String, OnnxTensor>()
                        try {
                            if (modelId == "dark_pattern") {
                                val bytes = File(root, c.getString("tensor_file")).readBytes()
                                val tensorHash = MessageDigest.getInstance("SHA-256").digest(bytes).joinToString("") { "%02x".format(it) }
                                require(tensorHash == c.getString("tensor_sha256"))
                                tensors["pixel_values"] = OnnxTensor.createTensor(env,
                                    ByteBuffer.wrap(bytes).order(ByteOrder.LITTLE_ENDIAN).asFloatBuffer(), longArrayOf(1, 3, 224, 224))
                            } else {
                                for (key in listOf("input_ids", "attention_mask")) {
                                    val array = c.getJSONArray(key)
                                    require(array.length() == 256)
                                    tensors[key] = OnnxTensor.createTensor(env,
                                        LongBuffer.wrap(LongArray(256) { array.getLong(it) }), longArrayOf(1, 256))
                                }
                            }
                            val start = System.nanoTime()
                            session.run(tensors).use { output ->
                                val actual = (output[0].value as Array<FloatArray>)[0]
                                val expected = c.getJSONArray("expected_logits")
                                require(actual.size == expected.length() && actual.all { it.isFinite() })
                                for (j in actual.indices) maximum = maxOf(maximum, abs(actual[j].toDouble() - expected.getDouble(j)))
                                val calibration = contract.getJSONObject("calibration")
                                val temperature = calibration.getDouble("temperature")
                                val decoded = mutableListOf<String>()
                                if (contract.getString("activation") == "sigmoid") {
                                    val thresholds = calibration.getJSONArray("thresholds")
                                    for (j in actual.indices) {
                                        val probability = 1.0 / (1.0 + kotlin.math.exp(-actual[j] / temperature))
                                        if (probability >= thresholds.getDouble(j)) decoded.add(labels.getString(j))
                                    }
                                } else {
                                    decoded.add(labels.getString(actual.indices.maxBy { actual[it] / temperature }))
                                }
                                val expectedLabels = c.getJSONArray("expected_decoded_labels")
                                require(decoded == (0 until expectedLabels.length()).map { expectedLabels.getString(it) })
                            }
                            times.put((System.nanoTime() - start) / 1000000.0)
                        } finally { tensors.values.forEach { it.close() } }
                    }
                    bundle.putLong("pssKbDuringSession", Debug.getPss())
                }
            }
            bundle.putString("qaResult", JSONObject(mapOf("modelId" to modelId, "status" to if (maximum <= 0.001) "QA_ONLY" else "FAIL",
                "cases" to cases.length(), "maxAbsLogitDifference" to maximum, "tolerance" to 0.001,
                "inferenceMs" to times, "tokenizationAndroid" to if (tokenizer == null) "N/A_TENSOR_FIXTURE" else "PASS_14_ORIGINAL_VECTORS")).toString())
            finish(if (maximum <= 0.001) -1 else 0, bundle)
        } catch (_: Throwable) {
            bundle.putString("qaResult", "FAIL: missing/corrupt package or runtime/resource failure")
            finish(0, bundle)
        }
    }
}
