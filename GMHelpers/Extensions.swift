//
//  Extensions.swift
//  GMHelpers
//
//  Created by Evangelos Pittas on 24/06/16.
//

import Foundation
import UIKit

extension String {
    var length: Int {
        return self.characters.count
    }
    
    func toInt() -> Int? {
        return Int(self)
    }
    
    func toFloat() -> Float? {
        return Float(self)
    }
    
    func toDouble() -> Double? {
        return Double(self)
    }
}