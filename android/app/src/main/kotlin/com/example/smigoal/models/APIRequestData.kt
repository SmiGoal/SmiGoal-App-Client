package com.example.smigoal.models

import com.google.gson.annotations.SerializedName

data class APIRequestData(
    @SerializedName("client")
    val client: Client,
    @SerializedName("threatInfo")
    val threatInfo: ThreatInfo
) {
    data class Client(
        @SerializedName("clientId")
        val clientId: String = "SmiGoal",
        @SerializedName("clientVersion")
        val clientVersion: String = "1.0.0" // 1.5.2
    )

    data class ThreatInfo(
        @SerializedName("platformTypes")
        val platformTypes: List<String> = listOf("ALL_PLATFORMS"), // 모든 플랫폼
        @SerializedName("threatEntries")
        val threatEntries: List<ThreatEntry>,
        @SerializedName("threatEntryTypes")
        val threatEntryTypes: List<String> = listOf("URL"), // URL에 대해서만 검증
        @SerializedName("threatTypes")
        val threatTypes: List<String> = listOf(
            "THREAT_TYPE_UNSPECIFIED", // 알 수 없는 작업입니다.
            "MALWARE", // 멀웨어 위협 유형
            "SOCIAL_ENGINEERING", // 소셜 엔지니어링 위협 유형입니다.
            "UNWANTED_SOFTWARE", // 원치 않는 소프트웨어 위협 유형입니다.
            "POTENTIALLY_HARMFUL_APPLICATION", // 잠재적으로 위험한 애플리케이션 위협 유형입니다.
        )
    ) {
        data class ThreatEntry(
            @SerializedName("url")
            val url: String
        )
    }
}