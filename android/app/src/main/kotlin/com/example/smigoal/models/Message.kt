package com.example.smigoal.models

import com.google.gson.annotations.SerializedName
import java.util.regex.Pattern

data class Message(
    @SerializedName("message") val message: String,
    @SerializedName("url") val url: List<String>?,
    val fullMessage: String
)

fun extractUrls(text: String): List<String> {
    val urls = mutableListOf<String>()
    val pattern = Pattern.compile(
        "\\b(?:http(?:s)?://)?(?:www\\.)?[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}(?:/[^\\s]*)?\\b",
        Pattern.CASE_INSENSITIVE
    )
    val matcher = pattern.matcher(text)

    while (matcher.find()) {
        urls.add(matcher.group())
    }

    return urls
}