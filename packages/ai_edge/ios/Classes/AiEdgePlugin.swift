import Flutter
import MediaPipeTasksGenAI

private enum CallError: Error {
    case unknown(String)
    case createModel(String)
    case createSession(String)
    case addQueryChunk(String)
    case addImage(String)
    case generateResponse(String)
    case generateResponseAsync(String)

    var code: String {
        switch self {
        case .unknown: "UNKNOWN_ERROR"
        case .createModel: "CREATE_MODEL_ERROR"
        case .createSession: "CREATE_SESSION_ERROR"
        case .addQueryChunk: "ADD_QUERY_CHUNK_ERROR"
        case .addImage: "ADD_IMAGE_ERROR"
        case .generateResponse: "GENERATE_RESPONSE_ERROR"
        case .generateResponseAsync: "GENERATE_RESPONSE_ASYNC_ERROR"
        }
    }

    var message: String {
        switch self {
        case .unknown(let msg),
            .createModel(let msg),
            .createSession(let msg),
            .addQueryChunk(let msg),
            .addImage(let msg),
            .generateResponse(let msg),
            .generateResponseAsync(let msg):
            msg
        }
    }

    func toFlutterError() -> FlutterError {
        FlutterError(code: code, message: message, details: nil)
    }
}

public class AiEdgePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "ai_edge/methods",
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "ai_edge/events",
            binaryMessenger: registrar.messenger()
        )

        let instance = AiEdgePlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    private var eventSink: FlutterEventSink?
    private var inferenceModel: InferenceModel?
    private var session: InferenceSession?

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Task { @MainActor in
            do {
                let response =
                    switch call.method {
                    case "createModel":
                        try await handleCreateModel(call)
                    case "createSession":
                        try await handleCreateSession(call)
                    case "addQueryChunk":
                        try await handleAddQueryChunk(call)
                    case "addImage":
                        try await handleAddImage(call)
                    case "generateResponse":
                        try await handleGenerateResponse(call)
                    case "generateResponseAsync":
                        try await handleGenerateResponseAsync(call)
                    case "close":
                        await handleClose()
                    default:
                        FlutterMethodNotImplemented
                    }
                result(response as? String)
            } catch let error as CallError {
                result(error.toFlutterError())
            } catch {
                let error = CallError.unknown(error.localizedDescription)
                result(error.toFlutterError())
            }
        }
    }

    private func handleCreateModel(_ call: FlutterMethodCall) async throws {
        guard let args = call.arguments as? [String: Any],
            let modelPath = args["modelPath"] as? String,
            let maxTokens = args["maxTokens"] as? Int
        else {
            throw CallError.createModel("Missing modelPath or maxTokens")
        }

        let loraRanks = args["loraRanks"] as? [Int]
        let maxNumImages = args["maxNumImages"] as? Int

        do {
            inferenceModel = try InferenceModel(
                modelPath: modelPath,
                maxTokens: maxTokens,
                supportedLoraRanks: loraRanks,
                maxNumImages: maxNumImages
            )
        } catch {
            throw CallError.createModel(error.localizedDescription)
        }
    }

    private func handleCreateSession(_ call: FlutterMethodCall) async throws {
        guard let inference = inferenceModel?.inference else {
            throw CallError.createSession("Inference model is not created")
        }

        guard let args = call.arguments as? [String: Any],
            let temperature = args["temperature"] as? Double,
            let randomSeed = args["randomSeed"] as? Int,
            let topK = args["topK"] as? Int
        else {
            throw CallError.createSession("Missing temperature, randomSeed or topK")
        }

        let topP = args["topP"] as? Double
        let loraPath = args["loraPath"] as? String
        let enableVisionModality = args["enableVisionModality"] as? Bool

        do {
            session = try InferenceSession(
                inference: inference,
                temperature: Float(temperature),
                randomSeed: randomSeed,
                topk: topK,
                topP: topP,
                loraPath: loraPath,
                enableVisionModality: enableVisionModality
            )
        } catch {
            throw CallError.createSession(error.localizedDescription)
        }
    }

    private func handleAddQueryChunk(_ call: FlutterMethodCall) async throws {
        guard let session else {
            throw CallError.addQueryChunk("Session not created")
        }

        guard let args = call.arguments as? [String: Any],
            let prompt = args["prompt"] as? String
        else {
            throw CallError.addQueryChunk("Missing prompt")
        }

        do {
            try session.addQueryChunk(prompt: prompt)
        } catch {
            throw CallError.addQueryChunk(error.localizedDescription)
        }
    }

    private func handleAddImage(_ call: FlutterMethodCall) async throws {
        guard let session else {
            throw CallError.addImage("Session not created")
        }

        guard let args = call.arguments as? [String: Any],
            let imageBytes = args["imageBytes"] as? FlutterStandardTypedData
        else {
            throw CallError.addImage("Missing imageBytes")
        }

        guard let cgImage = UIImage(data: imageBytes.data)?.cgImage else {
            throw CallError.addImage("Could not create image from data")
        }

        do {
            try session.addImage(image: cgImage)
        } catch {
            throw CallError.addImage(error.localizedDescription)
        }
    }

    private func handleGenerateResponse(_ call: FlutterMethodCall) async throws -> String {
        guard let session else {
            throw CallError.generateResponse("Session not created")
        }
        let args = call.arguments as? [String: String]

        do {
            return try session.generateResponse(prompt: args?["prompt"])
        } catch {
            throw CallError.generateResponse(error.localizedDescription)
        }
    }

    private func handleGenerateResponseAsync(_ call: FlutterMethodCall) async throws {
        guard let session else {
            throw CallError.generateResponseAsync("Session not created")
        }

        guard let eventSink else {
            throw CallError.generateResponseAsync("Event sink not created")
        }

        @MainActor
        func sink(_ event: Any) {
            eventSink(event)
        }

        do {
            let args = call.arguments as? [String: String]
            let stream = try session.generateResponseAsync(prompt: args?["prompt"])
            Task.detached {
                do {
                    for try await token in stream {
                        await sink(["partialResult": token, "done": false])
                    }
                    await sink(["partialResult": "", "done": true])
                    await sink(FlutterEndOfEventStream)
                } catch {
                    let error = CallError.generateResponseAsync(error.localizedDescription)
                    await sink(error.toFlutterError())
                }
            }
        } catch {
            throw CallError.generateResponseAsync(error.localizedDescription)
        }
    }

    private func handleClose() async -> Any? {
        session = nil
        inferenceModel = nil
        return nil
    }
}

// MARK: - FlutterStreamHandler
extension AiEdgePlugin: FlutterStreamHandler {
    public func onListen(
        withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
