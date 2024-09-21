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
                    paletteItem(palette: palette)
                }
            }
            .onDelete { indexSet in
                withAnimation { store.palettes.remove(atOffsets: indexSet) }
            }
            .onMove { indexSet, newOffset in
                withAnimation { store.palettes.move(fromOffsets: indexSet, toOffset: newOffset) }
            }
        }
        .navigationDestination(for: Palette.ID.self) { paletteID in
            if let index = store.palettes.firstIndex(where: { $0.id == paletteID }) {
                PaletteEditor(palette: $store.palettes[index])
                    .id(paletteID)
                // .id() ensures that the Editoe be recreated upon change of palette,
                // which ensures that the originalEmojis will be properly updated.
            }
        }
        .navigationDestination(isPresented: $showCursorPalette) {
            PaletteEditor(palette: $store.palettes[store.cursorIndex])
                .id(store.palettes[store.cursorIndex].id)
        }
        .navigationTitle("\(store.name) Palettes")
        .toolbar { toolbar }
    }
    
    private func paletteItem(palette: Palette) -> some View {
        VStack(alignment: .leading) {
            Text(palette.name)
            Text(palette.emojis).lineLimit(1)
        }
        .contextMenu {
            contextMenu(palette)
        }
    }
    
    private var toolbar: some View {
        Group {
            Button {
                store.insert(Palette(name: "", emojis: ""))
                showCursorPalette = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    private func contextMenu(_ palette: Palette) -> some View {
        Group {
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
