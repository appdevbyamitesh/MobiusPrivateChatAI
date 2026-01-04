import Foundation
import CoreML

struct DeviceCapabilities: Equatable {
    var hasNeuralEngine: Bool
    var cpuCores: Int
    var estimatedUsableRAMMB: Int
    var osMajorVersion: Int
}

enum DeviceCapabilitiesDetector {
    static func detect() -> DeviceCapabilities {
        let processInfo = ProcessInfo.processInfo
        let os = processInfo.operatingSystemVersion
        let osMajor = os.majorVersion

        let config = MLModelConfiguration()
        let hasNE = config.computeUnits != .cpuOnly

        let cores = processInfo.processorCount
        let ramBytes = processInfo.physicalMemory
        // Heuristic: assume ~35% available for model under typical load
        let usableMB = Int((Double(ramBytes) * 0.35) / (1024.0 * 1024.0))

        return DeviceCapabilities(
            hasNeuralEngine: hasNE,
            cpuCores: cores,
            estimatedUsableRAMMB: max(usableMB, 512),
            osMajorVersion: osMajor
        )
    }
}


