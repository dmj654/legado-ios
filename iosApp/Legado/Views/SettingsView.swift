import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("阅读") {
                    NavigationLink(destination: Text("阅读设置")) {
                        Label("阅读设置", systemImage: "book")
                    }
                    NavigationLink(destination: Text("翻页设置")) {
                        Label("翻页设置", systemImage: "arrow.left.arrow.right")
                    }
                }

                Section("备份") {
                    NavigationLink(destination: Text("备份与恢复")) {
                        Label("备份与恢复", systemImage: "arrow.clockwise")
                    }
                    NavigationLink(destination: Text("WebDAV 设置")) {
                        Label("WebDAV 设置", systemImage: "cloud")
                    }
                }

                Section("关于") {
                    HStack {
                        Label("版本", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0 (KMP)")
                            .foregroundColor(.secondary)
                    }
                    NavigationLink(destination: Text("开源许可")) {
                        Label("开源许可", systemImage: "scroll")
                    }
                    Link(destination: URL(string: "https://github.com/gedoor/legado")!) {
                        Label("原项目地址", systemImage: "link")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("我的")
        }
    }
}

#Preview {
    SettingsView()
}
