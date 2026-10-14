import SwiftUI
import SwiftData

struct BookDetailView: View {
    let book: BookModel
    @Environment(\.dismiss) private var dismiss
    @State private var showReader = false
    @State private var showCatalog = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    headerView
                    infoSection
                    actionButtons
                    introSection
                    catalogPreview
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {}) { Label("加入分组", systemImage: "folder") }
                        Button(action: {}) { Label("换源", systemImage: "arrow.triangle.2.circlepath") }
                        Button(role: .destructive, action: {}) { Label("从书架删除", systemImage: "trash") }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .fullScreenCover(isPresented: $showReader) {
                ReaderView(book: book)
            }
            .sheet(isPresented: $showCatalog) {
                ChapterListView(book: book, currentIndex: book.durChapterIndex) { index in
                    showCatalog = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showReader = true
                    }
                }
            }
        }
    }

    private var headerView: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: [.blue.opacity(0.6), .purple.opacity(0.4), .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: 280)

            HStack(spacing: 16) {
                BookCoverView(book: book, size: CGSize(width: 110, height: 155))
                    .shadow(radius: 8)

                VStack(alignment: .leading, spacing: 6) {
                    Text(book.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Text(book.author)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    if let kind = book.kind, !kind.isEmpty {
                        Text(kind)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    HStack(spacing: 12) {
                        Label("\(book.totalChapterNum)章", systemImage: "list.bullet")
                        Label("\(Int(book.readProgress * 100))%", systemImage: "book")
                    }
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    private var infoSection: some View {
        HStack(spacing: 0) {
            infoItem(title: "字数", value: "未知")
            Divider().frame(height: 30)
            infoItem(title: "状态", value: book.lastChapterName != nil ? "连载" : "未知")
            Divider().frame(height: 30)
            infoItem(title: "最新", value: book.lastChapterName ?? "未知")
        }
        .padding(.vertical, 12)
    }

    private func infoItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: { showReader = true }) {
                Label(book.durChapterIndex > 0 ? "继续阅读" : "开始阅读", systemImage: "book.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            Button(action: { showCatalog = true }) {
                Label("目录", systemImage: "list.bullet")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var introSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("简介")
                .font(.headline)
            Text(book.intro ?? "暂无简介")
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var catalogPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("目录")
                    .font(.headline)
                Spacer()
                Button("全部") { showCatalog = true }
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            if let last = book.lastChapterName {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    Text("最新：\(last)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.05))
    }
}

#Preview {
    BookDetailView(book: BookModel(bookUrl: "test", name: "示例小说", author: "示例作者"))
}
