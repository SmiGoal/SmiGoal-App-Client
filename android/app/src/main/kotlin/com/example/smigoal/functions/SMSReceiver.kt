package com.example.smigoal.functions

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class SMSReceiver(private var channel: MethodChannel? = null) : BroadcastReceiver() {
    private val fullMessage = StringBuilder()
    private var messageBody = ""
    private var sender = ""
    private var timestamp: Long = 0

    override fun onReceive(context: Context, intent: Intent) {
        if (Telephony.Sms.Intents.SMS_RECEIVED_ACTION == intent.action) {
            fullMessage.clear()
            messageBody = ""
            sender = ""
            timestamp = 0
            for (smsMessage in Telephony.Sms.Intents.getMessagesFromIntent(intent)) {
                messageBody = smsMessage.messageBody
                sender = smsMessage.originatingAddress!!
                timestamp = smsMessage.timestampMillis
                fullMessage.append(messageBody)
            }
            Log.i("test", intent.toString())
            Log.i("test", fullMessage.toString())
            Log.i("test", sender)
            Log.i("test", timestamp.toString())

            CoroutineScope(Dispatchers.IO).launch { RequestServer.extractMessage(context, fullMessage.toString(), sender, timestamp) }
        }
    }
}
