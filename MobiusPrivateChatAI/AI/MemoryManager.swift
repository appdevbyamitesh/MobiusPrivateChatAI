import Foundation

final class MemoryManager {
    private var registeredBytes: Int = 0
    private let maxUsageRatio: Double = 0.8

    func register(bytes: Int) {
        registeredBytes += bytes
    }

    func clearIfNeeded() {
        let total = ProcessInfo.processInfo.physicalMemory
        let threshold = Int(Double(total) * maxUsageRatio)
        if registeredBytes > threshold {
            registeredBytes = 0
        }
    }
}


