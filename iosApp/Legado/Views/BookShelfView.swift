import SwiftUI
import SwiftData

struct BookShelfView: View {
    @EnvironmentObject var settings: AppSettings
    @StateObject private var viewModel = BookShelfViewModel()
    @State private var showSearch = false
    @State private var selectedBook: BookModel? = nil
    @State private var showReader = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.filteredBooks.isEmpty {
                    EmptyStateView(
                        icon: "books.vertical",
                        title: "书架空空如也",
                        message: "去搜索添加你喜欢的小说吧",
                        actionTitle: "去搜索",
                        action: { selectedTab() }
                    )
                } else {
                    ScrollView {
                        if !viewModel.groups.isEmpty {
                            groupFilterBar
                        }
                        if viewModel.viewMode == "grid" {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.filteredBooks) { book in
                                    bookGridItem(book)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 8)
                        } else {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.filteredBooks) { book in
                                    bookListItem(book)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("书架")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("排序", selection: $viewModel.sortBy) {
                            Text("最近阅读").tag("recent")
                            Text("书名").tag("name")
                            Text("添加时间").tag("addTime")
                            Text("阅读进度").tag("progress")
                        }
                        Picker("视图", selection: $viewModel.viewMode) {
                            Label("网格", systemImage: "square.grid.3x3").tag("grid")
                            Label("列表", systemImage: "list.bullet").tag("list")
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSearch = true }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                BookSearchView()
            }
            .sheet(item: $selectedBook) { book in
                BookDetailView(book: book)
            }
            .onAppear { viewModel.loadBooks() }
        }
        .navigationViewStyle(.stack)
    }

    private var groupFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "全部", isSelected: viewModel.selectedGroup == nil) {
                    viewModel.selectedGroup = nil
                }
                ForEach(viewModel.groups, id: \.self) { group in
                    FilterChip(title: group, isSelected: viewModel.selectedGroup == group) {
                        viewModel.selectedGroup = viewModel.selectedGroup == group ? nil : group
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 8)
    }

    private func bookGridItem(_ book: BookModel) -> some View {
        VStack(spacing: 6) {
            BookCoverView(book: book, size: CGSize(width: 100, height: 140))
                .onTapGesture { selectedBook = book }
                .contextMenu {
                    Button(action: { viewModel.moveBookToTop(book) }) {
                        Label("置顶", systemImage: "pin")
                    }
                    Button(role: .destructive, action: {
                        viewModel.bookToDelete = book
                        viewModel.showDeleteConfirmation = true
                    }) {
                        Label("删除", systemImage: "trash")
                    }
                }
            Text(book.name)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)
            if !book.author.isEmpty {
                Text(book.author)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private func bookListItem(_ book: BookModel) -> some View {
        HStack(spacing: 12) {
            BookCoverView(book: book, size: CGSize(width: 56, height: 78))
            VStack(alignment: .leading, spacing: 4) {
                Text(book.name)
                    .font(.headline)
                    .lineLimit(1)
                if !book.author.isEmpty {
                    Text(book.author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                if let last = book.lastChapterName, !last.isEmpty {
                    Text(last)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                HStack(spacing: 4) {
                    ProgressView(value: book.readProgress)
                        .progressViewStyle(.linear)
                        .frame(height: 4)
                    Text("\(Int(book.readProgress * 100))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture { selectedBook = book }
        .contextMenu {
            Button(action: { viewModel.moveBookToTop(book) }) {
                Label("置顶", systemImage: "pin")
            }
            Button(role: .destructive, action: {
                viewModel.bookToDelete = book
                viewModel.showDeleteConfirmation = true
            }) {
                Label("从书架删除", systemImage: "trash")
            }
        }
    }

    private func selectedTab() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = 1
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.15))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

#Preview {
    BookShelfView()
}
