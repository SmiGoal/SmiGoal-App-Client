package com.example.smigoal.db

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "MESSAGE_TABLE")
data class MessageEntity(
    @PrimaryKey(autoGenerate = true) val id: Int? = null,
    val url: List<String>?,
    val message: String,
    val sender: String,
    var thumbnail: String,
    val containsUrl: Boolean,
    val timestamp: Long,
    var hamPercentage: Double,
    var spamPercentage: Double,
    var isSmishing: Boolean
) {
    constructor(url: List<String>?, message: String, sender: String, thumbnail: String, containsUrl: Boolean, timestamp: Long, hamPercentage: Double, spamPercentage: Double, isSmishing: Boolean)
            : this(null, url, message, sender, thumbnail, containsUrl, timestamp, hamPercentage, spamPercentage, isSmishing)
}