package com.riox432.civitdeck.domain.repository

import com.riox432.civitdeck.domain.model.ImageGenerationMeta
import com.riox432.civitdeck.domain.model.SavedPrompt
import kotlinx.coroutines.flow.Flow

interface SavedPromptRepository {
    fun observeAll(): Flow<List<SavedPrompt>>
    suspend fun save(meta: ImageGenerationMeta, sourceImageUrl: String?)
    suspend fun delete(id: Long)
}
