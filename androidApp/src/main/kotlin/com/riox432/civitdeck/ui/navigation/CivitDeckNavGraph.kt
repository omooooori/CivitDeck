package com.riox432.civitdeck.ui.navigation

import androidx.compose.animation.ExperimentalSharedTransitionApi
import androidx.compose.animation.SharedTransitionLayout
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.remember
import androidx.lifecycle.viewmodel.navigation3.rememberViewModelStoreNavEntryDecorator
import androidx.navigation3.runtime.entryProvider
import androidx.navigation3.runtime.rememberSaveableStateHolderNavEntryDecorator
import androidx.navigation3.ui.NavDisplay
import com.riox432.civitdeck.ui.detail.ModelDetailScreen
import com.riox432.civitdeck.ui.detail.ModelDetailViewModel
import com.riox432.civitdeck.ui.gallery.ImageGalleryScreen
import com.riox432.civitdeck.ui.gallery.ImageGalleryViewModel
import com.riox432.civitdeck.ui.search.ModelSearchScreen
import com.riox432.civitdeck.ui.search.ModelSearchViewModel
import org.koin.compose.viewmodel.koinViewModel
import org.koin.core.parameter.parametersOf

data object SearchRoute

data class DetailRoute(val modelId: Long, val thumbnailUrl: String? = null)

data class ImageGalleryRoute(val modelVersionId: Long)

@OptIn(ExperimentalSharedTransitionApi::class)
@Composable
fun CivitDeckNavGraph() {
    val backStack = remember { mutableStateListOf<Any>(SearchRoute) }

    SharedTransitionLayout {
        CompositionLocalProvider(LocalSharedTransitionScope provides this) {
            CivitDeckNavDisplay(backStack)
        }
    }
}

@Composable
private fun CivitDeckNavDisplay(backStack: MutableList<Any>) {
    NavDisplay(
        backStack = backStack,
        onBack = { backStack.removeLastOrNull() },
        entryDecorators = listOf(
            rememberSaveableStateHolderNavEntryDecorator(),
            rememberViewModelStoreNavEntryDecorator(),
        ),
        entryProvider = entryProvider {
            entry<SearchRoute> {
                val viewModel: ModelSearchViewModel = koinViewModel()
                ModelSearchScreen(
                    viewModel = viewModel,
                    onModelClick = { modelId, thumbnailUrl ->
                        backStack.add(DetailRoute(modelId, thumbnailUrl))
                    },
                )
            }
            entry<DetailRoute> { key ->
                val viewModel: ModelDetailViewModel = koinViewModel(
                    key = key.modelId.toString(),
                ) { parametersOf(key.modelId) }
                ModelDetailScreen(
                    viewModel = viewModel,
                    modelId = key.modelId,
                    initialThumbnailUrl = key.thumbnailUrl,
                    onBack = { backStack.removeLastOrNull() },
                    onViewImages = { modelVersionId ->
                        backStack.add(ImageGalleryRoute(modelVersionId))
                    },
                )
            }
            entry<ImageGalleryRoute> { key ->
                val viewModel: ImageGalleryViewModel = koinViewModel(
                    key = "gallery_${key.modelVersionId}",
                ) { parametersOf(key.modelVersionId) }
                ImageGalleryScreen(
                    viewModel = viewModel,
                    onBack = { backStack.removeLastOrNull() },
                )
            }
        },
    )
}
