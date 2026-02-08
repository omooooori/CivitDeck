package com.riox432.civitdeck.ui.prompts

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.riox432.civitdeck.domain.model.SavedPrompt
import com.riox432.civitdeck.domain.usecase.DeleteSavedPromptUseCase
import com.riox432.civitdeck.domain.usecase.ObserveSavedPromptsUseCase
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class SavedPromptsViewModel(
    observeSavedPromptsUseCase: ObserveSavedPromptsUseCase,
    private val deleteSavedPromptUseCase: DeleteSavedPromptUseCase,
) : ViewModel() {

    val prompts: StateFlow<List<SavedPrompt>> =
        observeSavedPromptsUseCase()
            .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    fun delete(id: Long) {
        viewModelScope.launch {
            deleteSavedPromptUseCase(id)
        }
    }
}
