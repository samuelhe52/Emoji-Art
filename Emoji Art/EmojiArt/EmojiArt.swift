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
    
    subscript(_ emojiID: Emoji.ID) -> Emoji? {
        if let index = index(of: emojiID) {
            return emojis[index]
        } else {
            return nil
        }
    }
    
    /// The use of this subscript here ensures that, when we want to change an emoji’s property
    /// in the emojis array, we don’t have to fetch the index of that emoji and use the subscript of the
    /// emojis array to access the emoji. Using this subscript would allow us to directly modify the
    /// Emoji instance in emojis, i.e. it does the indexing work for us.
    subscript(_ emoji: Emoji) -> Emoji {
        get {
            if let index = index(of: emoji.id) {
                return emojis[index]
            } else {
                return emoji // should probably throw error
            }
        }
        set {
            if let index = index(of: emoji.id) {
                emojis[index] = newValue
            }
        }
    }
    
    private func index(of emojiID: Emoji.ID) -> Int? {
        emojis.firstIndex(where: { $0.id == emojiID })
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
