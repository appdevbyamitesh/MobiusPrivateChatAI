import Foundation

struct IndexedDocument: Identifiable, Equatable {
    let id: UUID
    let text: String
    let embedding: Embedding
    let createdAt: Date
}

final class SmartSearchService {
    private let embeddings: EmbeddingsService
    private var index: [IndexedDocument] = []

    init(embeddings: EmbeddingsService = EmbeddingsService()) {
        self.embeddings = embeddings
    }

    func addDocument(text: String) async throws {
        let emb = try await embeddings.embed(text: text)
        let doc = IndexedDocument(id: UUID(), text: text, embedding: emb, createdAt: Date())
        index.append(doc)
    }

    func topK(query: String, k: Int = 3) async throws -> [IndexedDocument] {
        let q = try await embeddings.embed(text: query)
        let scored = index.map { doc in
            (doc, EmbeddingsService.cosineSimilarity(q, doc.embedding))
        }
        return scored.sorted { $0.1 > $1.1 }.prefix(k).map { $0.0 }
    }
}


