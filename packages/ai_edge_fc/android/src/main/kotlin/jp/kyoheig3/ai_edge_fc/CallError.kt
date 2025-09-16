package jp.kyoheig3.ai_edge_fc

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
     * Error when cloning a session fails.
     */
    class CloneSession(exception: Exception) : CallError(
        code = "CLONE_SESSION_ERROR",
        message = exception.toMessage()
    )
    
    /**
     * Error when enabling constraints fails.
     */
    class EnableConstraint(exception: Exception) : CallError(
        code = "ENABLE_CONSTRAINT_ERROR",
        message = exception.toMessage()
    )
    
    /**
     * Error when disabling constraints fails.
     */
    class DisableConstraint(exception: Exception) : CallError(
        code = "DISABLE_CONSTRAINT_ERROR",
        message = exception.toMessage()
    )
    
    /**
     * Error when sending a message fails.
     */
    class SendMessage(exception: Exception) : CallError(
        code = "SEND_MESSAGE_ERROR",
        message = exception.toMessage()
    )

    /**
     * Error when setting tools fails.
     */
    class SetTools(exception: Exception) : CallError(
        code = "SET_TOOLS_ERROR",
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
     * Error when getting history fails.
     */
    class GetHistory(exception: Exception) : CallError(
        code = "GET_HISTORY_ERROR",
        message = exception.toMessage()
    )
    
    /**
     * Error when getting last message fails.
     */
    class GetLast(exception: Exception) : CallError(
        code = "GET_LAST_ERROR",
        message = exception.toMessage()
    )
    
    /**
     * Error when rewinding session fails.
     */
    class Rewind(exception: Exception) : CallError(
        code = "REWIND_ERROR",
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