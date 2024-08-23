//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by Samuel He on 2024/8/21.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    @Published private var emojiArt = EmojiArt()
    
    var emojis: [Emoji] { emojiArt.emojis }
    var background: URL? { emojiArt.background }
    
    // MARK: - Intents
    func setBackground(_ url: URL?) {
        emojiArt.background = url
    }
    
    func addEmoji(_ emoji: String, size: CGFloat, at position: Emoji.Position) {
        emojiArt.addEmoji(emoji, size: Int(size), at: position)
    }
}

extension Emoji {
    var font: Font {
        Font.system(size: CGFloat(size))
    }
}

extension Emoji.Position {
    /// - Returns: The corresponding `CGPoint` in SwiftUI's default coordinate system.
    func `in`(_ geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        // We use minus sign for y coordinate to make this a Cartesian coordinate system.
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
    
    /// Initializes an instance by calculating its position relative to the center of the given `GeometryProxy`.
    ///
    /// - Parameters:
    ///   - location: A `CGPoint` representing the location in the `GeometryProxy`'s coordinate space.
    ///   - geometry: A `GeometryProxy` object that provides access to the frame of the view.
    init(at location: CGPoint,
         in geometry: GeometryProxy,
         pan: CGOffset = .zero,
         zoom: CGFloat = 1) {
        let center = geometry.frame(in: .local).center
        self.init(
            x: Int((location.x - center.x - pan.width) / zoom),
            y: Int((-(location.y - center.y - pan.height)) / zoom)
        )
    }
}
