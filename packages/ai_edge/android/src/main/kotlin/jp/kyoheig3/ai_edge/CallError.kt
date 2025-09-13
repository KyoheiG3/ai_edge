package jp.kyoheig3.ai_edge

/**
 * Sealed class representing various error types that can occur during AI Edge operations.
 * Each error type has a specific error code and message.
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
     * Generic unknown error.
     */
    class Unknown(exception: Exception) : CallError(
        code = "UNKNOWN_ERROR",
        message = exception.toMessage()
    )
    
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
     * Error when adding a query chunk fails.
     */
    class AddQueryChunk(exception: Exception) : CallError(
        code = "ADD_QUERY_CHUNK_ERROR",
        message = exception.toMessage()
    )
    
    /**
     * Error when adding an image fails.
     */
    class AddImage(exception: Exception) : CallError(
        code = "ADD_IMAGE_ERROR",
        message = exception.toMessage()
    )
    
    /**
     * Error when generating a response fails.
     */
    class GenerateResponse(exception: Exception) : CallError(
        code = "GENERATE_RESPONSE_ERROR",
        message = exception.toMessage()
    )
    
    /**
     * Error when generating an async response fails.
     */
    class GenerateResponseAsync(exception: Exception) : CallError(
        code = "GENERATE_RESPONSE_ASYNC_ERROR",
        message = exception.toMessage()
    )
}