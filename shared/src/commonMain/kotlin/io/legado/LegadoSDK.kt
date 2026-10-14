package io.legado

import io.legado.core.NetworkManager
import io.legado.data.repository.BookSourceRepository
import io.legado.domain.usecase.SearchBooksUseCase

object LegadoSDK {
    val networkManager = NetworkManager()
    val sourceRepository = BookSourceRepository(networkManager)
    val searchBooksUseCase = SearchBooksUseCase(sourceRepository)

    fun init() {
        // 初始化逻辑
    }

    fun destroy() {
        networkManager.close()
    }
}
