//
//  NewsService.swift
//  NewsReader
//
//  Created by Ray Tso on 2018/8/15.
//  Copyright © 2018 Ray Tso. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import SwiftyJSON

class NewsService {
    private var url: URL = URL(string: "http://doubleplay-sports-yql.media.yahoo.com/v3/sports_news?leagues=sports&stream_type=headlines&count=10&region=US&lang=en-US")!
    
//    private let jsonDecoder: JSONDecoder
//
//    init() {
//        self.jsonDecoder = JSONDecoder()
//        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
//    }
    
    func getItems() -> Observable<[News]> {
        return fetch()
            .flatMap { [weak self] in
                self?.convert(data: $0) ?? .empty()
            }
    }
    
    func getMore(count: Int) -> Observable<[News]> {
        return .empty()
    }
    
    private func fetch() -> Observable<JSON> {
        return Observable.create({ (observer) -> Disposable in
            Alamofire.request(self.url, method: .get).responseJSON { result in
                if let json = result.data, let data = try? JSON(data: json) {
                    let results = data["items"]["result"]
                    observer.onNext(results)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        })
    }
    
    private func convert(data: JSON) -> Observable<[News]> {
        return Observable.create({ (observer) -> Disposable in
            if let items = data.array {
                let news = items.compactMap { News(json: $0) }
                observer.onNext(news)
                observer.onCompleted()
            }
            return Disposables.create()
        })
    }
}

fileprivate extension News {
    init?(json: JSON) {
        guard let content = json["content"].string,
            let id = json["uuid"].string,
            let title = json["title"].string,
            let publisher = json["publisher"].string,
            let publishedAt = json["published_at"].double,
            let link = json["link"].url else { return nil }
        self.uuid = id
        self.content = content
        self.title = title
        self.publisher = publisher
        self.publishedAt = publishedAt
        self.link = link
        self.summary = json["summary"].string
        var images: [URL] = []
        let main = json["original_url"].url
        let others: [URL] = json["resolutions"].array?.compactMap { $0["url"].url } ?? []
        if main == nil {
            images = others
        } else {
            images = [main!] + others
        }
        self.images = images
    }
}
