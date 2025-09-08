package jp.kyoheig3.ai_edge

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*

sealed class CallError(override val message: String) : Exception(message) {
    data class Unknown(val msg: String) : CallError(msg)
    data class CreateModel(val msg: String) : CallError(msg)
    data class CreateSession(val msg: String) : CallError(msg)
    data class AddQueryChunk(val msg: String) : CallError(msg)
    data class AddImage(val msg: String) : CallError(msg)
    data class GenerateResponse(val msg: String) : CallError(msg)
    data class GenerateResponseAsync(val msg: String) : CallError(msg)
    
    val code: String
        get() = when (this) {
            is Unknown -> "UNKNOWN_ERROR"
            is CreateModel -> "CREATE_MODEL_ERROR"
            is CreateSession -> "CREATE_SESSION_ERROR"
            is AddQueryChunk -> "ADD_QUERY_CHUNK_ERROR"
            is AddImage -> "ADD_IMAGE_ERROR"
            is GenerateResponse -> "GENERATE_RESPONSE_ERROR"
            is GenerateResponseAsync -> "GENERATE_RESPONSE_ASYNC_ERROR"
        }
}

class AiEdgePlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context
    private val scope = CoroutineScope(Dispatchers.IO)
    private var eventSink: EventChannel.EventSink? = null
    private var inferenceModel: InferenceModel? = null
    private var session: InferenceSession? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "ai_edge/methods")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "ai_edge/events")
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        scope.launch {
            try {
                val response = when (call.method) {
                    "createModel" -> handleCreateModel(call)
                    "createSession" -> handleCreateSession(call)
                    "addQueryChunk" -> handleAddQueryChunk(call)
                    "addImage" -> handleAddImage(call)
                    "generateResponse" -> handleGenerateResponse(call)
                    "generateResponseAsync" -> handleGenerateResponseAsync(call)
                    "close" -> handleClose()
                    else -> throw NotImplementedError("Method not implemented: ${call.method}")
                }
                launch(Dispatchers.Main) {
                    result.success(response as? String)
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
                    val error = CallError.Unknown(e.message ?: "Unknown error")
                    result.error(error.code, error.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun handleCreateModel(call: MethodCall) {
        val modelPath = call.argument<String>("modelPath")
            ?: throw CallError.CreateModel("Missing modelPath")
        val maxTokens = (call.argument<Number>("maxTokens")
            ?: throw CallError.CreateModel("Missing maxTokens")).toInt()

        val loraRanks = call.argument<List<Number>>("loraRanks")?.map { it.toInt() }
        val maxNumImages = call.argument<Number>("maxNumImages")?.toInt()

        val preferredBackend = call.argument<Number>("preferredBackend")?.toInt()?.let {
            PreferredBackend.entries.getOrNull(it)
        }

        try {
            inferenceModel?.close()
            inferenceModel = InferenceModel(
                context,
                modelPath,
                maxTokens,
                loraRanks,
                maxNumImages,
                preferredBackend,
            )
        } catch (e: Exception) {
            throw CallError.CreateModel(e.message ?: e.toString())
        }
    }

    private fun handleCreateSession(call: MethodCall) {
        val inference = inferenceModel?.inference
            ?: throw CallError.CreateSession("Inference model is not created")

        val temperature = call.argument<Number>("temperature")?.toFloat()
            ?: throw CallError.CreateSession("Missing temperature")
        val randomSeed = call.argument<Number>("randomSeed")?.toInt()
            ?: throw CallError.CreateSession("Missing randomSeed")
        val topK = call.argument<Number>("topK")?.toInt()
            ?: throw CallError.CreateSession("Missing topK")

        val topP = call.argument<Number>("topP")?.toFloat()
        val loraPath = call.argument<String>("loraPath")
        val enableVisionModality = call.argument<Boolean>("enableVisionModality")

        try {
            session?.close()
            session = InferenceSession(
                inference,
                temperature,
                randomSeed,
                topK,
                topP,
                loraPath,
                enableVisionModality
            )
        } catch (e: Exception) {
            throw CallError.CreateSession(e.message ?: e.toString())
        }
    }

    private fun handleAddQueryChunk(call: MethodCall) {
        val session = session
            ?: throw CallError.AddQueryChunk("Session not created")
        val prompt = call.argument<String>("prompt") 
            ?: throw CallError.AddQueryChunk("Missing prompt")

        try {
            session.addQueryChunk(prompt)
        } catch (e: Exception) {
            throw CallError.AddQueryChunk(e.message ?: e.toString())
        }
    }

    private fun handleAddImage(call: MethodCall) {
        val session = session 
            ?: throw CallError.AddImage("Session not created")
        val imageBytes = call.argument<ByteArray>("imageBytes") 
            ?: throw CallError.AddImage("Missing imageBytes")

        try {
            session.addImage(imageBytes)
        } catch (e: Exception) {
            throw CallError.AddImage(e.message ?: e.toString())
        }
    }

    private fun handleGenerateResponse(call: MethodCall): String {
        val session = session 
            ?: throw CallError.GenerateResponse("Session not created")

        return try {
            session.generateResponse(call.argument("prompt"))
        } catch (e: Exception) {
            throw CallError.GenerateResponse(e.message ?: e.toString())
        }
    }

    private fun handleGenerateResponseAsync(call: MethodCall) {
        val session = session 
            ?: throw CallError.GenerateResponseAsync("Session not created")
        val eventSink = eventSink
            ?: throw CallError.GenerateResponseAsync("Event sink not created")

        session.generateResponseAsync(call.argument("prompt")) { result, done ->
            val payload = mapOf("partialResult" to result, "done" to done)
            scope.launch(Dispatchers.Main) {
                eventSink.success(payload)
                if (done) {
                    eventSink.endOfStream()
                }
            }
        }
    }

    private fun handleClose() {
        try {
            session?.close()
        } catch (e: IllegalStateException) {
            // Session is still processing, ignore the error
            Log.w("AiEdgePlugin", "Session close failed: ${e.message}")
        }
        session = null

        inferenceModel?.close()
        inferenceModel = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}