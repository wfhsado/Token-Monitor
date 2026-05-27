# Token监控 Android版

一个Android应用，通过**通知栏常驻通知**实时显示AI平台的Token余额信息。

**适用场景**：所有安卓手机，包括不支持小组件的设备。

## 功能特性

- ✅ 通知栏常驻通知显示余额
- ✅ 支持DeepSeek和小米MiMo平台
- ✅ 快捷刷新和停止按钮
- ✅ API Key加密存储
- ✅ 开机自启
- ✅ 前台服务保活

## 通知栏效果

```
┌─────────────────────────────────────┐
│  💰 DeepSeek Token余额              │
│  余额: 4.50 CNY | 正常              │
│  [刷新]  [停止监控]                  │
└─────────────────────────────────────┘
```

## 系统要求

- Android 8.0 (API 26) 或更高版本
- 需要通知权限

## 安装方式

### 方式一：使用Android Studio编译

1. 下载并安装 [Android Studio](https://developer.android.com/studio)

2. 打开项目：
   ```
   File -> Open -> 选择 TokenMonitorAndroid 文件夹
   ```

3. 等待Gradle同步完成

4. 连接手机或启动模拟器

5. 点击运行按钮 ▶️

### 方式二：直接安装APK

如果我已为你编译好APK：
1. 将APK文件传输到手机
2. 在手机上打开文件管理器
3. 找到APK文件并点击安装
4. 如果提示"未知来源"，需要在设置中允许

## 使用说明

### 第一步：配置API Key

1. 打开应用
2. 选择平台（DeepSeek或小米MiMo）
3. 输入API Key
4. 点击"保存"

### 第二步：启动监控

1. 点击"开始监控"按钮
2. 授予通知权限（首次会弹出）
3. 通知栏将显示余额信息

### 第三步：使用通知栏

- **查看余额**：下拉通知栏即可看到
- **刷新数据**：点击通知栏的"刷新"按钮
- **停止监控**：点击通知栏的"停止监控"按钮

## 获取API Key

### DeepSeek
1. 访问 https://platform.deepseek.com
2. 注册/登录账号
3. 进入API Keys页面
4. 创建新的API Key

### 小米MiMo
1. 访问小米AI开放平台
2. 注册开发者账号
3. 获取API Key

## 项目结构

```
TokenMonitorAndroid/
├── app/
│   ├── src/main/
│   │   ├── java/com/tokenmonitor/android/
│   │   │   ├── MainActivity.kt           # 主界面
│   │   │   ├── model/
│   │   │   │   ├── Platform.kt           # 平台枚举
│   │   │   │   └── BalanceInfo.kt        # 余额数据模型
│   │   │   ├── service/
│   │   │   │   ├── TokenApiService.kt    # API调用服务
│   │   │   │   └── TokenMonitorService.kt # 前台服务
│   │   │   ├── receiver/
│   │   │   │   └── BootReceiver.kt       # 开机广播
│   │   │   └── util/
│   │   │       └── PreferenceManager.kt  # 偏好设置管理
│   │   ├── res/
│   │   │   ├── layout/
│   │   │   │   └── activity_main.xml     # 主界面布局
│   │   │   ├── drawable/                 # 图标资源
│   │   │   └── values/                   # 字符串、颜色、主题
│   │   └── AndroidManifest.xml           # 应用配置
│   └── build.gradle.kts                  # 应用级构建配置
├── build.gradle.kts                      # 项目级构建配置
├── settings.gradle.kts                   # 项目设置
└── README.md                             # 说明文档
```

## 技术实现

### 通知栏常驻通知

使用Android的**前台服务 (Foreground Service)** 实现：

1. **前台服务**：确保应用不会被系统杀死
2. **常驻通知**：在通知栏持续显示余额信息
3. **定时刷新**：每30分钟自动更新数据
4. **快捷操作**：通知栏提供刷新和停止按钮

### API Key安全

使用 **EncryptedSharedPreferences** 加密存储API Key：
- AES-256加密
- 存储在应用私有目录
- 其他应用无法访问

### 开机自启

通过 **BroadcastReceiver** 监听开机广播：
- 用户启用监控后，开机自动启动服务
- 无需手动打开应用

## 常见问题

### Q: 通知栏不显示怎么办？
A: 
1. 检查是否授予通知权限
2. 在系统设置中找到应用，确保"允许通知"已开启
3. 某些手机需要在"自启动管理"中允许自启动

### Q: 应用被系统杀死怎么办？
A: 
1. 在系统设置中将应用加入"电池优化白名单"
2. 在"自启动管理"中允许自启动
3. 在"后台运行"中允许后台运行

### Q: 不同手机的设置路径不同？
A: 常见设置路径：
- **小米/红米**：设置 -> 应用设置 -> 应用管理 -> 找到应用 -> 自启动/后台运行
- **华为/荣耀**：设置 -> 应用 -> 应用启动管理 -> 找到应用
- **OPPO/realme**：设置 -> 应用管理 -> 找到应用 -> 自启动/后台运行
- **vivo/iQOO**：设置 -> 应用与权限 -> 权限管理 -> 自启动

### Q: 如何更新API Key？
A: 打开应用，选择平台，输入新的API Key，点击保存即可。

## 隐私说明

- API Key仅存储在本地设备
- 不收集任何个人信息
- 不上传任何数据到第三方服务器
- 仅在用户授权时访问网络查询余额

## 许可证

MIT License
