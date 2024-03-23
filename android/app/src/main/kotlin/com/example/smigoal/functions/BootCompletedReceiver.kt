package com.example.smigoal.functions

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.content.ContextCompat

class BootCompletedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.i("test", "핸드폰 부팅됐어요")
        if (Intent.ACTION_BOOT_COMPLETED == intent.action) {
            // 백그라운드에서 실행할 작업을 여기에 구현
            val serviceIntent = Intent(context, SMSForegroundService::class.java)
            ContextCompat.startForegroundService(context, serviceIntent)
        }
    }
}
