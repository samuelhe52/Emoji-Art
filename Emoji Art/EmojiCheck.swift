//
//  EmojiCheck.swift
//  Emoji Art
//
//  Borrowed from krummler/String+EmojiCheck.swift on github:
//  https://gist.github.com/krummler/879e1ce942893db3104783d1d0e67b34
//
//  Created by Samuel He on 2024/9/14.
//

import Foundation

extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        return unicodeScalars.count == 1 && unicodeScalars.first?.properties.isEmojiPresentation ?? false
    }

    /// Checks if the scalars will be merged into and emoji
    var isCombinedIntoEmoji: Bool {
        return unicodeScalars.count > 1 &&
        unicodeScalars.contains { $0.properties.isJoinControl ||
            $0.properties.isVariationSelector ||
            $0.properties.isEmojiModifier }
    }

    var isEmoji: Bool {
        return isSimpleEmoji || isCombinedIntoEmoji
    }
}

extension String {
    var isSingleEmoji: Bool {
        return count == 1 && containsEmoji
    }

    var containsEmoji: Bool {
        return contains { $0.isEmoji }
    }

    var containsOnlyEmoji: Bool {
        return !isEmpty && !contains { !$0.isEmoji }
    }

    var emojiString: String {
        return emojis.map { String($0) }.reduce("", +)
    }

    var emojis: [Character] {
        filter { $0.isEmoji }
    }

    var emojiScalars: [UnicodeScalar] {
        return filter{ $0.isEmoji }.flatMap { $0.unicodeScalars }
    }
}
