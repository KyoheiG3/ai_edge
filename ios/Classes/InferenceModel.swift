import MediaPipeTasksGenAI

// MARK: - InferenceModel
struct InferenceModel {
    private(set) var inference: LlmInference

    init(
        modelPath: String,
        maxTokens: Int,
        supportedLoraRanks: [Int]?,
        maxNumImages: Int?
    ) throws {
        guard FileManager.default.fileExists(atPath: modelPath) else {
            throw NSError(
                domain: "InferenceModel", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Model file not found: \(modelPath)"])
        }

        let llmOptions = LlmInference.Options(modelPath: modelPath)
        llmOptions.maxTokens = maxTokens
        llmOptions.waitForWeightUploads = true

        if let supportedLoraRanks {
            llmOptions.supportedLoraRanks = supportedLoraRanks
        }

        if let maxNumImages, maxNumImages > 0 {
            llmOptions.maxImages = maxNumImages
        }

        inference = try LlmInference(options: llmOptions)
    }
}

// MARK: - InferenceSession
final class InferenceSession {
    private let session: LlmInference.Session

    init(
        inference: LlmInference,
        temperature: Float,
        randomSeed: Int,
        topk: Int,
        topP: Double?,
        loraPath: String?,
        enableVisionModality: Bool?
    ) throws {
        let options = LlmInference.Session.Options()
        options.temperature = temperature
        options.randomSeed = randomSeed
        options.topk = topk

        if let topP {
            options.topp = Float(topP)
        }

        if let loraPath {
            options.loraPath = loraPath
        }

        options.enableVisionModality = enableVisionModality ?? false

        session = try LlmInference.Session(llmInference: inference, options: options)
    }

    func addQueryChunk(prompt: String) throws {
        try session.addQueryChunk(inputText: prompt)
    }

    func addImage(image: CGImage) throws {
        try session.addImage(image: image)
    }

    func generateResponse(prompt: String?) throws -> String {
        if let prompt {
            try session.addQueryChunk(inputText: prompt)
        }
        return try session.generateResponse()
    }

    func generateResponseAsync(prompt: String?) throws -> AsyncThrowingStream<
        String, any Error
    > {
        if let prompt {
            try session.addQueryChunk(inputText: prompt)
        }

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await partialResult in session.generateResponseAsync() {
                        continuation.yield(partialResult)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
