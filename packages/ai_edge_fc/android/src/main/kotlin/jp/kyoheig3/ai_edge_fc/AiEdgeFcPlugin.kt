package jp.kyoheig3.ai_edge_fc

import android.content.Context
import android.util.Log
import com.google.ai.edge.localagents.core.proto.Content
import com.google.ai.edge.localagents.core.proto.Tool
import com.google.ai.edge.localagents.fc.proto.ConstraintOptions
import com.google.ai.edge.localagents.fc.ChatSession
import com.google.ai.edge.localagents.fc.GemmaFormatter
import com.google.ai.edge.localagents.fc.GenerativeModel
import com.google.ai.edge.localagents.fc.LlmInferenceBackend
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import jp.kyoheig3.ai_edge.InferenceModel
import jp.kyoheig3.ai_edge.InferenceModelOptions
import jp.kyoheig3.ai_edge.InferenceSessionOptions
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class AiEdgeFcPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val scope = CoroutineScope(Dispatchers.IO)
    private var inferenceModel: InferenceModel? = null
    private var session: ChatSession? = null
    private var systemInstruction: Content? = null
    private var tools: List<Tool> = emptyList()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ai_edge_fc")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        scope.launch {
            try {
                val response = when (call.method) {
                    "createModel" -> handleCreateModel(call)
                    "createSession" -> handleCreateSession(call)
                    "cloneSession" -> handleCloneSession()
                    "enableConstraint" -> handleEnableConstraint(call)
                    "disableConstraint" -> handleDisableConstraint()
                    "sendMessage" -> handleSendMessage(call)
                    "setTools" -> handleSetTools(call)
                    "setSystemInstruction" -> handleSetSystemInstruction(call)
                    "getHistory" -> handleGetHistory()
                    "getLast" -> handleGetLast()
                    "close" -> handleClose()
                    else -> throw NotImplementedError("Method not implemented: ${call.method}")
                }
                launch(Dispatchers.Main) {
                    result.success(if (response is Unit) null else response)
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
            val options = InferenceModelOptions.fromArgs(arguments)
            inferenceModel?.close()
            inferenceModel = InferenceModel(context, options)
        } catch (e: Exception) {
            inferenceModel?.close()
            throw CallError.CreateModel(e)
        }
    }

    private fun handleCreateSession(call: MethodCall) {
        try {
            val inference = checkNotNull(inferenceModel?.inference) { "Inference model is not created" }
            val arguments = checkNotNull(call.arguments as? Map<*, *>) { "Invalid arguments format" }
            val backend = LlmInferenceBackend(
                inference,
                InferenceSessionOptions.fromArgs(arguments).build(),
                GemmaFormatter()
            )
            val generativeModel = GenerativeModel(
                backend,
                systemInstruction ?: Content.getDefaultInstance(),
                tools,
            )
            session?.close()
            session = generativeModel.startChat()
        } catch (e: Exception) {
            throw CallError.CreateSession(e)
        }
    }

    private fun handleSetTools(call: MethodCall) {
        try {
            val toolBytesList = checkNotNull(call.argument<List<ByteArray>>("tools")) { "Missing tools" }
            tools = toolBytesList.map { Tool.parseFrom(it) }
        } catch (e: Exception) {
            throw CallError.SetTools(e)
        }
    }

    private fun handleSetSystemInstruction(call: MethodCall) {
        try {
            val argument = checkNotNull(call.argument<ByteArray>("systemInstruction")) { "Missing systemInstruction" }
            systemInstruction = Content.parseFrom(argument)
        } catch (e: Exception) {
            throw CallError.SetSystemInstruction(e)
        }
    }

    private fun handleCloneSession() {
        try {
            val session = checkNotNull(session) { "Session is not created" }
            this.session = session.clone()
        } catch (e: Exception) {
            throw CallError.CloneSession(e)
        }
    }

    private fun handleEnableConstraint(call: MethodCall) {
        try {
            val session = checkNotNull(session) { "Session is not created" }
            val constraintsBytes = checkNotNull(call.argument<ByteArray>("constraints")) { "Missing constraints" }
            val constraintOptions = ConstraintOptions.parseFrom(constraintsBytes)
            session.enableConstraint(constraintOptions)
        } catch (e: Exception) {
            throw CallError.EnableConstraint(e)
        }
    }

    private fun handleDisableConstraint() {
        try {
            val session = checkNotNull(session) { "Session is not created" }
            session.disableConstraint()
        } catch (e: Exception) {
            throw CallError.DisableConstraint(e)
        }
    }

    private fun handleSendMessage(call: MethodCall): ByteArray {
        return try {
            val session = checkNotNull(session) { "Session is not created" }
            val argument = checkNotNull(call.argument<ByteArray>("message")) { "Missing message" }
            val message = Content.parseFrom(argument)
            val response = session.sendMessage(message)
            response.toByteArray()
        } catch (e: Exception) {
            throw CallError.SendMessage(e)
        }
    }

    private fun handleGetHistory(): List<ByteArray> {
        return try {
            val session = checkNotNull(session) { "Session is not created" }
            session.history.map { it.toByteArray() }
        } catch (e: Exception) {
            throw CallError.GetHistory(e)
        }
    }

    private fun handleGetLast(): ByteArray? {
        return try {
            val session = checkNotNull(session) { "Session is not created" }
            session.last?.toByteArray()
        } catch (e: Exception) {
            throw CallError.GetLast(e)
        }
    }

    private fun handleClose() {
        try {
            session?.close()
        } catch (e: IllegalStateException) {
            // Session is still processing, ignore the error
            Log.w("AiEdgeFcPlugin", "Session close failed: ${e.message}")
        }
        session = null

        inferenceModel?.close()
        inferenceModel = null

        tools = emptyList()
        systemInstruction = null
    }
}
