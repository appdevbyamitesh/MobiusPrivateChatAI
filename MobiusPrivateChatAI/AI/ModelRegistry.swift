import Foundation

/// Describes an on-device language model packaged for Core ML
struct ModelDescriptor: Identifiable, Equatable {
    enum Quantization: String {
        case int4
        case int8
        case float16
    }

    let id: UUID
    let name: String
    let identifier: String
    let sizeMB: Double
    let quantization: Quantization
    let maxContextTokens: Int
    let minimumSupportedOSMajor: Int
    let notes: String

    init(
        name: String,
        identifier: String,
        sizeMB: Double,
        quantization: Quantization,
        maxContextTokens: Int,
        minimumSupportedOSMajor: Int,
        notes: String
    ) {
        self.id = UUID()
        self.name = name
        self.identifier = identifier
        self.sizeMB = sizeMB
        self.quantization = quantization
        self.maxContextTokens = maxContextTokens
        self.minimumSupportedOSMajor = minimumSupportedOSMajor
        self.notes = notes
    }
}

/// Registry of supported models for dynamic selection at runtime
enum ModelRegistry {
    static let phi3Mini: ModelDescriptor = .init(
        name: "Phi-3-mini-4k (Quantized)",
        identifier: "phi3-mini-4k-int8",
        sizeMB: 650,
        quantization: .int8,
        maxContextTokens: 4096,
        minimumSupportedOSMajor: 15,
        notes: "Default model for broad device coverage; fast and lightweight."
    )

    static let mistral7B: ModelDescriptor = .init(
        name: "Mistral-7B-Instruct (Quantized)",
        identifier: "mistral-7b-instruct-int4",
        sizeMB: 2450,
        quantization: .int4,
        maxContextTokens: 8192,
        minimumSupportedOSMajor: 16,
        notes: "High-end devices; better quality, larger context window."
    )

    static let all: [ModelDescriptor] = [phi3Mini, mistral7B]
}


