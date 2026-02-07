package com.riox432.civitdeck.di

import com.riox432.civitdeck.domain.usecase.AddSearchHistoryUseCase
import com.riox432.civitdeck.domain.usecase.ClearSearchHistoryUseCase
import com.riox432.civitdeck.domain.usecase.GetImagesUseCase
import com.riox432.civitdeck.domain.usecase.GetModelDetailUseCase
import com.riox432.civitdeck.domain.usecase.GetModelsUseCase
import com.riox432.civitdeck.domain.usecase.ObserveFavoritesUseCase
import com.riox432.civitdeck.domain.usecase.ObserveIsFavoriteUseCase
import com.riox432.civitdeck.domain.usecase.ObserveSearchHistoryUseCase
import com.riox432.civitdeck.domain.usecase.ToggleFavoriteUseCase
import org.koin.mp.KoinPlatform.getKoin

object KoinHelper {
    fun getModelsUseCase(): GetModelsUseCase = getKoin().get()
    fun getModelDetailUseCase(): GetModelDetailUseCase = getKoin().get()
    fun getImagesUseCase(): GetImagesUseCase = getKoin().get()
    fun getToggleFavoriteUseCase(): ToggleFavoriteUseCase = getKoin().get()
    fun getObserveFavoritesUseCase(): ObserveFavoritesUseCase = getKoin().get()
    fun getObserveIsFavoriteUseCase(): ObserveIsFavoriteUseCase = getKoin().get()
    fun getObserveSearchHistoryUseCase(): ObserveSearchHistoryUseCase = getKoin().get()
    fun getAddSearchHistoryUseCase(): AddSearchHistoryUseCase = getKoin().get()
    fun getClearSearchHistoryUseCase(): ClearSearchHistoryUseCase = getKoin().get()
}
