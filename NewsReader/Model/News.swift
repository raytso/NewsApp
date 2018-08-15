//
//  News.swift
//  NewsReader
//
//  Created by Ray Tso on 2018/8/15.
//  Copyright © 2018 Ray Tso. All rights reserved.
//

import Foundation

struct News {
    let uuid: String
    let title: String
    let content: String
    let summary: String?
    let images: [URL]?
    let publisher: String
    let publishedAt: TimeInterval
    let link: URL
}
