import SwiftUI

struct BookCoverView: View {
    let book: BookModel
    var size: CGSize = CGSize(width: 80, height: 110)

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 6)
                .fill(LinearGradient(
                    colors: [gradientColor.opacity(0.7), gradientColor.opacity(0.4)],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(width: size.width, height: size.height)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)

            VStack(spacing: 4) {
                Text(book.name)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 6)

                if !book.author.isEmpty {
                    Text(book.author)
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                        .padding(.bottom, 6)
                }
            }
            .padding(.bottom, 4)

            if book.readProgress > 0 {
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: geo.size.width * book.readProgress, height: 3)
                }
                .frame(height: 3)
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private var gradientColor: Color {
        let hash = abs(book.name.hashValue) % 6
        let colors: [Color] = [.blue, .purple, .orange, .green, .pink, .red]
        return colors[hash]
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundColor(.gray.opacity(0.5))

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 8)
            }
        }
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = "搜索"
    var onSearch: (() -> Void)? = nil
    var onTextChanged: ((String) -> Void)? = nil

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSearch: onSearch, onTextChanged: onTextChanged)
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        var onSearch: (() -> Void)?
        var onTextChanged: ((String) -> Void)?

        init(text: Binding<String>, onSearch: (() -> Void)?, onTextChanged: ((String) -> Void)?) {
            _text = text
            self.onSearch = onSearch
            self.onTextChanged = onTextChanged
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
            onTextChanged?(searchText)
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            onSearch?()
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            text = ""
            searchBar.resignFirstResponder()
        }
    }
}
