package id.konsena.ai

import android.content.pm.PackageInfo
import android.content.pm.PermissionInfo
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class PermissionStatusMapperTest {
    @Test
    fun grantedFlagIsReportedAsDeclaredGranted() {
        val fact = PermissionStatusMapper.fromRequestedFlags(
            intArrayOf(PackageInfo.REQUESTED_PERMISSION_GRANTED),
            0,
            PermissionInfo.PROTECTION_DANGEROUS,
        )

        assertEquals(true, fact.granted)
        assertTrue(fact.flagsAvailable)
        assertEquals("declared_granted", fact.statusCode)
    }

    @Test
    fun deniedRuntimePermissionIsNotGiven() {
        val fact = PermissionStatusMapper.fromRequestedFlags(
            intArrayOf(0),
            0,
            PermissionInfo.PROTECTION_DANGEROUS,
        )

        assertEquals(false, fact.granted)
        assertEquals("declared_not_granted", fact.statusCode)
    }

    @Test
    fun deniedNormalPermissionIsNotMisrepresentedAsRuntimeDenial() {
        val fact = PermissionStatusMapper.fromRequestedFlags(intArrayOf(0), 0, 0)

        assertFalse(fact.granted!!)
        assertEquals("non_runtime_or_unknown", fact.statusCode)
    }

    @Test
    fun missingFlagsAndProtectionRemainUnknown() {
        val fact = PermissionStatusMapper.fromRequestedFlags(intArrayOf(), 0, null)

        assertNull(fact.granted)
        assertFalse(fact.flagsAvailable)
        assertEquals("unavailable", fact.statusCode)
    }
}
