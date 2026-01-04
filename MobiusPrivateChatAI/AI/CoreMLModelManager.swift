import Foundation
import CoreML

@MainActor
final class CoreMLModelManager: ObservableObject {
    enum State: Equatable {
        case notLoaded
        case loading(progress: Double)
        case ready(model: ModelDescriptor)
        case processing
        case error(String)
    }

    @Published private(set) var state: State = .notLoaded
    @Published private(set) var activeModel: ModelDescriptor? = nil

    private var mlModel: MLModel? = nil
    private var configuration: MLModelConfiguration = {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        config.allowLowPrecisionAccumulationOnGPU = true
//        config.allowBackgroundCompute = false
        return config
    }()

    func load(model descriptor: ModelDescriptor, at url: URL) async {
        state = .loading(progress: 0)
        do {
            let model = try await MLModel.load(contentsOf: url, configuration: configuration)
            self.mlModel = model
            self.activeModel = descriptor
            self.state = .ready(model: descriptor)
        } catch {
            self.state = .error("Failed to load model: \(error.localizedDescription)")
        }
    }

    /// Simple prewarm by running a tiny dummy request if supported by the model
    func prewarmIfNeeded() async {
        guard mlModel != nil else { return }
        // Placeholder: some models benefit from a warmup pass; keep no-op for now
    }

    /// Streams tokens as text fragments; actual implementation will call model prediction per step
    func generateStream(for prompt: String) -> AsyncStream<String> {
        return AsyncStream { continuation in
            Task {
                await MainActor.run { self.state = .processing }
                // Placeholder tokenization and streaming simulation
                let words = prompt.split(separator: " ")
                for word in words {
                    continuation.yield(String(word))
                    try? await Task.sleep(nanoseconds: 40_000_000)
                }
                continuation.finish()
                await MainActor.run { self.state = self.activeModel != nil ? .ready(model: self.activeModel!) : .notLoaded }
            }
        }
    }
}


