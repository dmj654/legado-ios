import SwiftUI

struct ReaderView: View {
    let bookTitle: String
    let chapterTitle: String
    let content: String

    @State private var fontSize: CGFloat = 18
    @State private var backgroundColor: Color = .white
    @State private var textColor: Color = .black
    @State private var showSettings = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(chapterTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)

                    Text(content)
                        .font(.system(size: fontSize))
                        .lineSpacing(8)
                        .foregroundColor(textColor)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(backgroundColor)
        }
        .navigationTitle(bookTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "textformat.size")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            ReaderSettingsView(
                fontSize: $fontSize,
                backgroundColor: $backgroundColor,
                textColor: $textColor
            )
            .presentationDetents([.medium])
        }
    }
}

struct ReaderSettingsView: View {
    @Binding var fontSize: CGFloat
    @Binding var backgroundColor: Color
    @Binding var textColor: Color
    @Environment(\.dismiss) private var dismiss

    private let themes: [(name: String, bg: Color, text: Color)] = [
        ("默认", .white, .black),
        ("护眼", Color(red: 0.96, green: 0.95, blue: 0.88), Color(red: 0.3, green: 0.3, blue: 0.25)),
        ("夜间", Color(red: 0.1, green: 0.1, blue: 0.1), Color(red: 0.8, green: 0.8, blue: 0.8)),
        ("羊皮纸", Color(red: 0.93, green: 0.88, blue: 0.78), Color(red: 0.35, green: 0.28, blue: 0.2))
    ]

    var body: some View {
        NavigationView {
            Form {
                Section("字号") {
                    HStack {
                        Text("A-")
                        Slider(value: $fontSize, in: 12...28, step: 1)
                        Text("A+")
                    }
                    Text("当前: \(Int(fontSize))pt")
                        .foregroundColor(.secondary)
                }

                Section("主题") {
                    ForEach(themes, id: \.name) { theme in
                        Button(action: {
                            backgroundColor = theme.bg
                            textColor = theme.text
                        }) {
                            HStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(theme.bg)
                                    .frame(width: 40, height: 30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.gray.opacity(0.3))
                                    )
                                Text(theme.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                if backgroundColor == theme.bg {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("阅读设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ReaderView(
        bookTitle: "示例小说",
        chapterTitle: "第一章 示例章节",
        content: "这是一段示例正文内容。\n\n在实际使用中，这里会显示从书源获取的小说正文。\n\n支持多种翻页模式、字体大小调整、背景主题切换等功能。"
    )
}
