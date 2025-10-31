package jp.kyoheig3.ai_edge_rag

import android.content.Context
import android.util.Log
import com.google.ai.edge.localagents.rag.chains.ChainConfig
import com.google.ai.edge.localagents.rag.chains.RetrievalAndInferenceChain
import com.google.ai.edge.localagents.rag.chunking.TextChunker
import com.google.ai.edge.localagents.rag.memory.DefaultSemanticTextMemory
import com.google.ai.edge.localagents.rag.memory.DefaultVectorStore
import com.google.ai.edge.localagents.rag.memory.SemanticMemory
import com.google.ai.edge.localagents.rag.memory.SqliteVectorStore
import com.google.ai.edge.localagents.rag.models.GeckoEmbeddingModel
import com.google.ai.edge.localagents.rag.models.GeminiEmbedder
import com.google.ai.edge.localagents.rag.models.GemmaEmbeddingModel
import com.google.ai.edge.localagents.rag.models.MediaPipeLlmBackend
import com.google.ai.edge.localagents.rag.prompt.PromptBuilder
import com.google.ai.edge.localagents.rag.retrieval.RetrievalConfig
import com.google.ai.edge.localagents.rag.retrieval.RetrievalConfig.TaskType
import com.google.ai.edge.localagents.rag.retrieval.RetrievalRequest
import com.google.common.collect.ImmutableList
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import jp.kyoheig3.ai_edge.InferenceModelOptions
import jp.kyoheig3.ai_edge.InferenceSessionOptions
import jp.kyoheig3.ai_edge.PreferredBackend
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.Optional

class AiEdgeRagPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context
    private val scope = CoroutineScope(Dispatchers.IO)
    private var inferenceModelOptions: InferenceModelOptions? = null
    private var session: MediaPipeLlmBackend? = null
    private var semanticMemory: SemanticMemory<String>? = null
    private var systemInstruction: PromptBuilder? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "ai_edge_rag/methods")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "ai_edge_rag/events")
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        scope.launch {
            try {
                when (call.method) {
                    "createModel" -> handleCreateModel(call)
                    "createSession" -> handleCreateSession(call)
                    "createEmbeddingModel" -> handleCreateEmbeddingModel(call)
                    "createGeminiEmbedder" -> handleCreateGeminiEmbedder(call)
                    "memorizeChunk" -> handleMemorizeChunk(call)
                    "memorizeChunks" -> handleMemorizeChunks(call)
                    "memorizeChunkedText" -> handleMemorizeChunkedText(call)
                    "setSystemInstruction" -> handleSetSystemInstruction(call)
                    "generateResponseAsync" -> handleGenerateResponseAsync(call)
                    "close" -> handleClose()
                    else -> throw NotImplementedError("Method not implemented: ${call.method}")
                }
                launch(Dispatchers.Main) {
                    result.success(null)
                }
            } catch (_: NotImplementedError) {
                launch(Dispatchers.Main) {
                    result.notImplemented()
                }
            } catch (e: CallError) {
                launch(Dispatchers.Main) {
                    result.error(e.code, e.message, e.stackTraceToString())
                }
            } catch (e: Exception) {
                launch(Dispatchers.Main) {
                    val error = CallError.Unknown(e)
                    result.error(error.code, error.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun handleCreateModel(call: MethodCall) {
        try {
            val arguments = checkNotNull(call.arguments as? Map<*, *>) { "Invalid arguments format" }
            inferenceModelOptions = InferenceModelOptions.fromArgs(arguments)
        } catch (e: Exception) {
            throw CallError.CreateModel(e)
        }
    }

    private fun handleCreateSession(call: MethodCall) {
        try {
            val inferenceModelOptions = checkNotNull(inferenceModelOptions) { "Inference model is not created" }
            val arguments = checkNotNull(call.arguments as? Map<*, *>) { "Invalid arguments format" }

            val modelOptions = inferenceModelOptions.build()
            val sessionOptions = InferenceSessionOptions.fromArgs(arguments).build()

            session = MediaPipeLlmBackend(
                context,
                modelOptions,
                sessionOptions
            )

            session?.initialize()?.get()
        } catch (e: Exception) {
            throw CallError.CreateSession(e)
        }
    }

    private fun handleCreateEmbeddingModel(call: MethodCall) {
        try {
            val tokenizerModelPath =
                checkNotNull(call.argument<String>("tokenizerModelPath")) { "Missing tokenizerModelPath" }
            val embeddingModelPath =
                checkNotNull(call.argument<String>("embeddingModelPath")) { "Missing embeddingModelPath" }
            val useGpu = (call.argument<Number>("preferredBackend"))?.toInt()?.let {
                PreferredBackend.entries.getOrNull(it)
            } == PreferredBackend.GPU

            val embedder = when (call.argument<String>("modelType")) {
                "Gecko" -> GeckoEmbeddingModel(
                    embeddingModelPath,
                    Optional.ofNullable(tokenizerModelPath),
                    useGpu,
                )
                else -> GemmaEmbeddingModel(
                    embeddingModelPath,
                    tokenizerModelPath,
                    useGpu,
                )
            }

            val vectorStore = when (call.argument<String>("vectorStore")) {
                // Gecko embedding model dimension is 768
                "SQLite" -> SqliteVectorStore(768)
                else -> DefaultVectorStore()
            }

            semanticMemory = DefaultSemanticTextMemory(
                vectorStore,
                embedder
            )
        } catch (e: Exception) {
            throw CallError.CreateEmbedder(e)
        }
    }

    private fun handleCreateGeminiEmbedder(call: MethodCall) {
        try {
            val embeddingModel =
                checkNotNull(call.argument<String>("geminiEmbeddingModel")) { "Missing geminiEmbeddingModel" }
            val apiKey =
                checkNotNull(call.argument<String>("geminiApiKey")) { "Missing geminiApiKey" }

            val vectorStore = when (call.argument<String>("vectorStore")) {
                // Gecko embedding model dimension is 768
                "SQLite" -> SqliteVectorStore(768)
                else -> DefaultVectorStore()
            }

            val embedder = GeminiEmbedder(embeddingModel, apiKey)

            semanticMemory = DefaultSemanticTextMemory(
                vectorStore,
                embedder
            )

        } catch (e: Exception) {
            throw CallError.MemorizeChunk(e)
        }
    }

    private fun handleMemorizeChunk(call: MethodCall) {
        try {
            val semanticMemory = checkNotNull(semanticMemory) { "Embedder is not created" }
            val chunk = checkNotNull(call.argument<String>("chunk")) { "Missing chunk" }

            semanticMemory.recordMemoryItem(chunk)?.get()
        } catch (e: Exception) {
            throw CallError.MemorizeChunk(e)
        }
    }

    private fun handleMemorizeChunks(call: MethodCall) {
        try {
            val semanticMemory = checkNotNull(semanticMemory) { "Embedder is not created" }
            val chunks = checkNotNull(call.argument<List<String>>("chunks")) { "Missing chunks" }

            if (chunks.isNotEmpty()) {
                semanticMemory.recordBatchedMemoryItems(ImmutableList.copyOf(chunks))?.get()
            }
        } catch (e: Exception) {
            throw CallError.MemorizeChunks(e)
        }
    }

    private fun handleMemorizeChunkedText(call: MethodCall) {
        val semanticMemory = checkNotNull(semanticMemory) { "Embedder is not created" }
        val text = checkNotNull(call.argument<String>("text")) { "Missing text" }
        val chunkSize = checkNotNull(call.argument<Int>("chunkSize")) { "Missing chunkSize" }
        val chunkOverlap = call.argument<Int>("chunkOverlap")

        val chunker = TextChunker()
        val chunks = if (chunkOverlap != null) {
            chunker.chunk(text, chunkSize, chunkOverlap)
        } else {
            chunker.chunkBySentences(text, chunkSize)
        }

        if (chunks.isNotEmpty()) {
            semanticMemory.recordBatchedMemoryItems(ImmutableList.copyOf(chunks))?.get()
        }
    }

    private fun handleSetSystemInstruction(call: MethodCall) {
        try {
            val argument = checkNotNull(call.argument<String>("systemInstruction")) { "Missing systemInstruction" }
            systemInstruction = PromptBuilder(argument)
        } catch (e: Exception) {
            throw CallError.SetSystemInstruction(e)
        }
    }

    private fun handleGenerateResponseAsync(call: MethodCall) {
        try {
            val session = checkNotNull(session) { "Session is not created" }
            val eventSink = checkNotNull(eventSink) { "Event sink is not created" }
            val prompt = checkNotNull(call.argument<String>("prompt")) { "Missing prompt" }
            val topK = checkNotNull(call.argument<Int>("topK")) { "Missing topK" }
            val minSimilarityScore = checkNotNull(call.argument<Float>("minSimilarityScore")) { "Missing minSimilarityScore" }

            val config = ChainConfig.create(
                session,
                systemInstruction,
                semanticMemory
            )

            val retrievalAndInferenceChain = RetrievalAndInferenceChain(config)

            val request = RetrievalRequest.create(
                prompt,
                RetrievalConfig.create(topK, minSimilarityScore, TaskType.QUESTION_ANSWERING)
            )

            retrievalAndInferenceChain.invoke(request) { result, done ->
                val payload = mapOf("partialResult" to result.text, "done" to done)
                scope.launch(Dispatchers.Main) {
                    eventSink.success(payload)
                    if (done) {
                        eventSink.endOfStream()
                    }
                }
            }
        } catch (e: Exception) {
            throw CallError.GenerateResponseAsync(e)
        }
    }

    private fun handleClose() {
        session?.close()
        session = null

        inferenceModelOptions = null
        systemInstruction = null
        semanticMemory = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
