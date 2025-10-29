package jp.kyoheig3.ai_edge_rag

import kotlin.toString

/**
 * Sealed class representing various error types that can occur during method calls.
 * Each error type has a specific error code and message format.
 */
sealed class CallError(
    val code: String,
    override val message: String
) : Exception(message) {

    companion object {
        /**
         * Extracts error message from exception
         */
        private fun Exception.toMessage(): String = message ?: toString()
    }
    
    /**
     * Error when creating a model fails.
     */
    class CreateModel(exception: Exception) : CallError(
        code = "CREATE_MODEL_ERROR",
        message = exception.toMessage()
    )
    
    /**
     * Error when creating a session fails.
     */
    class CreateSession(exception: Exception) : CallError(
        code = "CREATE_SESSION_ERROR",
        message = exception.toMessage()
    )

    /**
     * Error when creating an embedder fails.
     */
    class CreateEmbedder(exception: Exception) : CallError(
        code = "CREATE_EMBEDDER_ERROR",
        message = exception.toMessage()
    )

    /**
     * Error when memorize chunk fails.
     */
    class MemorizeChunk(exception: Exception) : CallError(
        code = "MEMORIZE_CHUNK_ERROR",
        message = exception.toMessage()
    )

    /**
     * Error when memorize chunks fails.
     */
    class MemorizeChunks(exception: Exception) : CallError(
        code = "MEMORIZE_CHUNKS_ERROR",
        message = exception.toMessage()
    )

    /**
     * Error when setting system instruction fails.
     */
    class SetSystemInstruction(exception: Exception) : CallError(
        code = "SET_SYSTEM_INSTRUCTION_ERROR",
        message = exception.toMessage()
    )

    /**
     * Error when generating an async response fails.
     */
    class GenerateResponseAsync(exception: Exception) : CallError(
        code = "GENERATE_RESPONSE_ASYNC_ERROR",
        message = exception.toMessage()
    )
    
    /**
     * Generic unknown error.
     */
    class Unknown(exception: Exception) : CallError(
        code = "UNKNOWN_ERROR",
        message = exception.toMessage()
    )
}