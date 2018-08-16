//
//  Array+Utils.swift
//  NewsReader
//
//  Created by Ray Tso on 2018/8/15.
//  Copyright © 2018 Ray Tso. All rights reserved.
//

import Foundation

extension Array {
    func groupBy(_ amount: Int) -> [[Element]] {
        var cache = [Element]()
        var result = [[Element]]()
        for (offset, element) in self.enumerated() {
            if offset % amount == 0 && !cache.isEmpty {
                result.append(cache)
                cache = []
            }
            cache.append(element)
        }
        if !cache.isEmpty {
            result.append(cache)
        }
        return result
    }
}
