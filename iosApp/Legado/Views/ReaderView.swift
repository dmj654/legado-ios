import SwiftUI

struct ReaderView: View {
    @EnvironmentObject var settings: AppSettings
    @StateObject private var viewModel: ReaderViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showControls = true
    @State private var dragOffset: CGFloat = 0

    init(book: BookModel) {
        _viewModel = StateObject(wrappedValue: ReaderViewModel(book: book))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                settings.currentTheme.bg
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("加载中...")
                        .tint(settings.currentTheme.text)
                } else {
                    readerContent(in: geometry.size)
                        .gesture(readerGesture(in: geometry.size.width))
                }

                if showControls && !viewModel.isLoading {
                    controlsOverlay
                }
            }
        }
        .statusBar(hidden: showControls)
        .onAppear { viewModel.loadChapters() }
        .onDisappear { viewModel.saveProgress() }
        .sheet(isPresented: $viewModel.showSettings) {
            ReaderSettingsPanel()
                .environmentObject(settings)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $viewModel.showCatalog) {
            ChapterListView(book: viewModel.book, currentIndex: viewModel.currentChapterIndex) { index in
                viewModel.jumpToChapter(index: index)
            }
        }
    }

    private func readerContent(in size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if settings.showTime || settings.showBattery {
                topBar
            }

            ScrollView {
                VStack(alignment: .leading, spacing: settings.paragraphSpacing) {
                    Text(viewModel.currentChapter?.title ?? "")
                        .font(.system(size: settings.fontSize + 4, weight: .bold))
                        .foregroundColor(settings.currentTheme.text)
                        .padding(.bottom, settings.paragraphSpacing)

                    Text(viewModel.currentContent)
                        .font(fontForSize(settings.fontSize))
                        .foregroundColor(settings.currentTheme.text)
                        .lineSpacing(settings.lineSpacing)
                        .multilineTextAlignment(textAlignment)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
        }
        .padding(.top, showControls ? 0 : 8)
    }

    private var topBar: some View {
        HStack {
            if settings.showTime {
                Text(currentTime)
                    .font(.caption2)
                    .foregroundColor(settings.currentTheme.subText)
            }
            Spacer()
            if settings.showBattery {
                HStack(spacing: 4) {
                    Image(systemName: "battery.100")
                        .font(.caption2)
                    Text("85%")
                        .font(.caption2)
                }
                .foregroundColor(settings.currentTheme.subText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var controlsOverlay: some View {
        VStack(spacing: 0) {
            topControls
            Spacer()
            bottomControls
        }
        .background(Color.black.opacity(0.4))
        .transition(.opacity)
    }

    private var topControls: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(12)
            }
            Text(viewModel.book.name)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer()
            Button(action: { viewModel.showCatalog = true }) {
                Image(systemName: "list.bullet")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(12)
            }
        }
        .padding(.top, 44)
        .background(LinearGradient(colors: [.black.opacity(0.6), .clear], startPoint: .top, endPoint: .bottom))
    }

    private var bottomControls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                Button(action: { viewModel.prevChapter() }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .disabled(viewModel.currentChapterIndex == 0)

                Text(viewModel.progressText)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(minWidth: 60)

                Button(action: { viewModel.nextChapter() }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .disabled(viewModel.currentChapterIndex >= viewModel.chapters.count - 1)
            }

            HStack(spacing: 30) {
                Button(action: {}) {
                    VStack(spacing: 4) {
                        Image(systemName: "moon.fill")
                            .font(.title3)
                        Text("夜间")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                }
                Button(action: { viewModel.showSettings = true }) {
                    VStack(spacing: 4) {
                        Image(systemName: "textformat.size")
                            .font(.title3)
                        Text("设置")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                }
                Button(action: {}) {
                    VStack(spacing: 4) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title3)
                        Text("朗读")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                }
                Button(action: {}) {
                    VStack(spacing: 4) {
                        Image(systemName: "bookmark.fill")
                            .font(.title3)
                        Text("书签")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .padding(.bottom, 40)
        .padding(.top, 16)
        .background(LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom))
    }

    private func readerGesture(in width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 30)
            .onChanged { value in
                dragOffset = value.translation.width
            }
            .onEnded { value in
                let horizontalAmount = value.translation.width
                let verticalAmount = value.translation.height
                if abs(horizontalAmount) > abs(verticalAmount) {
                    if horizontalAmount < -50 {
                        viewModel.nextChapter()
                    } else if horizontalAmount > 50 {
                        viewModel.prevChapter()
                    }
                }
                dragOffset = 0
            }
    }

    private func fontForSize(_ size: Double) -> Font {
        switch settings.fontFamily {
        case "宋体": return .custom("STSong", size: size)
        case "楷体": return .custom("STKaiti", size: size)
        case "黑体": return .custom("STHeiti", size: size)
        default: return .system(size: size)
        }
    }

    private var textAlignment: TextAlignment {
        switch settings.textAlignment {
        case 1: return .center
        case 2: return .trailing
        default: return .leading
        }
    }

    private var currentTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}

struct ReaderSettingsPanel: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("字号与字体") {
                    HStack {
                        Text("字号")
                        Slider(value: $settings.fontSize, in: 12...28, step: 1)
                        Text("\(Int(settings.fontSize))")
                            .frame(width: 30)
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
                        Text("\(Int(settings.lineSpacing))")
                            .frame(width: 30)
                    }
                    HStack {
                        Text("段间距")
                        Slider(value: $settings.paragraphSpacing, in: 0...32, step: 2)
                        Text("\(Int(settings.paragraphSpacing))")
                            .frame(width: 30)
                    }
                    Picker("对齐", selection: $settings.textAlignment) {
                        Text("左对齐").tag(0)
                        Text("居中").tag(1)
                        Text("右对齐").tag(2)
                    }
                }

                Section("主题") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(settings.themes.enumerated()), id: \.element.id) { index, theme in
                                Button(action: { settings.themeIndex = index }) {
                                    VStack(spacing: 4) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(theme.bg)
                                            .frame(width: 60, height: 80)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(settings.themeIndex == index ? Color.blue : Color.clear, lineWidth: 3)
                                            )
                                            .overlay(
                                                Text("文")
                                                    .font(.caption)
                                                    .foregroundColor(theme.text)
                                            )
                                        Text(theme.name)
                                            .font(.caption2)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                    }
                }

                Section("翻页") {
                    Picker("翻页动画", selection: $settings.pageAnimation) {
                        Text("覆盖").tag("cover")
                        Text("滑动").tag("slide")
                        Text("仿真").tag("simulation")
                        Text("无动画").tag("none")
                    }
                    Toggle("音量键翻页", isOn: $settings.volumeKeyFlip)
                    Toggle("点击中央翻页", isOn: $settings.clickCenterFlip)
                }

                Section("显示") {
                    Toggle("显示时间", isOn: $settings.showTime)
                    Toggle("显示电量", isOn: $settings.showBattery)
                    Toggle("显示进度", isOn: $settings.showProgress)
                    Toggle("保持屏幕常亮", isOn: $settings.keepScreenOn)
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
    ReaderView(book: BookModel(bookUrl: "test", name: "示例小说"))
}
