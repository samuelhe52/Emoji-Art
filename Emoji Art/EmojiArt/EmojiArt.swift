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
    
    mutating func addEmoji(_ emoji: String, size: Int, at position: Emoji.Position) {
        uniqueEmojiID += 1
        emojis.append(Emoji(string: emoji,
                            size: size,
                            position: position,
                            id: uniqueEmojiID))
    }
}

struct Emoji: Identifiable {
    /// An emoji as a `String` instance.
    let string: String
    /// The conceptual size of the emoji.
    var size: Int
    /// The `Position` for the emoji on screen, in Cartesian coordinate system.
    var position: Position
    var id: Int
    
    /// - Parameters:
    ///     - string: An emoji as a `String` instance.
    ///     - size: The conceptual size of the emoji.
    ///     - position: The `Position` for the emoji on screen, in Cartesian coordinate system.
    init(string: String, size: Int, position: Position, id: Int) {
        self.string = string
        self.size = size
        self.position = position
        self.id = id
    }
    
    struct Position: Equatable {
        let x: Int
        let y: Int
        
        static let zero = Position(x: 0, y: 0)
    }
}
