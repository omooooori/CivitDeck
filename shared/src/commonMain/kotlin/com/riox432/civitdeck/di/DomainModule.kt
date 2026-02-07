package com.riox432.civitdeck.di

import com.riox432.civitdeck.domain.usecase.GetImagesUseCase
import com.riox432.civitdeck.domain.usecase.GetModelDetailUseCase
import com.riox432.civitdeck.domain.usecase.GetModelsUseCase
import com.riox432.civitdeck.domain.usecase.GetRecommendationsUseCase
import com.riox432.civitdeck.domain.usecase.ObserveFavoritesUseCase
import com.riox432.civitdeck.domain.usecase.ObserveIsFavoriteUseCase
import com.riox432.civitdeck.domain.usecase.ToggleFavoriteUseCase
import com.riox432.civitdeck.domain.usecase.TrackModelViewUseCase
import org.koin.dsl.module

val domainModule = module {
    factory { GetModelsUseCase(get()) }
    factory { GetModelDetailUseCase(get()) }
    factory { GetImagesUseCase(get()) }
    factory { ToggleFavoriteUseCase(get()) }
    factory { ObserveFavoritesUseCase(get()) }
    factory { ObserveIsFavoriteUseCase(get()) }
    factory { TrackModelViewUseCase(get()) }
    factory { GetRecommendationsUseCase(get(), get(), get()) }
}
