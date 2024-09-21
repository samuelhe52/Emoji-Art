//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by Samuel He on 2024/8/21.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    @Published private var emojiArt = EmojiArt() {
        didSet {
            autosave()
            if emojiArt.background != oldValue.background {
                Task {
                    await fetchBackgroundImage()
                }
            }
        }
    }
    
    private let autosaveURL: URL = URL.documentsDirectory.appendingPathComponent("Autosaved.emojiart")
    
    private func autosave() {
        save(to: autosaveURL)
        print("autosaved to \(autosaveURL)")
    }
    
    private func save(to url: URL) {
        do {
            let data = try emojiArt.json()
            try data.write(to: url)
        } catch {
            print("EmojiArtDocument: error while saving: \(error.localizedDescription)")
        }
    }
    
    init() {
        if let data = try? Data(contentsOf: autosaveURL),
           let autosavedEmojiArt = try? EmojiArt(jsonData: data) {
            emojiArt = autosavedEmojiArt
        }
    }
    
    var emojis: [Emoji] { emojiArt.emojis }
    
    var bbox: CGRect {
        emojiArt.emojis
            .reduce(CGRect.zero) { $0.union($1.bbox) }
            .union(CGRect(center: .zero, size: background.uiImage?.size ?? .zero))
    }
    
    @Published var background: Background = .none
    
    // MARK: - Background Image
    
    @MainActor
    private func fetchBackgroundImage() async {
        if let url = emojiArt.background {
            background = .fetching(url)
            do {
                let image = try await fetchUIImage(from: url)
                if url == emojiArt.background {
                    background = .found(image)
                }
            } catch {
                background = .failed(error)
            }
        } else {
            background = .none
        }
    }
    
    private func fetchUIImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let uiImage = UIImage(data: data) {
            return uiImage
        } else {
            throw BackgroundFetchError.urlDoesNotContainImage
        }
    }
    
    enum Background {
        case none
        case fetching(URL)
        case found(UIImage)
        case failed(Error)
        
        var uiImage: UIImage? {
            switch self {
            case .found(let uiImage): return uiImage
            default: return nil
            }
        }
        
        var urlBeingFetched: URL? {
            switch self {
            case .fetching(let url): return url
            default: return nil
            }
        }
        
        var isFetching: Bool { urlBeingFetched != nil }
        
        var failureReason: String? {
            switch self {
            case .failed(let reason): return reason.localizedDescription
            default: return nil
            }
        }
    }
    
    enum BackgroundFetchError: Error {
        case urlDoesNotContainImage
        
        var description: String {
            switch self {
            case .urlDoesNotContainImage: return "URL doesn't contain an image."
            }
        }
    }
    
    // MARK: - Intents
    func setBackground(_ url: URL?) {
        emojiArt.background = url
    }
    
    func addEmoji(_ emoji: String, size: CGFloat, at position: Emoji.Position) {
        emojiArt.addEmoji(emoji, size: Int(size), at: position)
    }
    
    func move(_ emoji: Emoji, by offset: CGOffset) {
        let existingPosition = emojiArt[emoji].position
        emojiArt[emoji].position = Emoji.Position(
            x: existingPosition.x + Int(offset.width),
            y: existingPosition.y - Int(offset.height)
        )
    }
    
    func move(emojiWithID id: Emoji.ID, by offset: CGOffset) {
        if let emoji = emojiArt[id] {
            move(emoji, by: offset)
        }
    }
    
    func resize(_ emoji: Emoji, by scale: CGFloat) {
        emojiArt[emoji].size = Int(CGFloat(emojiArt[emoji].size) * scale)
    }
    
    func resize(emojiWithID id: Emoji.ID, by scale: CGFloat) {
        if let emoji = emojiArt[id] {
            resize(emoji, by: scale)
        }
    }
    
    func remove(_ emojis: Set<Emoji>) {
        let ids = Set(emojis.map { $0.id })
        remove(emojisWithIDs: ids)
    }
    
    func remove(emojisWithIDs ids: Set<Emoji.ID>) {
        emojiArt.emojis.removeAll(where: { ids.contains($0.id) })
    }
}

extension Emoji {
    var font: Font {
        Font.system(size: CGFloat(size))
    }
    var bbox: CGRect {
        CGRect(
            center: position.in(nil),
            size: CGSize(width: CGFloat(size), height: CGFloat(size))
        )
    }
}

extension Emoji.Position {
    /// - Returns: The corresponding `CGPoint` in SwiftUI's default coordinate system.
    func `in`(_ geometry: GeometryProxy?) -> CGPoint {
        let center = geometry?.frame(in: .local).center ?? .zero
        // We use minus sign for y coordinate to make this a Cartesian coordinate system.
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
    
    /// Initializes an instance by calculating its position relative to the center of the given `GeometryProxy`.
    ///
    /// - Parameters:
    ///   - location: A `CGPoint` representing the location in the `GeometryProxy`'s coordinate space.
    ///   - geometry: A `GeometryProxy` object that provides access to the frame of the view.
    init(at location: CGPoint,
         in geometry: GeometryProxy?,
         pan: CGOffset = .zero,
         zoom: CGFloat = 1) {
        let center = geometry?.frame(in: .local).center ?? .zero
        self.init(
            x: Int((location.x - center.x - pan.width) / zoom),
            y: Int((-(location.y - center.y - pan.height)) / zoom)
        )
    }
}
