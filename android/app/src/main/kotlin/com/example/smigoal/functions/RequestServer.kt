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
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import retrofit2.Retrofit
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

    fun extractMessage(context: Context, fullMessage: String, sender: String, timestamp: Long) {
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
            SMSServiceData.channel.invokeMethod(
                "onReceivedSMS", messageJson
            )
        }
        CoroutineScope(Dispatchers.IO).launch {
            getServerRequestMessage(message, entity)
            if (containsUrl) getServerRequestUrl(urls, entity)

            withContext(Dispatchers.Main) {
                SMSServiceData.setResponseFromServer(entity)
                CoroutineScope(Dispatchers.Main).launch {
                    NotificationService.sendNotification(context, entity)
                    Log.i("test", "result : $entity")
                    Log.i("test", "timestamp : ${entity.timestamp}")

                    val gson = Gson()
                    val messageJson = gson.toJson(entity)
                    SMSServiceData.channel.invokeMethod(
                        "onReceivedSMS", messageJson
                    )
                }
            }
        }
    }

    fun getServerRequestMessage(message: String, entity: MessageEntity) {
        smsService.requestMessageToServer(message).enqueue(object: Callback<Map<String, Any>> {
            override fun onResponse(call: Call<Map<String, Any>>, response: Response<Map<String, Any>>) {
                val body = response.body()!!
                Log.i("test", body.toString())
                val status: String = body["status"] as String
                val code: Int = (body["code"] as Double).toInt()
                if (status == "success") {
                    val result: Map<*, *> = body["result"] as Map<*, *>
                    val isSmishing: Boolean = (result["result"] as String) == "smishing"
                    entity.hamPercentage = (result["ham_percentage"] as String).toDouble()
                    entity.spamPercentage = (result["spam_percentage"] as String).toDouble()
                    entity.isSmishing = isSmishing
                }
                Log.i("test", entity.toString())

            }
            override fun onFailure(call: Call<Map<String, Any>>, t: Throwable) {
                Log.e("test", t.toString())
            }
        })
    }

    fun getServerRequestUrl(urls: List<String>, entity: MessageEntity) {
        val urlData = urls.map{ url ->
            if (!url.contains("(http|https)://")) "http://"+url
            else url
        }
        Log.i("test", urlData.toString())
        val requestUrlCall = smsService.requestUrlToServer(Urls(urlData))
        val body = requestUrlCall.execute().body()
        if(body != null) {
            val status: String = body["status"] as String
            val code: Int = (body["code"] as Double).toInt()
            Log.i("test", status)
            if (status == "success") {
                val result: Map<*, *> = body["result"] as Map<*, *>
                entity.hamPercentage = (result["ham_percantage"] as String).toDouble()
                entity.spamPercentage = (result["spam_percentage"] as String).toDouble()
                val isSmishing: Boolean = (result["result"] as String) == "smishing"
                val thumbnail: String = body["thumbnail"] as String
                if (thumbnail != "") entity.thumbnail = thumbnail
                entity.isSmishing = isSmishing
            }
            Log.i("test", body.toString())
        }
    }

    fun getisThreatURL(urls: List<String>): Boolean {
        val requestThreatUrlCall = apiService.getisThreatURL(param = APIRequestData(
            APIRequestData.Client(),
            APIRequestData.ThreatInfo(
                threatEntries = urls.map { url ->
                    APIRequestData.ThreatInfo.ThreatEntry(url)
                }
            )
        ))
        val body = requestThreatUrlCall.execute().body()
        return body != null
    }
}