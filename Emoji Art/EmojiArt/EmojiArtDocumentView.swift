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
    
    @State private var showBackgroundFailureAlert: Bool = false
    
    // MARK: - Constants
    struct Constants {
        static let paletteEmojiSize: CGFloat = 40
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            HStack {
                PaletteChooser()
                    .font(.system(size: Constants.paletteEmojiSize))
                    .padding(.horizontal)
                trashBin
                    .padding(.trailing)
            }
        }
    }
    
    // MARK: Document Body
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                if document.background.isFetching {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.blue)
                        .position(Emoji.Position.zero.in(geometry))
                }
                documentContent(in: geometry)
                    .scaleEffect(zoom * gestureZoom)
                    .offset(pan + gesturePan)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
            .onTapGesture(count: 2) {
                zoomToFit(document.bbox, in: geometry)
            }
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                return drop(sturldatas, at: location, in: geometry)
            }
            .onChange(of: document.background.failureReason) { _, reason in
                showBackgroundFailureAlert = (reason != nil)
            }
            .onChange(of: document.background.uiImage) { _, image in
                zoomToFit(image?.size, in: geometry)
            }
            .alert("Set Background",
                   isPresented: $showBackgroundFailureAlert,
                   presenting: document.background.failureReason) { _ in
                Button("OK", role: .cancel) { }
            } message: { reason in Text(reason) }
        }
    }
    
    private func zoomToFit(_ size: CGSize?, in geometry: GeometryProxy) {
        if let size {
            zoomToFit(CGRect(center: .zero, size: size), in: geometry)
        }
    }
    
    private func zoomToFit(_ rect: CGRect, in geometry: GeometryProxy) {
        withAnimation {
            if rect.size.width > 0, rect.size.height > 0,
               geometry.size.width > 0, geometry.size.height > 0 {
                let hZoom = geometry.size.width / rect.size.width
                let vZoom = geometry.size.height / rect.size.height
                zoom = min(hZoom, vZoom)
                pan = CGOffset(
                    width: -rect.midX * zoom,
                    height: -rect.midY * zoom
                )
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
    
    // MARK: Document Content
    @ViewBuilder
    private func documentContent(in geometry: GeometryProxy) -> some View {
        if let uiImage = document.background.uiImage {
            Image(uiImage: uiImage)
                .position(Emoji.Position.zero.in(geometry))
        }
        ForEach(document.emojis) { emoji in
            buildEmoji(emoji, in: geometry)
        }
    }
    
    // MARK: Emoji
    @ViewBuilder
    private func buildEmoji(_ emoji: Emoji, in geometry: GeometryProxy) -> some View {
        let selected = isSelected(emoji)
        Text(emoji.string)
            .onTapGesture {
                if selected {
                    selectedEmojiIDs.remove(emoji.id)
                } else {
                    selectedEmojiIDs.insert(emoji.id)
                }
            }
            .border(selected ? Color.red : Color.clear)
            .font(emoji.font)
            .scaleEffect(selected ? emojiGestureZoom : 1)
            .position(emoji.position.in(geometry))
            .offset(emojiGesturePan.pan(for: emoji, selected: selected))
            // Note: Our .gesture() modifier must be placed after any position-shifting modifiers.
            .gesture(emojiPanGesture(draggingUnselectedEmojiID: selected ? nil : emoji.id))
    }
    
    private func isSelected(_ emoji: Emoji) -> Bool {
        return selectedEmojiIDs.contains(emoji.id)
    }
    
    private func deselectAll() {
        selectedEmojiIDs.removeAll()
    }
    
    // MARK: - Zoom and pan
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var emojiGestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero
    @GestureState private var emojiGesturePan: EmojiGesturePan = .init(pan: .zero, panScope: .allSelected)
    
    private struct EmojiGesturePan {
        let pan: CGOffset
        let panScope: PanScope
        
        enum PanScope {
            case allSelected
            case single(Emoji.ID)
        }
        
        /// Determines the current pan for a specific emoji.
        func pan(for emoji: Emoji, selected: Bool) -> CGOffset {
            switch panScope {
            case .allSelected:
                return selected ? pan : .zero
            case .single(let id):
                return id == emoji.id ? pan : .zero
            }
        }
    }
    // MARK: - Gestures
    private var zoomGesture: some Gesture {
        let gesturingOnBackground: Bool = selectedEmojiIDs.isEmpty
        return MagnificationGesture()
            .updating($gestureZoom) { currentPinchScale, gestureZoom, _ in
                if gesturingOnBackground {
                    gestureZoom = currentPinchScale
                }
            }
            .updating($emojiGestureZoom) { currentPinchScale, emojiGestureZoom, _ in
                if !gesturingOnBackground {
                    emojiGestureZoom = currentPinchScale
                }
            }
            .onEnded { endingPinchScale in
                if gesturingOnBackground {
                    zoom *= endingPinchScale
                } else {
                    selectedEmojiIDs.forEach { id in
                        document.resize(emojiWithID: id, by: endingPinchScale)
                    }
                }
            }
    }
    
    // MARK: Pan
    // This gesture should be used when user is dragging on the background
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan) { currentDragGestureValue, gesturePan, _ in
                if selectedEmojiIDs.isEmpty {
                    gesturePan = currentDragGestureValue.translation
                }
            }
            .updating($emojiGesturePan) { currentDragGestureValue, emojiGesturePan, _ in
                if !selectedEmojiIDs.isEmpty {
                    emojiGesturePan = .init(pan: currentDragGestureValue.translation / zoom,
                                            panScope: .allSelected)
                }
            }
            .onEnded { endingDragGestureValue in
                if selectedEmojiIDs.isEmpty {
                    pan += endingDragGestureValue.translation
                } else {
                    selectedEmojiIDs.forEach { id in
                        document.move(emojiWithID: id, by: endingDragGestureValue.translation / zoom)
                    }
                }
            }
    }
    
    // This should be used when the user is dragging on a specific emoji
    /// - Parameters:
    ///     - draggingUnselectedEmojiID: indicates if the user is dragging on an unselected emoji;
    ///      If so, we move that emoji without selecting it. The background would not be moved in this case.
    private func emojiPanGesture(draggingUnselectedEmojiID: Emoji.ID? = nil) -> some Gesture {
        DragGesture()
            .updating($emojiGesturePan) { currentDragGestureValue, emojiGesturePan, _ in
                if let id = draggingUnselectedEmojiID {
                    emojiGesturePan = .init(pan: currentDragGestureValue.translation,
                                            panScope: .single(id))
                } else {
                    emojiGesturePan = .init(pan: currentDragGestureValue.translation,
                                            panScope: .allSelected)
                }
            }
            .onEnded { endingDragGestureValue in
                if let id = draggingUnselectedEmojiID {
                    document.move(emojiWithID: id, by: endingDragGestureValue.translation)
                } else {
                    selectedEmojiIDs.forEach { id in
                        document.move(emojiWithID: id, by: endingDragGestureValue.translation)
                    }
                }
            }
    }
    
    // MARK: - Trash Bin
    // TODO: Use Drag and Drop to delete emojis
    private var trashBin: some View {
        Button {
            document.remove(emojisWithIDs: selectedEmojiIDs)
            selectedEmojiIDs.removeAll()
        } label: {
            Image(systemName: "trash")
                .font(.title)
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environmentObject(PaletteStore(named: "Preview"))
}
