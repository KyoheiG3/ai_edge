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
        try {
            val arguments = checkNotNull(call.arguments as? Map<*, *>) { "Invalid arguments format" }
            val options = InferenceModelOptions.fromArgs(arguments)
            inferenceModel?.close()
            inferenceModel = InferenceModel(context, options)
        } catch (e: Exception) {
            throw CallError.CreateModel(e.message ?: e.toString())
        }
    }

    private fun handleCreateSession(call: MethodCall) {
        try {
            val inference = checkNotNull(inferenceModel?.inference) { "Inference model is not created" }
            val arguments = checkNotNull(call.arguments as? Map<*, *>) { "Invalid arguments format" }
            val options = InferenceSessionOptions.fromArgs(arguments)
            session?.close()
            session = InferenceSession(inference, options)
        } catch (e: Exception) {
            throw CallError.CreateSession(e.message ?: e.toString())
        }
    }

    private fun handleAddQueryChunk(call: MethodCall) {
        try {
            val session = checkNotNull(session) { "Session not created" }
            val prompt = checkNotNull(call.argument<String>("prompt")) { "Missing prompt" }
            session.addQueryChunk(prompt)
        } catch (e: Exception) {
            throw CallError.AddQueryChunk(e.message ?: e.toString())
        }
    }

    private fun handleAddImage(call: MethodCall) {
        try {
            val session = checkNotNull(session) { "Session not created" }
            val imageBytes = checkNotNull(call.argument<ByteArray>("imageBytes")) { "Missing imageBytes" }
            session.addImage(imageBytes)
        } catch (e: Exception) {
            throw CallError.AddImage(e.message ?: e.toString())
        }
    }

    private fun handleGenerateResponse(call: MethodCall): String {
        return try {
            val session = checkNotNull(session) { "Session not created" }
            session.generateResponse(call.argument("prompt"))
        } catch (e: Exception) {
            throw CallError.GenerateResponse(e.message ?: e.toString())
        }
    }

    private fun handleGenerateResponseAsync(call: MethodCall) {
        try {
            val session = checkNotNull(session) { "Session not created" }
            val eventSink = checkNotNull(eventSink) { "Event sink not created" }
            session.generateResponseAsync(call.argument("prompt")) { result, done ->
                val payload = mapOf("partialResult" to result, "done" to done)
                scope.launch(Dispatchers.Main) {
                    eventSink.success(payload)
                    if (done) {
                        eventSink.endOfStream()
                    }
                }
            }
        } catch (e: Exception) {
            throw CallError.GenerateResponseAsync(e.message ?: e.toString())
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