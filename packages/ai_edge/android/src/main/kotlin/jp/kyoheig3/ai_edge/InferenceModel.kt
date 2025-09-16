package jp.kyoheig3.ai_edge

import android.content.Context
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import java.io.File

enum class PreferredBackend(val value: Int) {
    UNKNOWN(0),
    CPU(1),
    GPU(2),
}

data class InferenceModelOptions(
    val modelPath: String,
    val maxTokens: Int? = null,
    val supportedLoraRanks: List<Int>? = null,
    val maxNumImages: Int? = null,
    val preferredBackend: PreferredBackend? = null
) {
    fun build(): LlmInference.LlmInferenceOptions {
        if (!File(modelPath).exists()) {
            throw IllegalArgumentException("Model not found at path: $modelPath")
        }

        val builder = LlmInference.LlmInferenceOptions.builder()
            .setModelPath(modelPath)
        
        maxTokens?.let { builder.setMaxTokens(it) }
        supportedLoraRanks?.let { builder.setSupportedLoraRanks(it) }
        maxNumImages?.let { if (it > 0) builder.setMaxNumImages(it) }

        preferredBackend?.let {
            val backendEnum = LlmInference.Backend.entries.getOrNull(it.ordinal)
                ?: throw IllegalArgumentException("Invalid preferredBackend value: ${it.ordinal}")
            builder.setPreferredBackend(backendEnum)
        }

        return builder.build()
    }

    companion object {
        fun fromArgs(arguments: Map<*, *>): InferenceModelOptions {
            val modelPath = arguments["modelPath"] as? String
                ?: throw IllegalArgumentException("Missing modelPath")

            val maxTokens = (arguments["maxTokens"] as? Number)?.toInt()

            val supportedLoraRanks = (arguments["loraRanks"] as? List<*>)
                ?.mapNotNull { (it as? Number)?.toInt() }
                ?.takeIf { it.isNotEmpty() }

            val maxNumImages = (arguments["maxNumImages"] as? Number)?.toInt()

            val preferredBackend = (arguments["preferredBackend"] as? Number)?.toInt()?.let {
                PreferredBackend.entries.getOrNull(it)
            }

            return InferenceModelOptions(
                modelPath = modelPath,
                maxTokens = maxTokens,
                supportedLoraRanks = supportedLoraRanks,
                maxNumImages = maxNumImages,
                preferredBackend = preferredBackend
            )
        }
    }
}

class InferenceModel(
    context: Context,
    options: InferenceModelOptions
) {
    val inference: LlmInference = LlmInference.createFromOptions(context, options.build())

    fun close() {
        inference.close()
    }
}
