//
//  ArrayExtension.swift
//  EmoChat
//
//  Created by Admin on 21.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

extension Array {
    
    mutating func rearrange(from: Int, to: Int) {
        if from == to {
            return
        }
        precondition(from != to && indices.contains(from) && indices.contains(to), "invalid indexes")
        insert(remove(at: from), at: to)
        
    }
    
    
    /*
     Usage:
     let newElement = "c"
     let index = myArray.insertionIndexOf(newElement) { $0 < $1 } // Or: myArray.indexOf(c, <)
     myArray.insert(newElement, atIndex: index)
    */
    func insertionIndexOf(elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
}
