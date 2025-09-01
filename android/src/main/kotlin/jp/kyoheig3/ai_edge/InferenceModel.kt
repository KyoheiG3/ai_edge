package jp.kyoheig3.ai_edge

import android.content.Context
import android.graphics.BitmapFactory
import com.google.common.util.concurrent.ListenableFuture
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.genai.llminference.GraphOptions
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import com.google.mediapipe.tasks.genai.llminference.LlmInferenceSession
import com.google.mediapipe.tasks.genai.llminference.ProgressListener
import java.io.File

enum class PreferredBackend(val value: Int) {
    UNKNOWN(0),
    CPU(1),
    GPU(2),
}

class InferenceModel(
    context: Context,
    modelPath: String,
    maxTokens: Int,
    supportedLoraRanks: List<Int>?,
    maxNumImages: Int?,
    preferredBackend: PreferredBackend?,
) {
    val inference: LlmInference

    init {
        if (!File(modelPath).exists()) {
            throw IllegalArgumentException("Model not found at path: $modelPath")
        }

        val builder = LlmInference.LlmInferenceOptions.builder()
            .setModelPath(modelPath)
            .setMaxTokens(maxTokens)

        supportedLoraRanks?.let { builder.setSupportedLoraRanks(it) }
        maxNumImages?.let { if (it > 0) builder.setMaxNumImages(it) }

        preferredBackend?.let {
            val backendEnum = LlmInference.Backend.entries.getOrNull(it.ordinal)
                ?: throw IllegalArgumentException("Invalid preferredBackend value: ${it.ordinal}")
            builder.setPreferredBackend(backendEnum)
        }

        inference = LlmInference.createFromOptions(context, builder.build())
    }

    fun close() {
        inference.close()
    }
}

class InferenceSession(
    llmInference: LlmInference,
    temperature: Float,
    randomSeed: Int,
    topK: Int,
    topP: Float?,
    loraPath: String?,
    enableVisionModality: Boolean?,
) {
    private val session: LlmInferenceSession

    init {
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

        session = LlmInferenceSession.createFromOptions(llmInference, builder.build())
    }

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