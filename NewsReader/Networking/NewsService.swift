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
    
    private var inflateURL = URL(string: "http://doubleplay-sports-yql.media.yahoo.com/v3/news_items")!
    
    private let concurrentScheduler: ConcurrentDispatchQueueScheduler = ConcurrentDispatchQueueScheduler(queue: .global())
    
    func getItems() -> Observable<[News]> {
        return fetch("items")
            .observeOn(concurrentScheduler)
            .flatMap { [weak self] in
                self?.convert(data: $0) ?? .empty()
            }
    }
    
    func getMore(count: Int = 10) -> Observable<[News]> {
        return fetch("more")
            .observeOn(concurrentScheduler)
            .flatMap { [weak self] in
                self?.fetchUUID(data: $0) ?? .empty()
            }
            .flatMap { [weak self] in
                self?.inflate(ids: $0) ?? .empty()
            }
    }
    
    private func fetch(_ key: String) -> Observable<JSON> {
        return Observable.create({ (observer) -> Disposable in
            Alamofire.request(self.url, method: .get).responseJSON { result in
                if let json = result.data, let data = try? JSON(data: json) {
                    let results = data[key]["result"]
                    observer.onNext(results)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        })
    }
    
    private func inflate(ids: [String]) -> Observable<[News]> {
        let batches: [[String]] = ids.groupBy(10)
        return Observable<[String]>.create({ (observer) -> Disposable in
            batches.forEach { observer.onNext($0) }
            observer.onCompleted()
            return Disposables.create()
        })
        .flatMap { [weak self] in
            return self?.fetch(ids: $0) ?? .empty()
        }
        .take(batches.count)
        .toArray()
        .observeOn(concurrentScheduler)
        .flatMap { [weak self] in
            self?.convert(batch: $0) ?? .empty()
        }
    }
    
    private func fetch(ids: [String]) -> Observable<JSON> {
        return Observable.create({ (observer) -> Disposable in
            let params: [String: Any] = ["uuids": ids.joined(separator: ",")]
            Alamofire.request(self.inflateURL, method: .get, parameters: params).responseJSON { result in
                if let json = result.data, let data = try? JSON(data: json) {
                    let results = data["items"]["result"]
                    observer.onNext(results)
                }
            }
            return Disposables.create()
        })
    }
    
    private func fetchUUID(data: JSON) -> Observable<[String]> {
        return Observable<String>.create({ (observer) -> Disposable in
            if let data = data.array {
                data.forEach {
                    if let uuid = $0["uuid"].string {
                        observer.onNext(uuid)
                    }
                }
            }
            observer.onCompleted()
            return Disposables.create()
        })
        .toArray()
    }
    
    private func convert(data: JSON) -> Observable<[News]> {
        return Observable.create({ (observer) -> Disposable in
            if let items = data.array {
                let news = items.compactMap { News(json: $0) }
                observer.onNext(news)
            }
            observer.onCompleted()
            return Disposables.create()
        })
    }
    
    private func convert(batch: [JSON]) -> Observable<[News]> {
        return Observable<JSON>.create({ (observer) -> Disposable in
            batch.forEach {
                observer.onNext($0)
            }
            observer.onCompleted()
            return Disposables.create()
        })
        .flatMap { [weak self] in self?.convert(data: $0) ?? .empty() }
        .toArray()
        .map { $0.flatMap { $0 } }
    }
}

fileprivate extension News {
    init?(json: JSON) {
        guard let content = json["content"].string,
            let id = json["uuid"].string,
            let title = json["title"].string,
            let publisher = json["publisher"].string,
            let publishedAt = Double(json["published_at"].string ?? ""),
            let link = URL(string: json["link"].string ?? "") else { return nil }
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
