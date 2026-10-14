import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            BookShelfView()
                .tabItem { Label("书架", systemImage: "books.vertical.fill") }
                .tag(0)

            BookSearchView()
                .tabItem { Label("搜索", systemImage: "magnifyingglass") }
                .tag(1)

            BookSourceManagerView()
                .tabItem { Label("书源", systemImage: "square.stack.3d.up.fill") }
                .tag(2)

            SettingsView()
                .tabItem { Label("我的", systemImage: "person.crop.circle.fill") }
                .tag(3)
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
}
