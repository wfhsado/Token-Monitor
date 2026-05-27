# Token监控 iOS小组件

一个iOS应用和小组件，用于实时监控AI平台的Token余额和使用情况。

## 功能特性

- 支持多个AI平台（DeepSeek、小米MiMo）
- 实时显示Token余额
- iOS小组件支持（小、中、大三种尺寸）
- 安全存储API Key（使用Keychain）
- 自动刷新数据

## 支持的平台

### DeepSeek
- API端点：`https://api.deepseek.com/user/balance`
- 获取API Key：https://platform.deepseek.com

### 小米MiMo
- 需要确认具体的API端点
- 请在对应平台获取API Key

## 项目结构

```
TokenMonitor/
├── TokenMonitor/              # 主应用
│   ├── TokenMonitorApp.swift  # 应用入口
│   ├── ContentView.swift      # 主界面
│   ├── TokenService.swift     # API服务
│   ├── KeychainService.swift  # Keychain存储
│   ├── TokenViewModel.swift   # 视图模型
│   └── Info.plist
├── TokenWidget/               # 小组件扩展
│   ├── TokenWidget.swift      # 小组件视图
│   ├── TokenWidgetBundle.swift
│   └── Info.plist
└── TokenMonitor.xcodeproj     # Xcode项目文件
```

## 安装和使用

### 1. 使用Xcode打开项目

```bash
open TokenMonitor.xcodeproj
```

### 2. 配置开发者账号

在Xcode中：
1. 选择项目 -> Signing & Capabilities
2. 选择你的开发者Team
3. 修改Bundle Identifier为唯一的标识符

### 3. 运行应用

1. 选择目标设备或模拟器
2. 按 `Cmd + R` 运行
3. 在设置中输入你的API Key

### 4. 添加小组件

1. 长按主屏幕空白处
2. 点击左上角的 "+" 按钮
3. 搜索 "Token监控"
4. 选择合适的小组件尺寸
5. 点击 "添加小组件"

## 小组件尺寸

- **小尺寸**：显示余额和状态
- **中尺寸**：显示平台信息和余额
- **大尺寸**：显示完整的余额和状态信息

## API说明

### DeepSeek API

查询余额：
```bash
curl https://api.deepseek.com/user/balance \
  -H "Authorization: Bearer YOUR_API_KEY"
```

响应示例：
```json
{
  "is_available": true,
  "balance": "4.50",
  "currency": "CNY",
  "total_balance": "10.00"
}
```

## 注意事项

1. **API Key安全**：API Key存储在iOS Keychain中，安全可靠
2. **网络权限**：应用需要网络权限来查询API
3. **刷新频率**：小组件默认每30分钟刷新一次
4. **小米MiMo**：API端点需要根据实际情况调整

## 扩展支持

如需添加其他AI平台，可以：

1. 在 `Platform` 枚举中添加新平台
2. 在 `TokenService` 中实现对应的API调用
3. 在 `ContentView` 中添加平台选择

## 系统要求

- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

## 许可证

MIT License
