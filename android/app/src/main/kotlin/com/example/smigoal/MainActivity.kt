package com.example.smigoal

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.PackageManager
import android.provider.Telephony
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat.registerReceiver
import androidx.core.content.ContextCompat.startForegroundService
import com.example.smigoal.db.MessageDB
import com.example.smigoal.functions.RequestServer
import com.example.smigoal.functions.SMSForegroundService
import com.example.smigoal.functions.SMSReceiver
import com.example.smigoal.functions.SettingsManager
import com.example.smigoal.models.SMSServiceData
import com.example.smigoal.models.SMSServiceData.SETTINGS_CHANNEL
import com.example.smigoal.models.SMSServiceData.channel
import com.example.smigoal.models.SMSServiceData.db
import com.example.smigoal.models.SMSServiceData.settings_channel
import com.example.smigoal.models.SMSServiceData.smsReceiver
import com.example.smigoal.models.SMSServiceData.stopSMSService
import com.example.smigoal.models.extractUrls
import io.flutter.embedding.android.FlutterFragmentActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterFragmentActivity() {
    val dbScope = CoroutineScope(Dispatchers.IO)
//    private val isServiceRunning = Observer<Boolean> { isRunning ->
//        if (!isRunning) {
//            Log.i("test", "service 상태 변화 감지")
//            SMSServiceData.startSMSService(this@MainActivity)
//            SMSServiceData.isServiceRunning.postValue(true)
//            registerSMSReceiver()
//            startSMSForegroundService()
//        }
//    }

    val permissions = arrayOf(
        android.Manifest.permission.POST_NOTIFICATIONS,
        android.Manifest.permission.RECEIVE_SMS)

    val multiplePermissionLauncher = (this as ComponentActivity).registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) {
        val resultPermission = it.all{ map ->
            map.value
        }
        if(!resultPermission){
            //finish()
            Toast.makeText(this, "모든 권한 승인되어야 함", Toast.LENGTH_SHORT).show()
        }
    }

    private lateinit var settingsManager: SettingsManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        checkPermissions()
        init(flutterEngine)
        initMethodChannels()
        if (isForegroundServiceEnabled()) {
            registerSMSReceiver()
            startSMSForegroundService()
        }
    }

    private fun initMethodChannels() {
        settings_channel.setMethodCallHandler {
                call, result ->
            when (call.method) {
                "setForegroundServiceEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    setForegroundServiceEnabled(enabled)
                    when (enabled) {
                        true -> startSMSForegroundService()
                        false -> stopSMSService(this)
                    }
                    result.success(null)
                }
                "isForegroundServiceEnabled" -> {
                    result.success(isForegroundServiceEnabled())
                }
                "deleteAllInDB" -> {
                    dbScope.launch {
                        db.messageDao().deleteAllMessages()
                        withContext(Dispatchers.Main) {
                            result.success(null)
                        }
                        channel.invokeMethod("showDB", mapOf(
                            "dbDatas" to emptyList<Map<*, *>>(),
                            "ham" to 0,
                            "spam" to 0,
                        ))
                        Log.i("test", db.messageDao().getMessage().toString())
                    }
                }
                else -> result.notImplemented()
            }
        }

        channel.setMethodCallHandler {
            call, result ->
            when (call.method) {
                "requestToServer" -> {
                    val sender: String = call.argument("sender") ?: "null"
                    val timestamp: Long = call.argument("timestamp") ?: 0
                    val message: String = call.argument("message") ?: "null"
                    RequestServer.extractMessage(this, message, sender, timestamp)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun setForegroundServiceEnabled(enabled: Boolean) {
        val prefs = getSharedPreferences("settings_prefs", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("foreground_service", enabled).apply()
    }

    private fun isForegroundServiceEnabled(): Boolean {
        val prefs = getSharedPreferences("settings_prefs", Context.MODE_PRIVATE)
        return prefs.getBoolean("foreground_service", false)
    }

    fun allPermissionGranted() = permissions.all{
        ActivityCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED
    }

    private fun checkPermissions() {
        Log.i("test", "checkPermissions")
        if(!allPermissionGranted()) multiplePermissionLauncher.launch(permissions)
    }

    private fun init(flutterEngine: FlutterEngine) {
        Log.i("test", "init")
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMSServiceData.CHANNEL)
        settings_channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SETTINGS_CHANNEL)
        smsReceiver = SMSReceiver(channel)
        db = MessageDB.getInstance(applicationContext)!!
        dbScope.launch {
            Log.i("test", "getFromDB : ${db.messageDao().getMessage()}")
        }
    }

    private fun registerSMSReceiver() {
        Log.i("test", "registerSMSReceiver")
        // SMSReceiver 등록
        val filter = IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION).apply {
            priority = Int.MAX_VALUE
        }
        registerReceiver(smsReceiver, filter)
    }

    // 필요에 따라 onDestroy에서 SMSReceiver 해제
    override fun onDestroy() {
//        unregisterReceiver(smsReceiver)
        super.onDestroy()
    }

    override fun onResume() {
        super.onResume()
        dbScope.launch {
            val entity = db.messageDao().getCurrentMessage()
            val entities = db.messageDao().getMessage()
            Log.i("test", "last Message : ${entity.toString()}")
            withContext(Dispatchers.Main) {
                if(entity != null) {
                    channel.invokeMethod(
                        "onReceivedSMS", mapOf(
                            "message" to entity.message,
                            "sender" to entity.sender,
                            "result" to if (entity.isSmishing) "spam" else "ham",
                            "timestamp" to entity.timestamp
                        )
                    )
                }
                if(entities != null) {
                    var ham = 0
                    var spam = 0
                    for (data in entities) {
                        if(data.isSmishing) spam++ else ham++
                    }
                    Log.i("test", entities.size.toString())
                    val dbDatas = entities.map { data ->
                        mapOf(
                            "id" to data.id,
                            "url" to data.url,
                            "message" to data.message,
                            "sender" to data.sender,
                            "containsUrl" to data.containsUrl,
                            "timestamp" to data.timestamp,
                            "isSmishing" to data.isSmishing
                        )
                    }

                    channel.invokeMethod(
                        "showDb", mapOf(
                            "dbDatas" to dbDatas,
                            "ham" to ham,
                            "spam" to spam
                        )
                    )
                }
            }
        }
    }

    private fun startSMSForegroundService() {
        Log.i("test", "startSMSForegroundService")
        val foregroundServiceIntent = Intent(this, SMSForegroundService::class.java)
        startForegroundService(foregroundServiceIntent)
    }
}