import Foundation
import Security

// MARK: - Keychain服务
class KeychainService {
    static let shared = KeychainService()

    private let service = "com.tokenmonitor.apikeys"

    func save(_ key: String, for platform: Platform) {
        let data = key.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: platform.rawValue,
            kSecValueData as String: data
        ]

        // 删除旧的
        SecItemDelete(query as CFDictionary)

        // 添加新的
        SecItemAdd(query as CFDictionary, nil)
    }

    func get(for platform: Platform) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: platform.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }

        return key
    }

    func delete(for platform: Platform) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: platform.rawValue
        ]

        SecItemDelete(query as CFDictionary)
    }
}
