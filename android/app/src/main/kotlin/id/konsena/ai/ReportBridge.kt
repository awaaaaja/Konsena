package id.konsena.ai

import android.app.Activity
import android.content.ClipData
import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.UUID

/** User-triggered, app-managed plaintext export cache. Never a raw source. */
class ReportBridge(private val activity: Activity, messenger: BinaryMessenger) {
    private val directory = File(activity.cacheDir, "audit_exports")
    init {
        // Recovery is best effort; an error remains visible on explicit cleanup.
        try { clearCache() } catch (_: Exception) { }
        MethodChannel(messenger, "id.konsena/reports").setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "clearExportCache" -> { clearCache(); result.success(null) }
                    "sharePdf" -> {
                        val bytes = call.argument<ByteArray>("bytes")
                        require(bytes != null && bytes.size in 5..(8 * 1024 * 1024))
                        require(String(bytes.copyOfRange(0, 5), Charsets.US_ASCII) == "%PDF-")
                        // Expire prior exports after 1h; don't revoke an ongoing receiver immediately.
                        directory.mkdirs()
                        directory.listFiles()?.filter { it.lastModified() < System.currentTimeMillis() - 3600000 }
                            ?.forEach { it.delete() }
                        val file = File(directory, "audit-${UUID.randomUUID()}.pdf")
                        file.writeBytes(bytes)
                        val uri = FileProvider.getUriForFile(activity, "${activity.packageName}.reports", file)
                        val intent = Intent(Intent.ACTION_SEND).apply {
                            type = "application/pdf"
                            putExtra(Intent.EXTRA_STREAM, uri)
                            clipData = ClipData.newRawUri("Laporan audit", uri)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }
                        activity.startActivity(Intent.createChooser(intent, "Bagikan laporan audit"))
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            } catch (_: Exception) {
                result.error("EXPORT_UNAVAILABLE", "Export action could not be completed", null)
            }
        }
    }
    private fun clearCache() {
        directory.listFiles()?.forEach { if (it.isFile && !it.delete()) error("Cache cleanup failed") }
    }
}
