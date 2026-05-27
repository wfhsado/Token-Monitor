import Foundation
import SwiftUI

@MainActor
class TokenViewModel: ObservableObject {
    @Published var balance: BalanceInfo?
    @Published var usageStats: UsageStats?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let tokenService = TokenService.shared
    private let keychainService = KeychainService.shared

    func fetchBalance(for platform: Platform) async {
        guard let apiKey = keychainService.get(for: platform) else {
            balance = nil
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            switch platform {
            case .deepseek:
                balance = try await tokenService.fetchDeepSeekBalance(apiKey: apiKey)
            case .mimo:
                balance = try await tokenService.fetchMimoBalance(apiKey: apiKey)
            }
        } catch {
            errorMessage = "获取余额失败: \(error.localizedDescription)"
            print("获取余额失败: \(error)")
        }

        isLoading = false
    }

    func saveApiKey(_ key: String, for platform: Platform) {
        keychainService.save(key, for: platform)
    }

    func getApiKey(for platform: Platform) -> String? {
        return keychainService.get(for: platform)
    }

    func deleteApiKey(for platform: Platform) {
        keychainService.delete(for: platform)
        balance = nil
    }
}
