package jp.kyoheig3.ai_edge

import android.graphics.BitmapFactory
import com.google.common.util.concurrent.ListenableFuture
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.genai.llminference.GraphOptions
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import com.google.mediapipe.tasks.genai.llminference.LlmInferenceSession
import com.google.mediapipe.tasks.genai.llminference.ProgressListener

data class InferenceSessionOptions(
    val temperature: Float,
    val randomSeed: Int,
    val topK: Int,
    val topP: Float? = null,
    val loraPath: String? = null,
    val enableVisionModality: Boolean? = null
) {
    fun build(): LlmInferenceSession.LlmInferenceSessionOptions {
        val builder = LlmInferenceSession.LlmInferenceSessionOptions.builder()
            .setTemperature(temperature)
            .setRandomSeed(randomSeed)
            .setTopK(topK)

        topP?.let { builder.setTopP(it) }
        loraPath?.let { builder.setLoraPath(it) }
        enableVisionModality?.let {
            builder.setGraphOptions(
                GraphOptions.builder()
                    .setEnableVisionModality(it)
                    .build()
            )
        }

        return builder.build()
    }

    companion object {
        fun fromArgs(arguments: Map<*, *>): InferenceSessionOptions {
            val temperature = (arguments["temperature"] as? Number)?.toFloat()
                ?: throw IllegalArgumentException("Missing temperature")
            
            val randomSeed = (arguments["randomSeed"] as? Number)?.toInt()
                ?: throw IllegalArgumentException("Missing randomSeed")
            
            val topK = (arguments["topK"] as? Number)?.toInt()
                ?: throw IllegalArgumentException("Missing topK")
            
            val topP = (arguments["topP"] as? Number)?.toFloat()
            val loraPath = arguments["loraPath"] as? String
            val enableVisionModality = arguments["enableVisionModality"] as? Boolean
            
            return InferenceSessionOptions(
                temperature = temperature,
                randomSeed = randomSeed,
                topK = topK,
                topP = topP,
                loraPath = loraPath,
                enableVisionModality = enableVisionModality
            )
        }
    }
}

class InferenceSession(
    llmInference: LlmInference,
    options: InferenceSessionOptions
) {
    private val session: LlmInferenceSession = 
        LlmInferenceSession.createFromOptions(llmInference, options.build())

    fun addQueryChunk(prompt: String) = session.addQueryChunk(prompt)

    fun addImage(imageBytes: ByteArray) {
        val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
            ?: throw IllegalArgumentException("Failed to decode image bytes")
        val mpImage = BitmapImageBuilder(bitmap).build()
        session.addImage(mpImage)
    }

    fun generateResponse(prompt: String?): String {
        if (prompt != null) {
            session.addQueryChunk(prompt)
        }
        return session.generateResponse()
    }

    fun generateResponseAsync(prompt: String?, progressListener: ProgressListener<String>): ListenableFuture<String> {
        if (prompt != null) {
            session.addQueryChunk(prompt)
        }
        return session.generateResponseAsync(progressListener)
    }

    fun close() {
        session.close()
    }
}