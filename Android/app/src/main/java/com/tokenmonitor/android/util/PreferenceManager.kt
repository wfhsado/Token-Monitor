package com.tokenmonitor.android.util

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import com.tokenmonitor.android.model.Platform

class PreferenceManager(context: Context) {

    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()

    private val sharedPreferences: SharedPreferences = EncryptedSharedPreferences.create(
        context,
        "token_monitor_prefs",
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    companion object {
        private const val KEY_API_PREFIX = "api_key_"
        private const val KEY_SELECTED_PLATFORM = "selected_platform"
        private const val KEY_MONITORING_ENABLED = "monitoring_enabled"
        private const val KEY_REFRESH_INTERVAL = "refresh_interval"
    }

    fun saveApiKey(platform: Platform, apiKey: String) {
        sharedPreferences.edit()
            .putString(KEY_API_PREFIX + platform.name, apiKey)
            .apply()
    }

    fun getApiKey(platform: Platform): String? {
        return sharedPreferences.getString(KEY_API_PREFIX + platform.name, null)
    }

    fun deleteApiKey(platform: Platform) {
        sharedPreferences.edit()
            .remove(KEY_API_PREFIX + platform.name)
            .apply()
    }

    fun getSelectedPlatform(): Platform {
        val value = sharedPreferences.getString(KEY_SELECTED_PLATFORM, Platform.DEEPSEEK.name)
        return Platform.fromString(value ?: Platform.DEEPSEEK.name)
    }

    fun setSelectedPlatform(platform: Platform) {
        sharedPreferences.edit()
            .putString(KEY_SELECTED_PLATFORM, platform.name)
            .apply()
    }

    fun isMonitoringEnabled(): Boolean {
        return sharedPreferences.getBoolean(KEY_MONITORING_ENABLED, false)
    }

    fun setMonitoringEnabled(enabled: Boolean) {
        sharedPreferences.edit()
            .putBoolean(KEY_MONITORING_ENABLED, enabled)
            .apply()
    }

    fun getRefreshInterval(): Long {
        return sharedPreferences.getLong(KEY_REFRESH_INTERVAL, 30 * 60 * 1000) // 默认30分钟
    }

    fun setRefreshInterval(intervalMillis: Long) {
        sharedPreferences.edit()
            .putLong(KEY_REFRESH_INTERVAL, intervalMillis)
            .apply()
    }
}
