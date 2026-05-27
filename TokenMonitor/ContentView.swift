import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TokenViewModel()
    @State private var showingApiKeySheet = false
    @State private var selectedPlatform: Platform = .deepseek

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 平台选择器
                Picker("选择平台", selection: $selectedPlatform) {
                    ForEach(Platform.allCases) { platform in
                        Text(platform.displayName).tag(platform)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // 余额卡片
                BalanceCardView(
                    platform: selectedPlatform,
                    balance: viewModel.balance,
                    isLoading: viewModel.isLoading
                )

                // 使用统计
                if let usage = viewModel.usageStats {
                    UsageStatsView(stats: usage)
                }

                Spacer()

                // 刷新按钮
                Button(action: {
                    Task {
                        await viewModel.fetchBalance(for: selectedPlatform)
                    }
                }) {
                    Label("刷新数据", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Token监控")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingApiKeySheet = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingApiKeySheet) {
                ApiKeySettingsView(viewModel: viewModel)
            }
            .task {
                await viewModel.fetchBalance(for: selectedPlatform)
            }
        }
    }
}

// MARK: - 余额卡片视图
struct BalanceCardView: View {
    let platform: Platform
    let balance: BalanceInfo?
    let isLoading: Bool

    var body: some View {
        VStack(spacing: 16) {
            // 平台图标和名称
            HStack {
                Image(systemName: platform.iconName)
                    .font(.title2)
                    .foregroundColor(platform.color)
                Text(platform.displayName)
                    .font(.headline)
                Spacer()
            }

            if isLoading {
                ProgressView()
                    .frame(height: 80)
            } else if let balance = balance {
                // 余额显示
                VStack(spacing: 8) {
                    Text("可用余额")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(balance.formattedBalance)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(balance.isAvailable ? .primary : .red)
                    Text(balance.currency)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 80)

                // 状态指示
                HStack {
                    Circle()
                        .fill(balance.isAvailable ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(balance.isAvailable ? "正常" : "余额不足")
                        .font(.caption)
                        .foregroundColor(balance.isAvailable ? .green : .red)
                    Spacer()
                }
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundColor(.orange)
                    Text("未配置API Key")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 80)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

// MARK: - 使用统计视图
struct UsageStatsView: View {
    let stats: UsageStats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("使用统计")
                .font(.headline)

            HStack(spacing: 20) {
                StatItem(title: "今日调用", value: "\(stats.todayCalls)")
                StatItem(title: "今日Token", value: formatNumber(stats.todayTokens))
                StatItem(title: "本月Token", value: formatNumber(stats.monthTokens))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }

    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000)
        }
        return "\(number)"
    }
}

// MARK: - 统计项
struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - API Key 设置视图
struct ApiKeySettingsView: View {
    @ObservedObject var viewModel: TokenViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var deepseekApiKey = ""
    @State private var mimoApiKey = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("DeepSeek API Key")) {
                    SecureField("输入API Key", text: $deepseekApiKey)
                    Button("保存") {
                        viewModel.saveApiKey(deepseekApiKey, for: .deepseek)
                    }
                }

                Section(header: Text("小米MiMo API Key")) {
                    SecureField("输入API Key", text: $mimoApiKey)
                    Button("保存") {
                        viewModel.saveApiKey(mimoApiKey, for: .mimo)
                    }
                }

                Section(header: Text("说明")) {
                    Text("DeepSeek API Key可在 platform.deepseek.com 获取")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("小米MiMo API Key请在对应平台获取")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("API设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                deepseekApiKey = viewModel.getApiKey(for: .deepseek) ?? ""
                mimoApiKey = viewModel.getApiKey(for: .mimo) ?? ""
            }
        }
    }
}

#Preview {
    ContentView()
}
