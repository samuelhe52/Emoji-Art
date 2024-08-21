//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by Samuel He on 2024/8/21.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    private var emojiArt = EmojiArt()
    
    var emojis: [Emoji] { emojiArt.emojis }
    var background: URL? { emojiArt.background }
    
    // MARK: - Intents
    func setBackground(_ url: URL?) {
        emojiArt.background = url
    }
    
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: CGFloat) {
        emojiArt.addEmoji(emoji, at: position, size: Int(size))
    }

}

extension Emoji {
    var font: Font {
        Font.system(size: CGFloat(size))
    }
}

extension Emoji.Position {
    func `in`(_ geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
}
