package jp.kyoheig3.ai_edge

/**
 * Sealed class representing various error types that can occur during AI Edge operations.
 * Each error type has a specific error code and message.
 */
sealed class CallError(
    val code: String,
    override val message: String
) : Exception(message) {
    
    /**
     * Generic unknown error.
     */
    class Unknown(details: String) : CallError(
        code = "UNKNOWN_ERROR",
        message = details
    )
    
    /**
     * Error when creating a model fails.
     */
    class CreateModel(details: String) : CallError(
        code = "CREATE_MODEL_ERROR",
        message = details
    )
    
    /**
     * Error when creating a session fails.
     */
    class CreateSession(details: String) : CallError(
        code = "CREATE_SESSION_ERROR",
        message = details
    )
    
    /**
     * Error when adding a query chunk fails.
     */
    class AddQueryChunk(details: String) : CallError(
        code = "ADD_QUERY_CHUNK_ERROR",
        message = details
    )
    
    /**
     * Error when adding an image fails.
     */
    class AddImage(details: String) : CallError(
        code = "ADD_IMAGE_ERROR",
        message = details
    )
    
    /**
     * Error when generating a response fails.
     */
    class GenerateResponse(details: String) : CallError(
        code = "GENERATE_RESPONSE_ERROR",
        message = details
    )
    
    /**
     * Error when generating an async response fails.
     */
    class GenerateResponseAsync(details: String) : CallError(
        code = "GENERATE_RESPONSE_ASYNC_ERROR",
        message = details
    )
}