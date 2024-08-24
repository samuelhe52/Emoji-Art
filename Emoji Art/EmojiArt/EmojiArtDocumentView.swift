//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by Samuel He on 2024/8/21.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    @State private var selectedEmojiIDs = Set<Emoji.ID>()
    
    struct Constants {
        static let paletteEmojiSize: CGFloat = 40
    }
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser()
                .font(.system(size: Constants.paletteEmojiSize))
                .padding(.horizontal)
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                documentContent(in: geometry)
                    .scaleEffect(zoom * gestureZoom)
                    .offset(pan + gesturePan)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                return drop(sturldatas, at: location, in: geometry)
            }
        }
    }
    
    @ViewBuilder
    private func documentContent(in geometry: GeometryProxy) -> some View {
        AsyncImage(url: document.background)
            .onTapGesture {
                if !selectedEmojiIDs.isEmpty {
                    deselectAll()
                }
            }
            .position(Emoji.Position.zero.in(geometry))
        ForEach(document.emojis) { emoji in
            buildEmoji(emoji, in: geometry)
        }
    }
    
    private func buildEmoji(_ emoji: Emoji, in geometry: GeometryProxy) -> some View {
        Text(emoji.string)
            .onTapGesture {
                if isSelected(emoji) {
                    selectedEmojiIDs.remove(emoji.id)
                } else {
                    selectedEmojiIDs.insert(emoji.id)
                }
            }
            .border(isSelected(emoji) ? Color.red : Color.clear)
            .font(emoji.font)
            .scaleEffect(isSelected(emoji) ? emojiGestureZoom : 1)
            .position(emoji.position.in(geometry))
            .offset(isSelected(emoji) ? emojiGesturePan: .zero)
            // Note: Our .gesture() modifier must be placed after any position-shifting modifiers.
            .gesture(isSelected(emoji) ? emojiPanGesture : nil)
    }
    
    private func isSelected(_ emoji: Emoji) -> Bool {
        return selectedEmojiIDs.contains(emoji.id)
    }
    
    private func deselectAll() {
        selectedEmojiIDs.removeAll()
    }
    
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var emojiGestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero
    @GestureState private var emojiGesturePan: CGOffset = .zero
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom) { currentPinchScale, gestureZoom, _ in
                if selectedEmojiIDs.isEmpty {
                    gestureZoom = currentPinchScale
                }
            }
            .updating($emojiGestureZoom) { currentPinchScale, emojiGestureZoom, _ in
                if !selectedEmojiIDs.isEmpty {
                    emojiGestureZoom = currentPinchScale
                }
            }
            .onEnded { endingPinchScale in
                if selectedEmojiIDs.isEmpty {
                    zoom *= endingPinchScale
                } else {
                    selectedEmojiIDs.forEach { id in
                        document.resize(emojiWithID: id, by: endingPinchScale)
                    }
                }
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan) { currentDragGestureValue, gesturePan, _ in
                gesturePan = currentDragGestureValue.translation
            }
            .onEnded { endingDragGestureValue in
                pan += endingDragGestureValue.translation
            }
    }
    
    private var emojiPanGesture: some Gesture {
        DragGesture()
            .updating($emojiGesturePan) { currentDragGestureValue, emojiGesturePan, _ in
                emojiGesturePan = currentDragGestureValue.translation
            }
            .onEnded { endingDragGestureValue in
                selectedEmojiIDs.forEach { id in
                    document.move(emojiWithID: id, by: endingDragGestureValue.translation)
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
                    at: .init(at: location, in: geometry, pan: pan, zoom: zoom)
                )
                return true
            default:
                break
            }
        }
        return false
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environmentObject(PaletteStore(named: "Preview"))
}
