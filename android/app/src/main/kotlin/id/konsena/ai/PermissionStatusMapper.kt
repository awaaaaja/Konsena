package id.konsena.ai

import android.content.pm.PackageInfo
import android.content.pm.PermissionInfo

internal data class PermissionGrantFact(
    val granted: Boolean?,
    val flagsAvailable: Boolean,
    val statusCode: String,
)

/** Maps only facts actually present in PackageInfo; never infers usage. */
internal object PermissionStatusMapper {
    fun fromRequestedFlags(
        flags: IntArray,
        index: Int,
        protectionLevel: Int?,
    ): PermissionGrantFact {
        val hasFlag = index in flags.indices
        val granted = if (hasFlag) {
            (flags[index] and PackageInfo.REQUESTED_PERMISSION_GRANTED) != 0
        } else null
        val isDangerous = protectionLevel != null &&
            (protectionLevel and 0xF) == PermissionInfo.PROTECTION_DANGEROUS
        val status = when {
            granted == true -> "declared_granted"
            granted == false && isDangerous -> "declared_not_granted"
            granted == false -> "non_runtime_or_unknown"
            else -> "unavailable"
        }
        return PermissionGrantFact(granted, hasFlag, status)
    }
}
