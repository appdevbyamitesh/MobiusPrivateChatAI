import Foundation

final class SecurityManager {
    func sanitizeInput(_ input: String) -> String {
        return input.replacingOccurrences(of: "javascript:", with: "")
            .replacingOccurrences(of: "<script>", with: "")
            .replacingOccurrences(of: "</script>", with: "")
    }
}


