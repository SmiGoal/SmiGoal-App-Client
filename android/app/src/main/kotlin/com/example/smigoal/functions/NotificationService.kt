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

//object NotificationService {
//    fun sendNotification(context: Context, entity: MessageEntity) {
//        val notificationChannelId = "SmiGoal SMS Received Channel ID"
//        val channelName = "SmiGoal SMS Receive Service"
//        val notificationChannel = NotificationChannel(
//            notificationChannelId,
//            channelName,
//            NotificationManager.IMPORTANCE_HIGH,
//        )
//        notificationChannel.enableVibration(true)
//        notificationChannel.enableLights(true)
//        notificationChannel.lightColor = Color.BLUE
//        notificationChannel.lockscreenVisibility = Notification.VISIBILITY_PRIVATE
//
//        Log.i("test", "From ${entity.sender}, ${entity.timestamp}: Message: ${entity.message}\\n")
//
//        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
//        manager.createNotificationChannel(notificationChannel)
//        Log.i("test", "thumbnail URL: "+entity.thumbnail)
//        val notificationBuilder = NotificationCompat.Builder(context, notificationChannelId)
//        val notification = notificationBuilder.setSmallIcon(R.mipmap.icon_smigoal)
//            .setContentTitle(if(entity.isSmishing) "스미싱 의심 문자 도착!" else "안전한 문자 도착!")
//            .setContentText("From ${entity.sender}, ${entity.timestamp}: Message: ${entity.message}\\n Url: ${entity.url}")
//            .setPriority(NotificationCompat.PRIORITY_HIGH)
//            .setCategory(Notification.CATEGORY_SERVICE)
//            .apply {
//                if (entity.thumbnail != "") {
//                    var bitmap: Bitmap
//                    CoroutineScope(Dispatchers.IO).launch {
//                        bitmap = downloadImage(entity.thumbnail)!!
//                        withContext(Dispatchers.Main) {
//                            Log.i("test", "Bitmap: $bitmap")
////                            setStyle(NotificationCompat.BigPictureStyle().bigPicture(bitmap))
//                            val remoteViews = RemoteViews(context.packageName, R.layout.custom_notification)
//                            remoteViews.setTextViewText(R.id.title, if(entity.isSmishing) "스미싱 의심 문자 도착!" else "안전한 문자 도착!")
//                            remoteViews.setImageViewBitmap(R.id.image, bitmap)
//                            setLargeIcon(bitmap)
//                                .setStyle(NotificationCompat.DecoratedCustomViewStyle())
//                                .setCustomContentView(remoteViews)
//                        }
//                    }
//                }
//            }
//        Log.i("test", "Noti setting done, $notification.")
//
//        val intent = Intent(context, MainActivity::class.java).apply {
//            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
//        }
//
//        val pendingIntent = PendingIntent.getActivity(
//            context,
//            1,
//            intent,
//            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
//        )
//        notification.setContentIntent(pendingIntent)
//
//        manager.notify(10, notification.build())
//    }
//
//    suspend fun downloadImage(imageUrl: String): Bitmap? {
//        return withContext(Dispatchers.IO) {
//            try {
//                Picasso.get().load(imageUrl).get()
//            } catch (e: Exception) {
//                e.printStackTrace()
//                null
//            }
//        }
//    }
//}

object NotificationService {
    fun sendNotification(context: Context, entity: MessageEntity) {
        val notificationChannelId = "SmiGoal SMS Received Channel ID"
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        createNotificationChannel(notificationManager, notificationChannelId, "SmiGoal SMS Receive Service")

        CoroutineScope(Dispatchers.Main).launch {
            val bitmap = downloadImage(context, entity.thumbnail)
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
        return NotificationCompat.Builder(context, channelId).apply {
            setSmallIcon(R.mipmap.icon_smigoal)
            setContentTitle(if(entity.isSmishing) "스미싱 의심 문자입니다!" else "안전한 문자 입니다!")
            setContentText("발신자: ${entity.sender}\n수신 시각: ${time}\n메시지 내용: ${entity.message}")
            setPriority(NotificationCompat.PRIORITY_HIGH)
            setCategory(Notification.CATEGORY_SERVICE)
            bitmap?.let {
                setLargeIcon(it)
                setStyle(NotificationCompat.BigPictureStyle().bigPicture(it))
            }
        }
    }
}
