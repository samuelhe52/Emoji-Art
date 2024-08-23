//
//  Extensions.swift
//  Emoji Art
//
//  Created by Samuel He on 2024/8/21.
//

import Foundation
import SwiftUI

typealias CGOffset = CGSize

extension CGOffset {
    static func +(lhs: CGOffset, rhs: CGOffset) -> CGOffset {
        CGOffset(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func +=(lhs: inout CGOffset, rhs: CGOffset) {
        lhs = lhs + rhs
    }
}

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

extension Array where Element: Hashable {
    /// - Returns: An `Array` with duplicates removed **and the sequential order of elements preserved.**
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
