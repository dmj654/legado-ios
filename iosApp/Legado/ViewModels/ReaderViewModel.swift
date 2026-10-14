import Foundation
import SwiftData
import Combine

@MainActor
final class ReaderViewModel: ObservableObject {
    @Published var book: BookModel
    @Published var chapters: [ChapterModel] = []
    @Published var currentChapterIndex: Int = 0
    @Published var currentContent: String = ""
    @Published var isLoading: Bool = false
    @Published var showSettings: Bool = false
    @Published var showCatalog: Bool = false
    @Published var errorMessage: String? = nil

    private var storage: StorageManager { StorageManager.shared }

    var currentChapter: ChapterModel? {
        guard currentChapterIndex >= 0 && currentChapterIndex < chapters.count else { return nil }
        return chapters[currentChapterIndex]
    }

    var progressText: String {
        guard !chapters.isEmpty else { return "" }
        return "\(currentChapterIndex + 1)/\(chapters.count)"
    }

    init(book: BookModel) {
        self.book = book
        self.currentChapterIndex = book.durChapterIndex
    }

    func loadChapters() {
        chapters = storage.fetchChapters(bookUrl: book.bookUrl)
        if chapters.isEmpty {
            loadSampleChapters()
        }
        loadCurrentContent()
    }

    private func loadSampleChapters() {
        let sampleTitles = [
            "第一章 初入江湖", "第二章 风云际会", "第三章 暗流涌动",
            "第四章 山雨欲来", "第五章 剑指苍穹", "第六章 破局之路",
            "第七章 天命所归", "第八章 终极一战", "第九章 尘埃落定",
            "第十章 新的征程"
        ]
        chapters = sampleTitles.enumerated().map { index, title in
            ChapterModel(bookUrl: book.bookUrl, index: index, title: title, url: "")
        }
        storage.saveChapters(chapters, bookUrl: book.bookUrl)
        book.totalChapterNum = chapters.count
        try? storage.context.save()
    }

    func loadCurrentContent() {
        guard let chapter = currentChapter else { return }
        if let content = chapter.content, !content.isEmpty {
            currentContent = content
            return
        }
        isLoading = true
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            let content = generateSampleContent(chapterTitle: chapter.title)
            currentContent = content
            chapter.content = content
            chapter.isRead = true
            try? storage.context.save()
            isLoading = false
        }
    }

    private func generateSampleContent(chapterTitle: String) -> String {
        let paragraphs = [
            "　　夜色如墨，寒风凛冽。\(chapterTitle)的故事在这片苍茫大地上缓缓展开。",
            "　　少年立于山巅，望着远方连绵起伏的群山，眼中闪过一丝坚定。他知道，从今天起，他的人生将不再平凡。",
            "　　风吹过，带起他的衣袂。身后，是他必须守护的一切；身前，是未知的危险与挑战。",
            "　　\"既然选择了这条路，便只顾风雨兼程。\"他低声自语，声音虽轻，却带着不容置疑的决心。",
            "　　远处，一道黑影悄然掠过。危险，正在悄然逼近。",
            "　　他猛然回头，眼中精光一闪。多年的历练让他对危险有着本能的敏锐。",
            "　　\"出来吧。\"他冷冷开口，声音在空旷的山谷中回荡。",
            "　　黑影顿了顿，随即从暗处走出。那是一个身着黑衣的蒙面人，浑身散发着冰冷的杀意。",
            "　　\"你是谁？为何跟踪我？\"少年握紧了手中的剑，警惕地问道。",
            "　　蒙面人没有回答，只是缓缓抽出了腰间的长刀。刀身映着月光，泛着幽幽的冷光。",
            "　　一场恶战，在所难免。少年深吸一口气，将全身的功力凝聚于剑尖之上。",
            "　　刀光剑影，气劲纵横。两人在这荒山之巅展开了一场惊心动魄的对决。",
            "　　数十招过后，少年渐感不支。对方的实力远超他的预料，每一刀都带着毁天灭地之势。",
            "　　\"难道今日就要葬身于此？\"他心中不甘，却又无可奈何。",
            "　　就在这千钧一发之际，一道苍老的声音从远方传来：\"住手！\"",
            "　　蒙面人闻言，攻势一顿。少年抓住这转瞬即逝的机会，纵身跃出数丈之外。",
            "　　一位白发老者踏空而来，仙风道骨，气度不凡。他只是轻轻一挥手，蒙面人便如遭重击，倒飞而出。",
            "　　\"前辈...\"少年惊讶地看着眼前的老者，一时不知该说些什么。",
            "　　老者微微一笑：\"孩子，你的路还很长。这把剑，或许能帮到你。\"",
            "　　说罢，老者从怀中取出一柄古朴的长剑，递给了少年。剑身古朴无华，却隐隐透着一股令人心悸的力量。",
            "　　少年接过长剑，只觉得一股暖流从剑身传入体内，原本消耗殆尽的功力竟以肉眼可见的速度恢复着。",
            "　　\"多谢前辈！\"他恭敬地行礼，心中充满了感激。",
            "　　当他再次抬头时，老者已经消失不见，只留下一句话在山谷中回荡：\"天命所归，好自为之...\"",
            "　　少年握着手中的宝剑，望着老者消失的方向，久久不语。他知道，自己的命运，从这一刻起，已经彻底改变。"
        ]
        return paragraphs.joined(separator: "\n\n")
    }

    func nextChapter() {
        guard currentChapterIndex < chapters.count - 1 else { return }
        saveProgress()
        currentChapterIndex += 1
        loadCurrentContent()
    }

    func prevChapter() {
        guard currentChapterIndex > 0 else { return }
        saveProgress()
        currentChapterIndex -= 1
        loadCurrentContent()
    }

    func jumpToChapter(index: Int) {
        guard index >= 0 && index < chapters.count else { return }
        saveProgress()
        currentChapterIndex = index
        loadCurrentContent()
        showCatalog = false
    }

    func saveProgress() {
        storage.updateProgress(
            bookUrl: book.bookUrl,
            chapterIndex: currentChapterIndex,
            position: 0,
            chapterTitle: currentChapter?.title
        )
    }
}
