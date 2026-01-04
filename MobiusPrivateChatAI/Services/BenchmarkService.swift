import Foundation

final class BenchmarkService {
    private let modelManager: CoreMLModelManager

    init(modelManager: CoreMLModelManager) {
        self.modelManager = modelManager
    }

    func runQuickBenchmark() async -> BenchmarkResult {
        let prompt = "Benchmark test prompt for on-device inference."
        let start = CFAbsoluteTimeGetCurrent()
        var tokenCount = 0
        for await _ in await modelManager.generateStream(for: prompt) {
            tokenCount += 1
        }
        let end = CFAbsoluteTimeGetCurrent()
        let elapsedMs = (end - start) * 1000.0
        let tps = elapsedMs > 0 ? (Double(tokenCount) / (elapsedMs / 1000.0)) : 0
        return BenchmarkResult(
            testName: "Quick Benchmark",
            responseTime: elapsedMs,
            tokensPerSecond: tps,
            success: true,
            timestamp: Date()
        )
    }
}


