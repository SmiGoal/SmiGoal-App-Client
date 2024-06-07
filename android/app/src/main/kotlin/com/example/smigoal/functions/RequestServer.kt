package com.example.smigoal.functions

import android.content.Context
import android.util.Log
import com.example.smigoal.BuildConfig
import com.example.smigoal.db.MessageEntity
import com.example.smigoal.models.APIRequestData
import com.example.smigoal.models.SMSServiceData
import com.example.smigoal.models.extractUrls
import com.google.gson.Gson
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.launch
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.await
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

object RequestServer {
    val BASE_URL = BuildConfig.BASE_URL
    val API_URL = BuildConfig.API_URL

    val okHttpClient = OkHttpClient.Builder()
        // 연결 타임아웃 시간 설정
        .connectTimeout(180, TimeUnit.SECONDS) // 연결 타임아웃 시간을 30초로 설정
        // 읽기 타임아웃 시간 설정
        .readTimeout(180, TimeUnit.SECONDS) // 읽기 타임아웃 시간을 30초로 설정
        // 쓰기 타임아웃 시간 설정
        .writeTimeout(180, TimeUnit.SECONDS) // 쓰기 타임아웃 시간을 30초로 설정
        .build()

    val retrofit = Retrofit.Builder()
        .baseUrl(BASE_URL)
        .addConverterFactory(GsonConverterFactory.create())
        .client(okHttpClient)
        .build()

    val retrofitGoogle = Retrofit.Builder()
        .baseUrl(API_URL)
        .addConverterFactory(GsonConverterFactory.create())
        .client(okHttpClient)
        .build()

    val smsService = retrofit.create(SMSService::class.java)
    val apiService = retrofitGoogle.create(APIService::class.java)

    suspend fun extractMessage(context: Context, fullMessage: String, sender: String, timestamp: Long) {
        var message = fullMessage
        val urls = extractUrls(message)
        var containsUrl = urls.isNotEmpty()
        var isThreatUrl = false
        urls.forEach { url ->
            message = message.replace(url, "")
        }
        var entity =
            MessageEntity(urls.ifEmpty { null }, fullMessage, sender, "", containsUrl, timestamp, .0, .0, false)
        if (containsUrl) {
            Log.i("test", "url: $urls")
            isThreatUrl = getisThreatURL(urls)
        }
        if (isThreatUrl) {
            entity.isSmishing = true
            NotificationService.sendNotification(context, entity)
            Log.i("test", "result : $entity")
            Log.i("test", "timestamp : ${entity.timestamp}")

            val gson = Gson()
            val messageJson = gson.toJson(entity)
            CoroutineScope(Dispatchers.Main).launch {
                SMSServiceData.channel.invokeMethod(
                    "onReceivedSMS", messageJson
                )
            }
        }
        try {
            val serverRequestMessageDeferred = CoroutineScope(Dispatchers.IO).async {
                getServerRequestMessage(message, entity)
            }
            serverRequestMessageDeferred.await()
            if (containsUrl) {
                val serverRequestUrlDeferred = CoroutineScope(Dispatchers.IO).async {
                    getServerRequestUrl(urls, entity)
                }
                serverRequestUrlDeferred.await()
            }

            SMSServiceData.setResponseFromServer(entity)
            NotificationService.sendNotification(context, entity)
            Log.i("test", "result : $entity")
            Log.i("test", "timestamp : ${entity.timestamp}")

            val gson = Gson()
            val messageJson = gson.toJson(entity)
            CoroutineScope(Dispatchers.Main).launch {
                SMSServiceData.channel.invokeMethod(
                    "onReceivedSMS", messageJson
                )
            }
        } catch (e: Exception) {
            Log.e("test", "Error: ${e.message}")
        }
    }

    suspend fun getServerRequestMessage(message: String, entity: MessageEntity) {
        try {
            val body = smsService.requestMessageToServer(message).await()
//            val body: Map<*, *> = response["result"] as Map<*, *>
            Log.i("test", body.toString())
            val status: String = body["status"] as String
            val code: Int = (body["code"] as Double).toInt()
            if (status == "success") {
                val result: Map<*, *> = body["result"] as Map<*, *>
                val isSmishing: Boolean = (result["result"] as String) == "smishing"
                entity.hamPercentage = result["ham_percentage"] as Double
                entity.spamPercentage = result["spam_percentage"] as Double
                entity.isSmishing = isSmishing
            }
            Log.i("test", entity.toString())
        } catch (e: Exception) {
            Log.e("test", "Error: ${e.message}")
        }
    }

    suspend fun getServerRequestUrl(urls: List<String>, entity: MessageEntity) {
        try {
            val urlData = urls.map{ url ->
                if (!url.contains("(http|https)://")) "http://"+url
                else url
            }
            Log.i("test", urlData.toString())
            val body = smsService.requestUrlToServer(Urls(urlData)).await()
            Log.i("test", "Body: $body")
//            val body: Map<*, *> = response["result"]
            if(body != null) {
                val status: String = body["status"] as String
                val code: Int = (body["code"] as Double).toInt()
                Log.i("test", status)
                if (status == "success") {
                    val result: Map<*, *> = body["result"] as Map<*, *>
                    entity.hamPercentage = result["ham_percentage"] as Double
                    entity.spamPercentage = result["spam_percentage"] as Double
                    val isSmishing: Boolean = (result["result"] as String) == "smishing"
                    val thumbnail: String = body["thumbnail"] as String
                    if (thumbnail != "") entity.thumbnail = thumbnail
                    entity.isSmishing = isSmishing
                }
                else {
                    if (code == 422) {
                        entity.apply {
                            hamPercentage = 50.0
                            spamPercentage = 50.0
                            isSmishing = false
                        }
                    }
                }
                Log.i("test", body.toString())
            }
        } catch (e: Exception) {
            Log.e("test", "Error: ${e.message}")
        }
    }

    suspend fun getisThreatURL(urls: List<String>): Boolean {
        try {
            val requestThreatUrlDeferred = CoroutineScope(Dispatchers.IO).async {
                apiService.getisThreatURL(param = APIRequestData(
                    APIRequestData.Client(),
                    APIRequestData.ThreatInfo(
                        threatEntries = urls.map { url ->
                            APIRequestData.ThreatInfo.ThreatEntry(url)
                        }
                    )
                )).execute()
            }
            val response = requestThreatUrlDeferred.await()
            val body = response.body()?.matches
            Log.i("test", "API result: $body")
            return body != null
        } catch (e: Exception) {
            Log.e("test", "Error: ${e.message}")
            return false
        }
    }
}