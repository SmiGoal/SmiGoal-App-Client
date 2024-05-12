package com.example.smigoal.functions

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.util.Log
import androidx.core.app.NotificationCompat
import com.example.smigoal.MainActivity
import com.example.smigoal.R
import com.example.smigoal.db.MessageEntity

object NotificationService {
    fun sendNotification(context: Context, entity: MessageEntity) {
        val notificationChannelId = "SmiGoal SMS Received Channel ID"
        val channelName = "SmiGoal SMS Receive Service"
        val notificationChannel = NotificationChannel(
            notificationChannelId,
            channelName,
            NotificationManager.IMPORTANCE_HIGH,
        )
        notificationChannel.enableVibration(true)
        notificationChannel.enableLights(true)
        notificationChannel.lightColor = Color.BLUE
        notificationChannel.lockscreenVisibility = Notification.VISIBILITY_PRIVATE

        Log.i("test", "From ${entity.sender}, ${entity.timestamp}: Message: ${entity.message}\\n")

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(notificationChannel)

        val notificationBuilder = NotificationCompat.Builder(context, notificationChannelId)
        val notification = notificationBuilder.setSmallIcon(R.mipmap.icon_smigoal)
            .setContentTitle("메시지 도착")
            .setContentText("From ${entity.sender}, ${entity.timestamp}: Message: ${entity.message}\\n Result: ${if (entity.isSmishing) "SPAM" else "HAM"}")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(Notification.CATEGORY_SERVICE)

        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            1,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        notification.setContentIntent(pendingIntent)

        manager.notify(10, notification.build())
    }
}