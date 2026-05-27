import WidgetKit
import SwiftUI

// MARK: - Timeline Provider
struct TokenTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> TokenEntry {
        TokenEntry(
            date: Date(),
            platform: .deepseek,
            balance: BalanceInfo(
                isAvailable: true,
                balance: 100.00,
                totalBalance: 200.00,
                currency: "CNY"
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TokenEntry) -> Void) {
        let entry = TokenEntry(
            date: Date(),
            platform: .deepseek,
            balance: BalanceInfo(
                isAvailable: true,
                balance: 100.00,
                totalBalance: 200.00,
                currency: "CNY"
            )
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TokenEntry>) -> Void) {
        Task {
            let entry = await fetchLatestEntry()
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    private func fetchLatestEntry() async -> TokenEntry {
        let keychainService = KeychainService.shared
        let tokenService = TokenService.shared

        // 尝试获取DeepSeek余额
        if let apiKey = keychainService.get(for: .deepseek) {
            do {
                let balance = try await tokenService.fetchDeepSeekBalance(apiKey: apiKey)
                return TokenEntry(date: Date(), platform: .deepseek, balance: balance)
            } catch {
                print("Widget获取DeepSeek余额失败: \(error)")
            }
        }

        // 尝试获取MiMo余额
        if let apiKey = keychainService.get(for: .mimo) {
            do {
                let balance = try await tokenService.fetchMimoBalance(apiKey: apiKey)
                return TokenEntry(date: Date(), platform: .mimo, balance: balance)
            } catch {
                print("Widget获取MiMo余额失败: \(error)")
            }
        }

        // 返回默认值
        return TokenEntry(
            date: Date(),
            platform: .deepseek,
            balance: nil
        )
    }
}

// MARK: - Timeline Entry
struct TokenEntry: TimelineEntry {
    let date: Date
    let platform: Platform
    let balance: BalanceInfo?
}

// MARK: - Widget View
struct TokenWidgetEntryView: View {
    var entry: TokenTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - 小尺寸小组件
struct SmallWidgetView: View {
    let entry: TokenEntry

    var body: some View {
        VStack(spacing: 8) {
            // 平台图标
            HStack {
                Image(systemName: entry.platform.iconName)
                    .foregroundColor(entry.platform.color)
                Text(entry.platform.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }

            if let balance = entry.balance {
                // 余额
                VStack(spacing: 4) {
                    Text("余额")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(balance.formattedBalance)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(balance.isAvailable ? .primary : .red)
                    Text(balance.currency)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                // 状态
                HStack {
                    Circle()
                        .fill(balance.isAvailable ? Color.green : Color.red)
                        .frame(width: 6, height: 6)
                    Text(balance.isAvailable ? "正常" : "不足")
                        .font(.caption2)
                    Spacer()
                }
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("未配置")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - 中尺寸小组件
struct MediumWidgetView: View {
    let entry: TokenEntry

    var body: some View {
        HStack(spacing: 16) {
            // 左侧：平台信息
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: entry.platform.iconName)
                        .foregroundColor(entry.platform.color)
                        .font(.title2)
                    Text(entry.platform.displayName)
                        .font(.headline)
                }

                if let balance = entry.balance {
                    HStack {
                        Circle()
                            .fill(balance.isAvailable ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(balance.isAvailable ? "服务正常" : "余额不足")
                            .font(.caption)
                            .foregroundColor(balance.isAvailable ? .green : .red)
                    }
                }
            }

            Spacer()

            // 右侧：余额
            if let balance = entry.balance {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("可用余额")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(balance.formattedBalance)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(balance.isAvailable ? .primary : .red)
                    Text(balance.currency)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack {
                    Image(systemName: "gearshape")
                        .font(.title)
                        .foregroundColor(.secondary)
                    Text("请配置API Key")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - 大尺寸小组件
struct LargeWidgetView: View {
    let entry: TokenEntry

    var body: some View {
        VStack(spacing: 16) {
            // 头部
            HStack {
                Image(systemName: entry.platform.iconName)
                    .foregroundColor(entry.platform.color)
                    .font(.title)
                Text(entry.platform.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text(entry.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let balance = entry.balance {
                // 余额卡片
                VStack(spacing: 12) {
                    Text("可用余额")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(balance.formattedBalance)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(balance.isAvailable ? .primary : .red)
                    Text(balance.currency)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // 状态信息
                HStack {
                    VStack(alignment: .leading) {
                        Text("状态")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Circle()
                                .fill(balance.isAvailable ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            Text(balance.isAvailable ? "正常" : "余额不足")
                                .font(.subheadline)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("总额度")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.2f", balance.totalBalance))
                            .font(.subheadline)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("请在App中配置API Key")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Configuration
struct TokenWidget: Widget {
    let kind: String = "TokenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TokenTimelineProvider()) { entry in
            TokenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Token监控")
        .description("实时显示AI平台Token余额")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    TokenWidget()
} timeline: {
    TokenEntry(
        date: Date(),
        platform: .deepseek,
        balance: BalanceInfo(
            isAvailable: true,
            balance: 100.00,
            totalBalance: 200.00,
            currency: "CNY"
        )
    )
}

#Preview(as: .systemMedium) {
    TokenWidget()
} timeline: {
    TokenEntry(
        date: Date(),
        platform: .deepseek,
        balance: BalanceInfo(
            isAvailable: true,
            balance: 100.00,
            totalBalance: 200.00,
            currency: "CNY"
        )
    )
}
