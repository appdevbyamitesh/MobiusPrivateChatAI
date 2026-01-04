import Foundation

struct Embedding: Equatable {
    let vector: [Float]
}

final class EmbeddingsService {
    func embed(text: String) async throws -> Embedding {
        // Placeholder: replace with Core ML embedding model inference
        let tokens = text.split(separator: " ")
        let vector = tokens.map { _ in Float.random(in: -0.1...0.1) }
        return Embedding(vector: vector)
    }

    static func cosineSimilarity(_ a: Embedding, _ b: Embedding) -> Float {
        let minCount = min(a.vector.count, b.vector.count)
        guard minCount > 0 else { return 0 }
        var dot: Float = 0
        var aNorm: Float = 0
        var bNorm: Float = 0
        for i in 0..<minCount {
            let av = a.vector[i]
            let bv = b.vector[i]
            dot += av * bv
            aNorm += av * av
            bNorm += bv * bv
        }
        let denom = (sqrt(aNorm) * sqrt(bNorm))
        return denom > 0 ? dot / denom : 0
    }
}


