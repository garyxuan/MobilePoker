//
//  Clamp.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import Foundation

func clamp<T: Comparable>(_ value: T, _ min: T, _ max: T) -> T {
    if value < min { return min }
    if value > max { return max }
    return value
}

