package com.riox432.civitdeck.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import com.riox432.civitdeck.data.local.entity.SavedPromptEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface SavedPromptDao {
    @Query("SELECT * FROM saved_prompts ORDER BY savedAt DESC")
    fun observeAll(): Flow<List<SavedPromptEntity>>

    @Insert
    suspend fun insert(entity: SavedPromptEntity)

    @Query("DELETE FROM saved_prompts WHERE id = :id")
    suspend fun deleteById(id: Long)
}
