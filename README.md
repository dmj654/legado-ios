# Legado KMP - 开源阅读 iOS 移植版

基于 [gedoor/legado](https://github.com/gedoor/legado) 的 Kotlin Multiplatform 移植项目，目标是将 legado 的核心阅读引擎跨平台共享，并提供原生 iOS 客户端。

## 项目架构

```
legado-kmp/
├── shared/                    # KMP 共享模块（核心逻辑）
│   └── src/
│       ├── commonMain/        # 平台无关代码
│       │   └── kotlin/io/legado/
│       │       ├── LegadoSDK.kt          # SDK 入口
│       │       ├── core/                  # 核心组件
│       │       │   └── NetworkManager.kt # 网络请求（Ktor）
│       │       ├── data/
│       │       │   ├── entities/          # 数据实体
│       │       │   │   ├── BookSource.kt # 书源
│       │       │   │   ├── Book.kt       # 书籍
│       │       │   │   ├── BookChapter.kt# 章节
│       │       │   │   ├── SearchBook.kt # 搜索结果
│       │       │   │   └── rule/         # 书源规则
│       │       │   └── repository/        # 数据仓库
│       │       ├── domain/usecase/        # 领域用例
│       │       ├── model/
│       │       │   ├── analyzeRule/       # 规则解析引擎
│       │       │   └── webBook/           # 网络书源
│       │       └── utils/
│       ├── androidMain/       # Android 平台实现
│       └── iosMain/           # iOS 平台实现
├── iosApp/                    # iOS 原生应用（SwiftUI）
│   ├── Legado.xcodeproj/      # Xcode 工程
│   └── Legado/
│       ├── App/               # 应用入口
│       ├── Views/             # SwiftUI 视图
│       │   ├── ContentView.swift
│       │   ├── BookShelfView.swift
│       │   ├── BookSearchView.swift
│       │   ├── BookSourceManagerView.swift
│       │   ├── ReaderView.swift
│       │   └── SettingsView.swift
│       ├── Assets.xcassets/
│       └── Info.plist
└── .github/workflows/
    └── build-ios.yml          # CI：macOS runner 出未签名 ipa
```

## 技术栈

### 共享模块 (KMP)
- **Kotlin Multiplatform** - 跨平台共享代码
- **Ktor Client** - 跨平台网络请求（Android: OkHttp, iOS: Darwin）
- **kotlinx.serialization** - JSON 序列化
- **kotlinx.coroutines** - 异步编程
- **kotlinx.datetime** - 日期时间
- **SQLDelight** - 跨平台数据库（规划中）
- **Koin** - 依赖注入

### iOS 端
- **SwiftUI** - 声明式 UI
- **iOS 15.0+** 部署目标
- 支持 iPhone 和 iPad

## 已移植功能

- [x] 书源数据模型（BookSource + 全部规则类）
- [x] 书籍/章节/搜索结果数据模型
- [x] 规则解析引擎（CSS/XPath/JSONPath/Regex）
- [x] 网络书源获取（搜索/详情/目录/正文）
- [x] 书源管理（导入/启用/删除）
- [x] 跨平台网络层（Ktor）
- [x] iOS SwiftUI 完整界面（书架/搜索/书源/阅读/设置）
- [x] GitHub Actions CI 出未签名 ipa

## 待移植功能

- [ ] KMP framework 集成到 Xcode 工程（CocoaPods/SPM）
- [ ] SQLDelight 数据库持久化
- [ ] JS 引擎（书源 JS 规则执行）
- [ ] 本地书籍阅读（TXT/EPUB/UMD）
- [ ] TTS 朗读
- [ ] WebDAV 备份同步
- [ ] 发现页/分类
- [ ] 替换净化规则
- [ ] 阅读进度同步

## CI 构建未签名 IPA

项目配置了 GitHub Actions，推送到 main 分支后自动构建：

1. 使用 `macos-latest` runner
2. 编译 KMP shared 模块（iOS framework）
3. Xcode Release 模式编译 iOS App（arm64）
4. 打包为未签名 IPA
5. 上传为 Artifact（保留 30 天）

**获取 IPA**：在 GitHub 仓库的 Actions 页面，找到最新的 "Build iOS IPA" workflow，下载 `Legado-unsigned-ipa` artifact。

### 本地构建（需要 macOS + Xcode）

```bash
cd iosApp
xcodebuild \
  -project Legado.xcodeproj \
  -scheme Legado \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -archivePath build/Legado.xcarchive \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  clean archive

mkdir -p build/Payload
cp -R build/Legado.xcarchive/Products/Applications/Legado.app build/Payload/
cd build && zip -qr Legado-unsigned.ipa Payload
```

## 未签名 IPA 安装方式

未签名 IPA 无法直接安装到未越狱设备，需要以下方式之一：

1. **自签名**：使用 `ldid` 或 `codesign` 用个人证书签名
2. **AltStore / SideStore**：通过 AltStore 自签名安装
3. **TrollStore**：支持的设备可直接安装
4. **企业证书**：用企业开发者账号签名后分发
5. **越狱设备**：可直接安装

## 与原项目的关系

本项目基于 legado 的架构和数据模型进行 KMP 重写，目标是：
- 核心引擎代码跨 Android/iOS 共享
- 各端使用原生 UI（Android: Compose, iOS: SwiftUI）
- 书源格式 100% 兼容 legado

原项目：https://github.com/gedoor/legado（原仓库已清空，社区 fork 持续维护）

## License

GPL-3.0（与原项目一致）
