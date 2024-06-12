package com.example.smigoal.functions
import android.content.Context
import android.content.SharedPreferences

class SettingsManager(context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences("settings_prefs", Context.MODE_PRIVATE)

    fun setForegroundServiceEnabled(enabled: Boolean) {
        val editor = prefs.edit()
        editor.putBoolean("foreground_service", enabled)
        editor.apply()
    }

    fun isForegroundServiceEnabled(): Boolean {
        return prefs.getBoolean("foreground_service", true)  // 기본값은 true
    }
}