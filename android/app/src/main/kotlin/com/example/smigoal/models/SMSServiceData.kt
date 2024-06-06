package com.example.smigoal.models

import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.example.smigoal.db.MessageDB
import com.example.smigoal.db.MessageEntity
import com.example.smigoal.functions.SMSForegroundService
import com.example.smigoal.functions.SMSReceiver
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

object SMSServiceData {
    // 서비스의 실행 성탸룰 나타내는 LiveData이다. 기본값은 false
    val isServiceRunning = MutableLiveData<Boolean>(false)

    val CHANNEL = "com.example.smigoal/sms"
    val SETTINGS_CHANNEL = "com.example.smigoal/settings"
    val DATA_CHANNEL = "com.example.smigoal/data"
    lateinit var db: MessageDB
    lateinit var smsReceiver: SMSReceiver
    lateinit var channel: MethodChannel
    lateinit var settings_channel: MethodChannel
    lateinit var data_channel: MethodChannel
    fun setResponseFromServer(entity: MessageEntity) {
        CoroutineScope(Dispatchers.IO).launch {
            Log.i("test", "db insert")
            db.messageDao().insertMessage(entity)
        }
    }

    // SMSService를 중지하는 메서드
    fun stopSMSService(context: Context) {
        Log.i("test", "Stop Service")
        val intent = Intent(context, SMSForegroundService::class.java)
        context.stopService(intent)
    }

}