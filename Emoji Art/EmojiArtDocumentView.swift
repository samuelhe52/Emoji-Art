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
            documentBody
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
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                return drop(sturldatas, at: location, in: geometry)
            }
        }
    }
    
    private func drop(_ sturldatas: [Sturldata],
                      at location: CGPoint,
                      in geometry: GeometryProxy) -> Bool {
        for sturldata in sturldatas {
            switch sturldata {
            case .url(let url):
                document.setBackground(url)
                return true
            case .string(let string):
                document.addEmoji(
                    string,
                    size: Constants.paletteEmojiSize,
                    at: .init(at: location, in: geometry)
                )
                return true
            default:
                break
            }
        }
        return false
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
                        .draggable(emoji)
                }
            }
        }.scrollIndicators(.never)
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
}
