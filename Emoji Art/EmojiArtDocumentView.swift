//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by Samuel He on 2024/8/21.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    struct Constants {
        static let paletteEmojiSize: CGFloat = 40
    }
    
    private let emojis = "👻🍎😃🤪☹️🤯🐶🐭🦁🐵🦆🐝🐢🐄🐖🌲🌴🌵🍄🌞🌎🔥🌈🌧️🌨️☁️⛄️⛳️🚗🚙🚓🚲🛺🏍️🚘✈️🛩️🚀🚁🏰🏠❤️💤⛵️"
    
    var body: some View {
        VStack(spacing: 0) {
            Color.yellow
            ScrollingEmojis(emojis)
                .font(.system(size: Constants.paletteEmojiSize))
                .padding(.horizontal)
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                AsyncImage(url: document.background)
                    .position(Emoji.Position.zero.in(geometry))
                ForEach(document.emojis) { emoji in
                    Text(emoji.string)
                        .font(emoji.font)
                        .position(emoji.position.in(geometry))
                }
            }
        }
    }
}

struct ScrollingEmojis: View {
    var emojis: [String]
    
    init(_ emojis: String) {
        let uniquedEmojis = Set(Array(emojis)).map(String.init)
        self.emojis = uniquedEmojis
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                }
            }
        }.scrollIndicators(.hidden)
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
}
