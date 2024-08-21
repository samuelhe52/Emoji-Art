//
//  EmojiArt.swift
//  Emoji Art
//
//  Created by Samuel He on 2024/8/21.
//

import Foundation

struct EmojiArt {
    var background: URL?
    var emojis = [Emoji]()
    
    private var uniqueEmojiID = 0
    
    mutating func addEmoji(_ emoji: String, at position: Emoji.Position, size: Int) {
        uniqueEmojiID += 1
        emojis.append(Emoji(string: emoji,
                            size: size,
                            position: position,
                            id: uniqueEmojiID))
    }
}

struct Emoji: Identifiable {
    let string: String
    var size: Int
    var position: Position
    
    var id: Int
    
    struct Position: Equatable {
        let x: Int
        let y: Int
        
        static let zero = Position(x: 0, y: 0)
    }
}
