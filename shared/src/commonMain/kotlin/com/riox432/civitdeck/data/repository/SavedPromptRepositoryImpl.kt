package com.riox432.civitdeck.data.repository

import com.riox432.civitdeck.data.local.currentTimeMillis
import com.riox432.civitdeck.data.local.dao.SavedPromptDao
import com.riox432.civitdeck.data.local.entity.SavedPromptEntity
import com.riox432.civitdeck.domain.model.ImageGenerationMeta
import com.riox432.civitdeck.domain.model.SavedPrompt
import com.riox432.civitdeck.domain.model.toDomain
import com.riox432.civitdeck.domain.repository.SavedPromptRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class SavedPromptRepositoryImpl(
    private val dao: SavedPromptDao,
) : SavedPromptRepository {

    override fun observeAll(): Flow<List<SavedPrompt>> =
        dao.observeAll().map { list -> list.map { it.toDomain() } }

    override suspend fun save(meta: ImageGenerationMeta, sourceImageUrl: String?) {
        dao.insert(
            SavedPromptEntity(
                prompt = meta.prompt ?: "",
                negativePrompt = meta.negativePrompt,
                sampler = meta.sampler,
                steps = meta.steps,
                cfgScale = meta.cfgScale,
                seed = meta.seed,
                modelName = meta.model,
                size = meta.size,
                sourceImageUrl = sourceImageUrl,
                savedAt = currentTimeMillis(),
            ),
        )
    }

    override suspend fun delete(id: Long) = dao.deleteById(id)
}
