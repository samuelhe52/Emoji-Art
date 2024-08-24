//
//  PaletteChooser.swift
//  Emoji Art
//
//  Created by Samuel He on 2024/8/23.
//

import SwiftUI

struct PaletteChooser: View {
    @EnvironmentObject var store: PaletteStore
    
    var body: some View {
        HStack {
            chooser
            view(for: store.palettes[store.cursorIndex])
        }
        .clipped()
    }
    
    var chooser: some View {
        AnimatedActionButton(systemImage: "paintpalette") {
            store.cursorIndex += 1
        }
        .contextMenu {
            AnimatedActionButton("New", systemImage: "plus") {
                store.insert(name: "Math", emojis: "+−×÷±=∞∩∪")
            }
            AnimatedActionButton("Delete", systemImage: "minus.circle", role: .destructive) {
                store.palettes.remove(at: store.cursorIndex)
            }
        }
        .font(.title)
    }
    
    func view(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
                .font(.title)
            ScrollingEmojis(palette.emojis)
        }
        .id(palette.id)
        .transition(
            .asymmetric(insertion: .move(edge: .bottom),
                        removal: .move(edge: .top))
        )
    }
}

struct ScrollingEmojis: View {
    var emojis: [String]
    
    init(_ emojis: String) {
        let uniquedEmojis = Array(emojis).removingDuplicates().map(String.init)
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
    PaletteChooser()
        .environmentObject(PaletteStore(named: "Preview"))
}
