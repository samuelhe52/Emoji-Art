//
//  PaletteManager.swift
//  Emoji Art
//
//  Created by Samuel He on 2024/9/15.
//

import SwiftUI

struct PaletteManager: View {
    let stores: [PaletteStore]
    
    @State var selectedStore: PaletteStore?
    
    var body: some View {
        NavigationSplitView {
            List(stores, selection: $selectedStore) { store in
                PaletteStoreView(store: store)
                    .tag(store)
            }
        } content: {
            if let selectedStore {
                EditablePaletteList(store: selectedStore)
            } else {
                Text("Choose a store")
            }
        } detail: {
            Text("Choose a palette")
        }
    }
}

fileprivate struct PaletteStoreView: View {
    @ObservedObject var store: PaletteStore
    
    var body: some View {
        Text(store.name)
    }
}
