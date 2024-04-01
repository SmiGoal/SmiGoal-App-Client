package com.example.smigoal.functions

import android.content.Context
import android.util.Log
import com.example.smigoal.BuildConfig
import com.example.smigoal.db.MessageEntity
import com.example.smigoal.models.APIRequestData
import com.example.smigoal.models.APIResponseDTO
import com.example.smigoal.models.Message
import com.example.smigoal.models.SMSServiceData
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
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

    fun getServerRequest(context: Context, url: String, message: Message, sender: String, containsUrl: Boolean, timestamp: Long) {
        smsService.requestServer(url, message).enqueue(object: Callback<Map<String, Any>> {
            override fun onResponse(call: Call<Map<String, Any>>, response: Response<Map<String, Any>>) {
                val body = response.body()!!
                Log.i("test", body.toString())
                val entity = when(body["status"]) {
                    "success" -> MessageEntity(message.url, message.fullMessage, sender, containsUrl, timestamp, false)
                    else -> MessageEntity(message.url, message.fullMessage, sender, containsUrl, timestamp, true)
                }
                Log.i("test", entity.toString())
                SMSServiceData.setResponseFromServer(entity)
                CoroutineScope(Dispatchers.Main).launch {
                    SMSServiceData.smsReceiver.sendNotification(context, entity)
                    Log.i("test", "result : $entity")
                    Log.i("test", "timestamp : ${entity.timestamp}")

                    SMSServiceData.channel.invokeMethod(
                        "onReceivedSMS", mapOf(
                            "message" to entity.message,
                            "sender" to entity.sender,
                            "result" to if (entity.isSmishing) "spam" else "ham",
                            "timestamp" to entity.timestamp
                        )
                    )
                }
            }
            override fun onFailure(call: Call<Map<String, Any>>, t: Throwable) {
                Log.e("test", t.toString())
            }
        })
    }

    fun getisThreatURL(context: Context, urls: List<String>) {
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