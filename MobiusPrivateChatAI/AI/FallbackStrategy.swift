import Foundation

enum FallbackStrategy {
    struct Selection: Equatable {
        let model: ModelDescriptor
        let targetContextTokens: Int
    }

    static func selectModel(for capabilities: DeviceCapabilities) -> Selection {
        // Prefer Mistral if OS and memory allow, else Phi-3-mini
        let canRunMistral = capabilities.osMajorVersion >= ModelRegistry.mistral7B.minimumSupportedOSMajor
            && capabilities.estimatedUsableRAMMB >= 3000

        if canRunMistral {
            return Selection(model: ModelRegistry.mistral7B, targetContextTokens: min(4096, ModelRegistry.mistral7B.maxContextTokens))
        } else {
            // Default lightweight
            let target = min(2048, ModelRegistry.phi3Mini.maxContextTokens)
            return Selection(model: ModelRegistry.phi3Mini, targetContextTokens: target)
        }
    }
}


