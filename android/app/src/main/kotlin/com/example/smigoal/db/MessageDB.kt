package com.example.smigoal.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters

@Database(
    entities = [MessageEntity::class],
    version = 1,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class MessageDB : RoomDatabase() {
    abstract fun messageDao(): MessageDAO

    companion object {
        private var instance: MessageDB? = null

        @Synchronized
        fun getInstance(context: Context): MessageDB? {
            if (instance == null) {
                synchronized(MessageDB::class) {
                    instance = Room.databaseBuilder(
                        context.applicationContext,
                        MessageDB::class.java,
                        "SmiGoal-database"
                    ).build()
                }
            }
            return instance
        }
    }
}