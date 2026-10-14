import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("fontSize") var fontSize: Double = 18
    @AppStorage("lineSpacing") var lineSpacing: Double = 8
    @AppStorage("paragraphSpacing") var paragraphSpacing: Double = 16
    @AppStorage("fontFamily") var fontFamily: String = "系统"
    @AppStorage("themeIndex") var themeIndex: Int = 0
    @AppStorage("pageAnimation") var pageAnimation: String = "cover"
    @AppStorage("brightness") var brightness: Double = 0.8
    @AppStorage("autoBrightness") var autoBrightness: Bool = true
    @AppStorage("textAlignment") var textAlignment: Int = 0
    @AppStorage("showBattery") var showBattery: Bool = true
    @AppStorage("showTime") var showTime: Bool = true
    @AppStorage("showProgress") var showProgress: Bool = true
    @AppStorage("keepScreenOn") var keepScreenOn: Bool = true
    @AppStorage("volumeKeyFlip") var volumeKeyFlip: Bool = false
    @AppStorage("clickCenterFlip") var clickCenterFlip: Bool = true
    @AppStorage("shelfViewMode") var shelfViewMode: String = "grid"
    @AppStorage("shelfSortBy") var shelfSortBy: String = "recent"
    @AppStorage("appearanceMode") var appearanceMode: String = "system"
    @AppStorage("accentColor") var accentColor: String = "blue"

    let themes: [ReaderTheme] = [
        ReaderTheme(name: "默认", bg: .white, text: .black, subText: .gray),
        ReaderTheme(name: "护眼", bg: Color(red: 0.96, green: 0.95, blue: 0.88), text: Color(red: 0.3, green: 0.3, blue: 0.25), subText: .gray),
        ReaderTheme(name: "夜间", bg: Color(red: 0.1, green: 0.1, blue: 0.1), text: Color(red: 0.85, green: 0.85, blue: 0.85), subText: Color(red: 0.5, green: 0.5, blue: 0.5)),
        ReaderTheme(name: "羊皮纸", bg: Color(red: 0.93, green: 0.88, blue: 0.78), text: Color(red: 0.35, green: 0.28, blue: 0.2), subText: Color(red: 0.5, green: 0.45, blue: 0.35)),
        ReaderTheme(name: "绿色", bg: Color(red: 0.88, green: 0.94, blue: 0.88), text: Color(red: 0.2, green: 0.35, blue: 0.2), subText: Color(red: 0.4, green: 0.5, blue: 0.4)),
        ReaderTheme(name: "粉色", bg: Color(red: 0.96, green: 0.90, blue: 0.92), text: Color(red: 0.35, green: 0.2, blue: 0.25), subText: Color(red: 0.5, green: 0.4, blue: 0.42))
    ]

    var currentTheme: ReaderTheme {
        themes[min(themeIndex, themes.count - 1)]
    }

    var effectiveColorScheme: ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}

struct ReaderTheme: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let bg: Color
    let text: Color
    let subText: Color
}
