package com.example.smigoal

import android.app.AlertDialog
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import android.provider.Telephony
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.app.ActivityCompat
import com.example.smigoal.db.MessageDB
import com.example.smigoal.db.MessageEntity
import com.example.smigoal.functions.RequestServer
import com.example.smigoal.functions.SMSForegroundService
import com.example.smigoal.functions.SMSReceiver
import com.example.smigoal.models.SMSServiceData
import com.example.smigoal.models.SMSServiceData.DATA_CHANNEL
import com.example.smigoal.models.SMSServiceData.SETTINGS_CHANNEL
import com.example.smigoal.models.SMSServiceData.channel
import com.example.smigoal.models.SMSServiceData.data_channel
import com.example.smigoal.models.SMSServiceData.db
import com.example.smigoal.models.SMSServiceData.settings_channel
import com.example.smigoal.models.SMSServiceData.smsReceiver
import com.example.smigoal.models.SMSServiceData.stopSMSService
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterFragmentActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import java.util.Calendar

private const val MY_PERMISSIONS_REQUEST_READ_CONTACTS = 1

class MainActivity : FlutterFragmentActivity() {
    val dbScope = CoroutineScope(Dispatchers.IO)
    private lateinit var flutterEngine: FlutterEngine
    private var returningFromSettings = false

    private val permissions = arrayOf(
        android.Manifest.permission.POST_NOTIFICATIONS,
        android.Manifest.permission.RECEIVE_SMS)

    private val multiplePermissionLauncher =
        (this as ComponentActivity).registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()){
            Log.i("test", "multiplePermissionLauncher.launch")
            val resultPermission = it.all{map ->
                map.value
            }
            if(!resultPermission){
                Toast.makeText(this, "All Permissions must be allowed!", Toast.LENGTH_SHORT).show()
                permissionCheckAlertDialog()
            }
            else init()
        }

    private fun checkPermissions() {
        Log.i("test", "checkPermissions")
        when {
            (permissions.all { checkSelfPermission(it) == PackageManager.PERMISSION_GRANTED }) -> init()
            (ActivityCompat.shouldShowRequestPermissionRationale (this, android.Manifest.permission.POST_NOTIFICATIONS)
                    || ActivityCompat.shouldShowRequestPermissionRationale(this, android.Manifest.permission.READ_SMS)) -> permissionCheckAlertDialog()
            else -> multiplePermissionLauncher.launch(permissions)

        }
    }


    fun permissionCheckAlertDialog(){
        Log.i("test", "permissionCheckAlertDialog")
        val builder = AlertDialog.Builder(this).setCancelable(false)
        builder.setMessage("모든 권한이 수락되어야 합니다!").setTitle("앱 사용 권한").setPositiveButton("확인"){
                _, _ ->
            multiplePermissionLauncher.launch(permissions)
        }.setNeutralButton("Go to Settings") { dlg, _ ->
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", packageName, null)
            }
            startActivity(intent)
            returningFromSettings = true
            dlg.dismiss()
        }
        val dialog = builder.create()
        dialog.show()
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
//        Log.i("test", "onRequestPermissionsResult")
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            MY_PERMISSIONS_REQUEST_READ_CONTACTS -> {
                if ((grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
                    // 권한이 부여되었을 때의 로직
                    Log.i("test", "Granted")
//                    init()
                } else {
                    // 권한이 거부되었을 때의 로직
                    Log.i("test", "Not Granted")
                }
                return
            }
            // 다른 'case' 라인을 여기에 추가할 수 있습니다.
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        this.flutterEngine = flutterEngine
        checkPermissions()
        init()
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
                        true -> {
                            registerSMSReceiver()
                            startSMSForegroundService()
                        }
                        false -> {
                            unregisterReceiver(smsReceiver)
                            stopSMSService(this)
                        }
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
                            val gson = Gson()
                            val jsonMessage = gson.toJson(emptyList<MessageEntity>())
                            channel.invokeMethod("showDb", mapOf(
                                "dbDatas" to jsonMessage,
                                "ham" to 0,
                                "spam" to 0,
                                "doubt" to 0,
                            ))
                        }
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
                    CoroutineScope(Dispatchers.IO).launch { RequestServer.extractMessage(this@MainActivity, message, sender, timestamp) }
                }
                else -> result.notImplemented()
            }
        }

        data_channel.setMethodCallHandler { call, result ->
            if (call.method == "getSmishingData") {
                val data = runBlocking { getSmishingData() }
                result.success(data)
            } else {
                result.notImplemented()
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

    private fun init() {
        Log.i("test", "init")
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMSServiceData.CHANNEL)
        settings_channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SETTINGS_CHANNEL)
        data_channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DATA_CHANNEL)
        smsReceiver = SMSReceiver(channel)
        db = MessageDB.getInstance(applicationContext)!!
        dbScope.launch {
            Log.i("test", "getFromDB : ${db.messageDao().getMessage() ?: "없음"}")
        }
    }

    private suspend fun getSmishingData(): String {
        val messageDao = db.messageDao()

        val calendar = Calendar.getInstance()
        calendar.add(Calendar.MONTH, -3)
        val threeMonthsAgoTimestamp = calendar.timeInMillis

        val messages = withContext(Dispatchers.IO) {
            messageDao.getMessagesFromDate(threeMonthsAgoTimestamp)
        }

        val gson = Gson()
        return gson.toJson(messages)
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
        if (returningFromSettings) {
            checkPermissions()
        }
        returningFromSettings = false
        dbScope.launch {
            val entity = db.messageDao().getCurrentMessage()
            val entities = db.messageDao().getMessage()
            val gson = Gson()
            Log.i("test", "last Message : ${entity.toString()}")
            withContext(Dispatchers.Main) {
                if(entity != null) {
                    Log.i("test", "send Entity")
                    val messageJson = gson.toJson(entity)
                    channel.invokeMethod(
                        "onReceivedSMS", messageJson
                    )
                }
                if(entities != null) {
                    var ham = 0
                    var spam = 0
                    var doubt = 0
                    for (data in entities) {
                        if (data.isSmishing) {
                            spam++
                        } else {
                            if (data.spamPercentage >= 50) doubt++
                            else ham++
                        }
                    }
                    Log.i("test", entities.size.toString())
                    val dbDatas = gson.toJson(entities)

                    channel.invokeMethod(
                        "showDb", mapOf(
                            "dbDatas" to dbDatas,
                            "ham" to ham,
                            "spam" to spam,
                            "doubt" to doubt
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