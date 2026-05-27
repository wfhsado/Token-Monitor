import Foundation
import SwiftUI

// MARK: - 平台枚举
enum Platform: String, CaseIterable, Identifiable {
    case deepseek
    case mimo

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .deepseek: return "DeepSeek"
        case .mimo: return "小米MiMo"
        }
    }

    var iconName: String {
        switch self {
        case .deepseek: return "brain.head.profile"
        case .mimo: return "cpu"
        }
    }

    var color: Color {
        switch self {
        case .deepseek: return .blue
        case .mimo: return .orange
        }
    }
}

// MARK: - 余额信息
struct BalanceInfo {
    let isAvailable: Bool
    let balance: Double
    let totalBalance: Double
    let currency: String

    var formattedBalance: String {
        return String(format: "%.2f", balance)
    }
}

// MARK: - 使用统计
struct UsageStats {
    let todayCalls: Int
    let todayTokens: Int
    let monthTokens: Int
}

// MARK: - Token服务
class TokenService {
    static let shared = TokenService()

    private let deepseekBaseUrl = "https://api.deepseek.com"

    // DeepSeek余额查询
    func fetchDeepSeekBalance(apiKey: String) async throws -> BalanceInfo {
        guard let url = URL(string: "\(deepseekBaseUrl)/user/balance") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

        let isAvailable = json["is_available"] as? Bool ?? false
        let balanceStr = json["balance"] as? String ?? "0"
        let totalBalanceStr = json["total_balance"] as? String ?? "0"
        let currency = json["currency"] as? String ?? "CNY"

        return BalanceInfo(
            isAvailable: isAvailable,
            balance: Double(balanceStr) ?? 0,
            totalBalance: Double(totalBalanceStr) ?? 0,
            currency: currency
        )
    }

    // MiMo余额查询（需要根据实际API调整）
    func fetchMimoBalance(apiKey: String) async throws -> BalanceInfo {
        // 注意：小米MiMo的API接口需要根据实际情况调整
        // 这里假设一个通用的接口格式
        guard let url = URL(string: "https://api.mimo.xiaomi.com/user/balance") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

        let isAvailable = json["is_available"] as? Bool ?? false
        let balanceStr = json["balance"] as? String ?? "0"
        let totalBalanceStr = json["total_balance"] as? String ?? "0"
        let currency = json["currency"] as? String ?? "CNY"

        return BalanceInfo(
            isAvailable: isAvailable,
            balance: Double(balanceStr) ?? 0,
            totalBalance: Double(totalBalanceStr) ?? 0,
            currency: currency
        )
    }
}
