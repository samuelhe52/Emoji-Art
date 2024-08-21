//
//  Extensions.swift
//  Emoji Art
//
//  Created by Samuel He on 2024/8/21.
//

import Foundation

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    
    init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPoint(x: center.x - size.width / 2,
                                  y: center.y - size.height / 2),
                  size: size)
    }
}
