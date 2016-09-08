//
//  ZZTag.swift
//  DailyNotes
//
//  Created by Zhicong Zang on 9/8/16.
//  Copyright © 2016 Zhicong Zang. All rights reserved.
//

import Foundation

struct ZZTag: Hashable, Equatable {
    
    let text: String
    
    init(text: String) {
        self.text = text
    }
    
    var hashValue: Int {
        return self.text.hashValue
    }
    
    func equals(other: ZZTag) -> Bool {
        return self.text == other.text
    }
    
    
}

func ==(lhs: ZZTag, rhs: ZZTag) -> Bool {
    return lhs.equals(rhs)
}