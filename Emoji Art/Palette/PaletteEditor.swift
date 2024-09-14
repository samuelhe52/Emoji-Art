//
//  PaletteEditor.swift
//  Emoji Art
//
//  Created by Samuel He on 2024/9/14.
//

import SwiftUI

struct PaletteEditor: View {
    @Binding var palette: Palette
    
    private let emojiFont = Font.system(size: 40)
    @State private var emojisToAdd: String = ""
    @State private var originalEmojis: String
    
    init(palette: Binding<Palette>) {
        _palette = palette
        _originalEmojis = .init(initialValue: palette.wrappedValue.emojis)
    }
    
    enum Focused: Equatable {
        case name
        case emojis
    }
    
    @FocusState private var focused: Focused?
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Name", text: $palette.name)
                    .focused($focused, equals: .name)
            }
            Section(header: Text("Edit Emojis")) {
                addEmojis
                removeEmojis
                HStack {
                    Spacer()
                    AnimatedActionButton("Restore To Original", role: .destructive, action: restoreEmojis)
                    Spacer()
                }
            }
        }
        .onAppear {
            if palette.name.isEmpty {
                focused = .name
            } else {
                focused = .emojis
            }
        }
        .onDisappear {
            if palette.name.isEmpty {
                palette.name = "New"
            }
        }
    }
    
    func restoreEmojis() {
        palette.emojis = originalEmojis
        emojisToAdd.removeAll()
    }
    
    @State private var displayNonEmojiAlert: Bool = false
    
    var addEmojis: some View {
        TextField("Add Emojis Here", text: $emojisToAdd)
            .font(emojiFont)
            .focused($focused, equals: .emojis)
            .onChange(of: emojisToAdd) {
                palette.emojis = (emojisToAdd + palette.emojis)
                    .filter { $0.isEmoji }
                    .removingDuplicates()
                if !emojisToAdd.containsOnlyEmoji && !emojisToAdd.isEmpty {
                    displayNonEmojiAlert = true
                } else {
                    displayNonEmojiAlert = false
                }
            }
            .autocorrectionDisabled()
            .popover(isPresented: $displayNonEmojiAlert) {
                Label("Only emojis are allowed", systemImage: "exclamationmark.triangle")
                    .padding(.horizontal)
                    .foregroundStyle(.red)
            }
    }
    
    var removeEmojis: some View {
        VStack(alignment: .center) {
            HStack {
                Text("Current Emojis")
                Spacer()
                Text("Tap to remove an emoji")
                    .opacity(palette.emojis.isEmpty ? 0 : 1)
            }.font(.caption).foregroundStyle(.gray)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette.emojiArray, id: \.self) { emoji in
                    Text(String(emoji))
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.remove(emoji)
                                emojisToAdd.remove(emoji)
                            }
                        }
                }
            }
        }
        .font(emojiFont)
    }
}

struct Preview: View {
    @State private var palette: Palette =  .builtins.first!
    var body: some View {
        PaletteEditor(palette: $palette)
    }
}

#Preview {
    Preview()
}
