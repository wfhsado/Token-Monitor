# Token监控 - AI平台Token余额实时监控

一个跨平台的Token余额监控应用，支持 **iOS** 和 **Android**，可实时显示DeepSeek、小米MiMo等AI平台的Token余额。

## 📱 平台支持

| 平台 | 显示方式 | 兼容性 |
|------|---------|--------|
| **iOS** | 桌面小组件（小/中/大） | iOS 16.0+ |
| **Android** | 通知栏常驻通知 | Android 8.0+ (所有手机) |

## ✨ 功能特性

- ✅ 支持多个AI平台（DeepSeek、小米MiMo）
- ✅ 实时显示Token余额
- ✅ 安全存储API Key
- ✅ 自动刷新数据
- ✅ 支持开机自启（Android）

---

## 📂 项目结构

```
TokenMonitor/
├── iOS/                        # iOS版本
│   ├── TokenMonitor/           # 主应用
│   ├── TokenWidget/            # 小组件扩展
│   ├── TokenMonitor.xcodeproj  # Xcode项目
│   ├── README.md               # iOS详细说明
│   └── 快速开始.md             # iOS快速指南
│
├── Android/                    # Android版本
│   ├── app/                    # 应用模块
│   ├── build.gradle.kts        # 构建配置
│   ├── README.md               # Android详细说明
│   └── ...
│
└── README.md                   # 本文件（项目总览）
```

---

## 🍎 iOS版本

### 显示方式
iOS小组件，支持三种尺寸：
- **小尺寸**：显示余额和状态
- **中尺寸**：显示平台信息和余额
- **大尺寸**：显示完整的余额和状态信息

### 系统要求
- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

### 快速开始
```bash
cd iOS
open TokenMonitor.xcodeproj
```

详细说明请查看 [iOS/README.md](iOS/README.md)

---

## 🤖 Android版本

### 显示方式
通知栏常驻通知：
- 下拉通知栏即可查看余额
- 提供快捷刷新和停止按钮
- 支持开机自启

### 优势
- **所有安卓手机都支持**，无需小组件功能
- 前台服务保活，稳定可靠
- API Key加密存储

### 系统要求
- Android 8.0 (API 26)+
- Android Studio (用于编译)

### 快速开始
```bash
cd Android
# 用Android Studio打开项目
```

详细说明请查看 [Android/README.md](Android/README.md)

---

## 🔑 获取API Key

### DeepSeek
1. 访问 https://platform.deepseek.com
2. 注册/登录账号
3. 进入API Keys页面
4. 创建新的API Key

### 小米MiMo
1. 访问小米AI开放平台
2. 注册开发者账号
3. 获取API Key

---

## 🔧 API说明

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

---

## 📊 iOS vs Android 对比

| 特性 | iOS小组件 | Android通知栏 |
|------|----------|--------------|
| 显示位置 | 桌面 | 通知栏 |
| 可见性 | 直接可见 | 需要下拉 |
| 兼容性 | iOS 16+ | 所有安卓 |
| 操作 | 点击打开App | 有快捷按钮 |
| 保活 | 系统管理 | 前台服务 |
| 电池影响 | 低 | 略高 |

---

## 🔒 安全说明

- API Key仅存储在本地设备
- iOS使用Keychain存储
- Android使用EncryptedSharedPreferences加密存储
- 不收集任何个人信息
- 不上传任何数据到第三方服务器

---

## 🛠️ 扩展支持

如需添加其他AI平台：

### iOS
1. 在 `Platform` 枚举中添加新平台
2. 在 `TokenService` 中实现API调用
3. 在 `ContentView` 中添加平台选择

### Android
1. 在 `Platform.kt` 枚举中添加新平台
2. 在 `TokenApiService.kt` 中实现API调用
3. 在 `MainActivity.kt` 中添加平台选择

---

## 📄 许可证

MIT License

---

## 🤝 贡献

欢迎提交Issue和Pull Request！

---

## 📧 联系方式

如有问题，请在GitHub上提交Issue。
