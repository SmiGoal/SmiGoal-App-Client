package com.example.smigoal.db

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query

@Dao
interface MessageDAO {
    @Query("SELECT * FROM MESSAGE_TABLE")
    fun getMessage(): List<MessageEntity>?

    @Query("DELETE FROM MESSAGE_TABLE")
    fun deleteAllMessages()

    @Query("SELECT * FROM MESSAGE_TABLE WHERE timestamp >= :startDate")
    fun getMessagesFromDate(startDate: Long): List<MessageEntity>

    @Query("SELECT * FROM MESSAGE_TABLE ORDER BY id DESC LIMIT 1")
    fun getCurrentMessage(): MessageEntity?

    @Delete
    fun deleteMessage(messageEntity: MessageEntity)

    @Insert
    fun insertMessage(messageEntity: MessageEntity)
}