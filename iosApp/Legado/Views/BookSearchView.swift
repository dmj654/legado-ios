import SwiftUI

struct BookSearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var showDetail = false
    @State private var selectedResult: SearchResultItem? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $viewModel.keyword, placeholder: "搜索书名、作者", onSearch: {
                    viewModel.search(keyword: viewModel.keyword)
                })
                .padding(.horizontal)
                .padding(.vertical, 8)

                if viewModel.isSearching {
                    ProgressView("正在搜索...")
                        .padding()
                    Spacer()
                } else if let error = viewModel.errorMessage, viewModel.results.isEmpty {
                    EmptyStateView(icon: "exclamationmark.triangle", title: "搜索失败", message: error)
                    Spacer()
                } else if !viewModel.results.isEmpty {
                    List {
                        ForEach(viewModel.results) { result in
                            searchResultRow(result)
                        }
                        if viewModel.hasMore && !viewModel.results.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .onAppear { viewModel.loadMore() }
                                Spacer()
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                } else {
                    searchHistoryView
                }
            }
            .navigationTitle("搜索")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedResult) { result in
                SearchResultDetailView(result: result)
            }
            .onAppear { viewModel.loadHistory() }
        }
        .navigationViewStyle(.stack)
    }

    private var searchHistoryView: some View {
        List {
            if !viewModel.searchHistory.isEmpty {
                Section {
                    ForEach(viewModel.searchHistory) { history in
                        Button(action: {
                            viewModel.keyword = history.keyword
                            viewModel.search(keyword: history.keyword)
                        }) {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundColor(.gray)
                                Text(history.keyword)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("搜索历史")
                        Spacer()
                        Button("清空") { viewModel.clearHistory() }
                            .font(.caption)
                    }
                }
            }

            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.hotKeywords, id: \.self) { keyword in
                            Button(action: {
                                viewModel.keyword = keyword
                                viewModel.search(keyword: keyword)
                            }) {
                                Text(keyword)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.1))
                                    .foregroundColor(.orange)
                                    .cornerRadius(14)
                            }
                        }
                    }
                }
            } header: {
                Text("热门搜索")
            }
        }
        .listStyle(.insetGrouped)
    }

    private func searchResultRow(_ result: SearchResultItem) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(LinearGradient(colors: [.blue.opacity(0.5), .purple.opacity(0.5)], startPoint: .top, endPoint: .bottom))
                .frame(width: 60, height: 80)
                .overlay(
                    Text(result.title.prefix(2))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.headline)
                    .lineLimit(1)
                if !result.author.isEmpty {
                    Text(result.author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if let last = result.lastChapter, !last.isEmpty {
                    Text(last)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                Text(result.sourceName)
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture { selectedResult = result }
    }
}

struct SearchResultDetailView: View {
    let result: SearchResultItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(colors: [.blue.opacity(0.5), .purple.opacity(0.5)], startPoint: .top, endPoint: .bottom))
                            .frame(width: 100, height: 140)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(result.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(result.author)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(result.sourceName)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                    .padding()

                    if let intro = result.intro, !intro.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("简介")
                                .font(.headline)
                            Text(intro)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }

                    Button(action: {
                        let vm = SearchViewModel()
                        vm.addToShelf(result: result)
                        dismiss()
                    }) {
                        Text("加入书架")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("书籍详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    BookSearchView()
}
