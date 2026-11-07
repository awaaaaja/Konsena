package id.konsena.ai

import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.PermissionInfo
import android.net.Uri
import android.os.Build
import android.provider.Settings
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "id.konsena/permissions"

    private fun capturedAtUtc(): String = SimpleDateFormat(
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
        Locale.US,
    ).apply { timeZone = TimeZone.getTimeZone("UTC") }.format(Date())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "listVisibleLaunchableApps" -> {
                            val includeSystem = call.argument<Boolean>("includeSystem") ?: false
                            result.success(listVisibleLaunchableApps(includeSystem))
                        }
                        "getPermissionSnapshot" -> {
                            val packageName = call.argument<String>("packageName")
                            if (packageName.isNullOrBlank()) {
                                result.error("INVALID_ARGUMENT", "packageName is required", null)
                            } else {
                                result.success(getPermissionSnapshot(packageName))
                            }
                        }
                        "openAppSettings" -> {
                            val packageName = call.argument<String>("packageName")
                            if (packageName.isNullOrBlank()) {
                                result.error("INVALID_ARGUMENT", "packageName is required", null)
                            } else {
                                result.success(openAppSettings(packageName))
                            }
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: SecurityException) {
                    result.error("NOT_VISIBLE", "Package information is not visible to this app", null)
                } catch (error: PackageManager.NameNotFoundException) {
                    result.error("PACKAGE_NOT_FOUND", "The selected package is no longer installed", null)
                } catch (error: Exception) {
                    result.error("UNKNOWN", "Android permission inspection failed", null)
                }
            }
    }

    private fun launcherIntent() = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)

    @Suppress("DEPRECATION")
    private fun visibleLaunchables() = if (Build.VERSION.SDK_INT >= 33) {
        packageManager.queryIntentActivities(launcherIntent(), PackageManager.ResolveInfoFlags.of(0L))
    } else {
        packageManager.queryIntentActivities(launcherIntent(), 0)
    }

    private fun listVisibleLaunchableApps(includeSystem: Boolean): Map<String, Any> {
        val apps = visibleLaunchables()
            .mapNotNull { it.activityInfo?.applicationInfo }
            .filter { it.packageName != packageName }
            .distinctBy { it.packageName }
            .filter { includeSystem || (it.flags and ApplicationInfo.FLAG_SYSTEM) == 0 }
            .map { app ->
                val info = try {
                    packageInfo(app.packageName, 0)
                } catch (_: PackageManager.NameNotFoundException) {
                    null
                }
                mapOf(
                    "packageName" to app.packageName,
                    "label" to app.loadLabel(packageManager).toString(),
                    "versionName" to info?.versionName,
                    "isSystem" to ((app.flags and ApplicationInfo.FLAG_SYSTEM) != 0),
                )
            }
            .sortedWith(compareBy(String.CASE_INSENSITIVE_ORDER) { it["label"] as String })
        return mapOf(
            "apps" to apps,
            "visibilityScope" to "launcher_query",
            "capturedAt" to capturedAtUtc(),
            "androidSdk" to Build.VERSION.SDK_INT,
        )
    }

    @Suppress("DEPRECATION")
    private fun packageInfo(packageName: String, flags: Long): PackageInfo = if (Build.VERSION.SDK_INT >= 33) {
        packageManager.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(flags))
    } else {
        packageManager.getPackageInfo(packageName, flags.toInt())
    }

    private fun isVisibleLaunchable(packageName: String): Boolean =
        visibleLaunchables().any { it.activityInfo?.packageName == packageName }

    private fun getPermissionSnapshot(packageName: String): Map<String, Any?> {
        if (!isVisibleLaunchable(packageName)) {
            throw SecurityException("Package is outside the launcher-visible query scope")
        }
        val info = packageInfo(packageName, PackageManager.GET_PERMISSIONS.toLong())
        val requested = info.requestedPermissions ?: emptyArray()
        val grantFlags = info.requestedPermissionsFlags ?: IntArray(0)
        val permissionEntries = requested.mapIndexed { index, permissionName ->
            val hasGrantFlag = index < grantFlags.size
            val granted = if (hasGrantFlag) {
                (grantFlags[index] and PackageInfo.REQUESTED_PERMISSION_GRANTED) != 0
            } else null
            var protectionLevel: Int? = null
            var label: String? = null
            try {
                @Suppress("DEPRECATION")
                val permissionInfo = packageManager.getPermissionInfo(permissionName, 0)
                protectionLevel = permissionInfo.protectionLevel
                label = permissionInfo.loadLabel(packageManager)?.toString()
            } catch (_: Exception) {
                // Permission labels/protection metadata may be unavailable due to OS visibility.
            }
            val isDangerous = protectionLevel != null &&
                (protectionLevel and 0xF) == PermissionInfo.PROTECTION_DANGEROUS
            val status = when {
                granted == true -> "declared_granted"
                granted == false && isDangerous -> "declared_not_granted"
                granted == false -> "non_runtime_or_unknown"
                else -> "unavailable"
            }
            mapOf(
                "name" to permissionName,
                "label" to label,
                "granted" to granted,
                "statusCode" to status,
                "protectionLevel" to protectionLevel,
                "flagsAvailable" to hasGrantFlag,
            )
        }
        val app = info.applicationInfo
        return mapOf(
            "packageName" to info.packageName,
            "label" to (app?.loadLabel(packageManager)?.toString() ?: packageName),
            "versionName" to info.versionName,
            "permissions" to permissionEntries,
            "capturedAt" to capturedAtUtc(),
            "androidSdk" to Build.VERSION.SDK_INT,
            "visibilityScope" to "launcher_query",
            "snapshotStatus" to "available",
        )
    }

    private fun openAppSettings(packageName: String): Map<String, Any> {
        if (!isVisibleLaunchable(packageName)) {
            throw SecurityException("Package is outside the launcher-visible query scope")
        }
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.parse("package:$packageName")
        }
        return try {
            startActivity(intent)
            mapOf("opened" to true, "fallbackUsed" to false)
        } catch (_: ActivityNotFoundException) {
            mapOf("opened" to false, "fallbackUsed" to false)
        }
    }
}
