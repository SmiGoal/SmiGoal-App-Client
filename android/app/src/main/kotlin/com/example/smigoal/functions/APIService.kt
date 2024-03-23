package com.example.smigoal.functions

import com.example.smigoal.BuildConfig
import com.example.smigoal.models.APIRequestData
import com.example.smigoal.models.APIResponseDTO
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.Header
import retrofit2.http.POST
import retrofit2.http.Query

val API_KEY = BuildConfig.API_KEY
interface APIService {
    @POST("v4/threatMatches:find")
    fun getisThreatURL(
        @Header("Content-Type") header: String = "application/json",
        @Query("key") apiKey: String = API_KEY, // API 키를 메서드 인자로 전달
        @Body param: APIRequestData
    ): Call<APIResponseDTO>
}