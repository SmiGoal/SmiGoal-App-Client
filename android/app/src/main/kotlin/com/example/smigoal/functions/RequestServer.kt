package com.example.smigoal.functions

import android.content.Context
import android.util.Log
import com.example.smigoal.BuildConfig
import com.example.smigoal.db.MessageEntity
import com.example.smigoal.models.APIRequestData
import com.example.smigoal.models.APIResponseDTO
import com.example.smigoal.models.SMSServiceData
import com.example.smigoal.models.extractUrls
import com.google.gson.Gson
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.invoke
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
        var message = fullMessage.toString()
        val urls = extractUrls(message)
        var containsUrl = urls.isNotEmpty()
        urls.forEach { url ->
            message = message.replace(url, "")
        }
        if (containsUrl) {
            Log.i("test", "url: $urls")
            getisThreatURL(urls)
        }
        var entity =
            MessageEntity(urls.ifEmpty { null }, message, sender, "", containsUrl, timestamp, false)
        CoroutineScope(Dispatchers.IO).launch {
            getServerRequestMessage(message, entity)
            if (urls.isNotEmpty()) getServerRequestUrl(urls, entity)

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
//                        mapOf(
////                            "id" to entity.id,
//                            "url" to entity.url,
//                            "message" to entity.message,
//                            "sender" to entity.sender,
//                            "thumbnail" to entity.thumbnail,
//                            "containsUrl" to entity.containsUrl,
//                            "timestamp" to entity.timestamp,
//                            "isSmishing" to entity.isSmishing
//                        )
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
                val result: Map<*, *> = body["result"] as Map<*, *>
                if (status == "success") {
                    val isSmishing: Boolean = (result["result"] as String) == "smishing"
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
        val requestUrlCall = smsService.requestUrlToServer(Urls(urls))
        val body = requestUrlCall.execute().body()
        if(body != null) {
            val status: String = body["status"] as String
            val code: Int = (body["code"] as Double).toInt()
            val result: Map<*, *> = body["result"] as Map<*, *>
            Log.i("test", status)
            if (status == "success") {
                val isSmishing: Boolean = (result["result"] as String) == "smishing"
                val thumbnail: String = body["thumbnail"] as String
                if (thumbnail != "") entity.thumbnail = thumbnail
                entity.isSmishing = isSmishing
            }
            Log.i("test", body.toString())
        }
//        smsService.requestUrlToServer(Urls(urls)).enqueue(object: Callback<Map<String, Any>> {
//            override fun onResponse(
//                call: Call<Map<String, Any>>,
//                response: Response<Map<String, Any>>
//            ) {
//                val body = response.body()!!
//                val status: String = body["status"] as String
//                val code: Int = (body["code"] as Double).toInt()
//                val result: Map<*, *> = body["result"] as Map<*, *>
//                Log.i("test", status)
//                if (status == "success") {
//                    val isSmishing: Boolean = (result["result"] as String) == "smishing"
//                    val thumbnail: String = body["thumbnail"] as String
//                    if (thumbnail != "") entity.thumbnail = thumbnail
//                    entity.isSmishing = isSmishing
//                }
//                Log.i("test", body.toString())
//            }
//
//            override fun onFailure(call: Call<Map<String, Any>>, t: Throwable) {
//                Log.e("test", t.toString())
//            }
//        })
    }

    fun getisThreatURL(urls: List<String>) {
        apiService.getisThreatURL(param = APIRequestData(
            APIRequestData.Client(),
            APIRequestData.ThreatInfo(
                threatEntries = urls.map { url ->
                        APIRequestData.ThreatInfo.ThreatEntry(url)
                    }
            )
        )).enqueue(object: Callback<APIResponseDTO> {
            override fun onResponse(
                call: Call<APIResponseDTO>,
                response: Response<APIResponseDTO>
            ) {
                val body = response.body()!!
                Log.i("test", "URL Result : $body")
                if(body.matches == null) return
            }

            override fun onFailure(call: Call<APIResponseDTO>, t: Throwable) {
                Log.e("test", t.toString())
            }
        })
    }
}