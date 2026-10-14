import SwiftUI

struct BookShelfView: View {
    @State private var books: [Book] = []
    @State private var showingAddBook = false

    var body: some View {
        NavigationView {
            Group {
                if books.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "books.vertical")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("书架空空如也")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("去搜索添加书籍，或导入书源")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(books) { book in
                                BookCoverView(book: book)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("书架")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBook = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBook) {
                BookSearchView()
            }
        }
    }
}

struct BookCoverView: View {
    let book: Book

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)], startPoint: .top, endPoint: .bottom))
                .frame(height: 140)
                .overlay(
                    Text(book.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(8)
                )
            Text(book.name)
                .font(.caption)
                .lineLimit(1)
            Text(book.author ?? "未知")
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
}

struct Book: Identifiable {
    let id = UUID()
    let name: String
    let author: String?
    let coverUrl: String?
}

#Preview {
    BookShelfView()
}
