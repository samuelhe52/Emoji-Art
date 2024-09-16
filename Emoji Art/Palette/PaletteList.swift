//
//  PaletteList.swift
//  Emoji Art
//
//  Created by Samuel He on 2024/9/15.
//

import SwiftUI

struct EditablePaletteList: View {
    @ObservedObject var store: PaletteStore
    @State private var showCursorPalette: Bool = false
    
    var body: some View {
        List {
            ForEach(store.palettes) { palette in
                NavigationLink(value: palette.id) {
                    VStack(alignment: .leading) {
                        Text(palette.name)
                        Text(palette.emojis).lineLimit(1)
                    }
                    .contextMenu {
                        Button {
                            store.cursorIndex = store.palettes.firstIndex(of: palette)!
                            showCursorPalette = true
                        } label: {
                            Text("Edit")
                        }
                        Button(role: .destructive) {
                            withAnimation {
                                store.palettes.removeAll(where: { $0.id == palette.id })
                            }
                        } label: {
                            Text("Delete")
                        }
                    }
                }
            }
            .onDelete { indexSet in
                withAnimation {
                    store.palettes.remove(atOffsets: indexSet)
                }
            }
            .onMove { indexSet, newOffset in
                withAnimation {
                    store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
        }
        .navigationDestination(for: Palette.ID.self) { paletteID in
            if let index = store.palettes.firstIndex(where: { $0.id == paletteID }) {
                PaletteEditor(palette: $store.palettes[index])
                    .id(paletteID)
            }
        }
        .navigationDestination(isPresented: $showCursorPalette) {
            PaletteEditor(palette: $store.palettes[store.cursorIndex])
                .id(store.palettes[store.cursorIndex].id)
        }
        .navigationTitle("\(store.name) Palettes")
        .toolbar {
            Button {
                store.insert(Palette(name: "", emojis: ""))
                showCursorPalette = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

struct PaletteView: View {
    let palette: Palette
    
    var body: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette
                    .emojiArray
                    .removingDuplicates()
                    .map(String.init), id: \.self) { emoji in
                    NavigationLink(value: emoji) {
                        Text(emoji)
                    }
                }
            }
            .navigationDestination(for: String.self) { emoji in
                Text(emoji).font(.system(size: 300))
            }
            Spacer()
        }
        .padding()
        .font(.largeTitle)
        .navigationTitle(palette.name)
    }
}
