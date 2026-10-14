import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var showAbout = false

    var body: some View {
        NavigationView {
            List {
                Section("阅读") {
                    NavigationLink(destination: ReaderSettingsOnlyView()) {
                        Label("阅读设置", systemImage: "book")
                    }
                    NavigationLink(destination: Text("翻页设置")) {
                        Label("翻页设置", systemImage: "arrow.left.arrow.right")
                    }
                    NavigationLink(destination: Text("下载设置")) {
                        Label("下载设置", systemImage: "arrow.down.circle")
                    }
                }

                Section("外观") {
                    Picker("主题模式", selection: $settings.appearanceMode) {
                        Text("跟随系统").tag("system")
                        Text("浅色").tag("light")
                        Text("深色").tag("dark")
                    }
                    Picker("强调色", selection: $settings.accentColor) {
                        Text("蓝色").tag("blue")
                        Text("绿色").tag("green")
                        Text("橙色").tag("orange")
                        Text("紫色").tag("purple")
                        Text("红色").tag("red")
                    }
                }

                Section("书源") {
                    NavigationLink(destination: Text("源校验")) {
                        Label("书源校验", systemImage: "checkmark.shield")
                    }
                    NavigationLink(destination: Text("源排序")) {
                        Label("书源排序", systemImage: "arrow.up.arrow.down")
                    }
                }

                Section("备份") {
                    Button(action: {}) {
                        Label("本地备份", systemImage: "folder")
                    }
                    Button(action: {}) {
                        Label("本地恢复", systemImage: "arrow.uturn.backward")
                    }
                    NavigationLink(destination: Text("WebDAV 设置")) {
                        Label("WebDAV 同步", systemImage: "cloud")
                    }
                }

                Section("其他") {
                    NavigationLink(destination: Text("缓存管理")) {
                        Label("清理缓存", systemImage: "trash")
                    }
                    NavigationLink(destination: Text("关于")) {
                        Label("关于阅读", systemImage: "info.circle")
                    }
                    Link(destination: URL(string: "https://github.com/gedoor/legado")!) {
                        Label("原项目地址", systemImage: "link")
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("阅读 iOS KMP 版")
                                .font(.headline)
                            Text("版本 1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("基于 legado 开源项目")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(.stack)
    }
}

struct ReaderSettingsOnlyView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Section("字号与字体") {
                HStack {
                    Text("字号")
                    Slider(value: $settings.fontSize, in: 12...28, step: 1)
                    Text("\(Int(settings.fontSize))")
                }
                Picker("字体", selection: $settings.fontFamily) {
                    Text("系统").tag("系统")
                    Text("宋体").tag("宋体")
                    Text("楷体").tag("楷体")
                    Text("黑体").tag("黑体")
                }
            }
            Section("间距") {
                HStack {
                    Text("行间距")
                    Slider(value: $settings.lineSpacing, in: 0...20, step: 1)
                }
                HStack {
                    Text("段间距")
                    Slider(value: $settings.paragraphSpacing, in: 0...32, step: 2)
                }
            }
            Section("主题") {
                Picker("阅读主题", selection: $settings.themeIndex) {
                    ForEach(Array(settings.themes.enumerated()), id: \.element.id) { index, theme in
                        Text(theme.name).tag(index)
                    }
                }
            }
            Section("显示") {
                Toggle("显示时间", isOn: $settings.showTime)
                Toggle("显示电量", isOn: $settings.showBattery)
                Toggle("显示进度", isOn: $settings.showProgress)
                Toggle("保持屏幕常亮", isOn: $settings.keepScreenOn)
            }
        }
        .navigationTitle("阅读设置")
    }
}

#Preview {
    SettingsView()
}
