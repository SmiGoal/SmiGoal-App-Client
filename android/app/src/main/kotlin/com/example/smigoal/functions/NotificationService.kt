package com.example.smigoal.functions

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Color
import android.util.Log
import androidx.core.app.NotificationCompat
import com.example.smigoal.MainActivity
import com.example.smigoal.R
import com.example.smigoal.db.MessageEntity
import com.squareup.picasso.Picasso
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object NotificationService {
    val title = listOf("스미싱 고위험 문자입니다!", "스미싱 의심 문자입니다!", "안전한 문자입니다!")

    fun sendNotification(context: Context, entity: MessageEntity) {
        val notificationChannelId = "SmiGoal SMS Received Channel ID"
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        createNotificationChannel(notificationManager, notificationChannelId, "SmiGoal SMS Receive Service")

        CoroutineScope(Dispatchers.Main).launch {
            val bitmap = if (entity.thumbnail.isNotEmpty()) downloadImage(context, entity.thumbnail) else null
            val notification = buildNotification(context, entity, bitmap, notificationChannelId)
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context, 1, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            notification.setContentIntent(pendingIntent)
            notificationManager.notify(10, notification.build())

        }
    }

    private fun createNotificationChannel(notificationManager: NotificationManager, channelId: String, channelName: String) {
        val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_HIGH).apply {
            enableVibration(true)
            enableLights(true)
            lightColor = Color.BLUE
            lockscreenVisibility = Notification.VISIBILITY_PRIVATE
        }
        notificationManager.createNotificationChannel(channel)
    }

    private suspend fun downloadImage(context: Context, imageUrl: String): Bitmap? {
        return withContext(Dispatchers.IO) {
            try {
                Picasso.get().load(imageUrl).get()
            } catch (e: Exception) {
                Log.e("NotificationService", "Error downloading image", e)
                null
            }
        }
    }

    private fun buildNotification(context: Context, entity: MessageEntity, bitmap: Bitmap?, channelId: String): NotificationCompat.Builder {
        val date = Date(entity.timestamp)
        val format = SimpleDateFormat("yyyy년 MM월 dd일 HH시 mm분", Locale.KOREA)
        val time = format.format(date)
        val idx = when {
            entity.isSmishing -> 0
            entity.spamPercentage >= 50 -> 1
            else -> 2
        }
        return NotificationCompat.Builder(context, channelId).apply {
            setSmallIcon(R.mipmap.icon_smigoal)
            setContentTitle(title[idx])
            setContentText("발신자: ${entity.sender}\n수신 시각: ${time}\n메시지 내용: ${entity.message}")
            setStyle(NotificationCompat.BigTextStyle()
                .bigText("발신자: ${entity.sender}\n수신 시각: ${time}\n메시지 내용: ${entity.message}"))
            setPriority(NotificationCompat.PRIORITY_HIGH)
            setCategory(Notification.CATEGORY_SERVICE)
            bitmap?.let {
                setLargeIcon(it)
                setStyle(NotificationCompat.BigPictureStyle()
                    .bigPicture(it)
                    .setSummaryText("발신자: ${entity.sender}\n수신 시각: ${time}\n메시지 내용: ${entity.message}"))
            }
        }
    }
}
