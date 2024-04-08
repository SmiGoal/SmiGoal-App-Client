package com.example.smigoal.functions

import com.example.smigoal.models.Message
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.POST
import retrofit2.http.Query
import retrofit2.http.Url

interface SMSService {
    @POST("message")
    fun requestMessageToServer(@Body message: String): Call<Map<String, Any>>

    @POST("url")
    fun requestUrlToServer(@Body urls: List<String>): Call<Map<String, Any>>
}