//
//  NewsListTableViewController.swift
//  NewsReader
//
//  Created by Ray Tso on 2018/8/15.
//  Copyright © 2018 Ray Tso. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

class NewsListTableViewController: UITableViewController {
    
    private let disposeBag = DisposeBag()
    
    var service: NewsService = NewsService()
    
    var news: [News] = []
    
    var didLoadMore: Bool = false
    
    private let concurrentScheduler: ConcurrentDispatchQueueScheduler = ConcurrentDispatchQueueScheduler(queue: .global())
    
    private let loadMoreEvent = PublishSubject<Void>()
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        service.getItems()
            .observeOn(concurrentScheduler)
            .map { $0.sorted { $0.publishedAt > $1.publishedAt } }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (news) in
                self?.add(news)
            }).disposed(by: disposeBag)
        
        loadMoreEvent
            .flatMapFirst { Observable.just(()) }
            .subscribe(onNext: { [weak self] _ in
                if self?.didLoadMore == false {
                    self?.loadMore()
                }
            }).disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400.0
        
        tableView.tableFooterView = UIView()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(updateAll), for: .valueChanged)
    }
    
    
    private func loadMore() {
        didLoadMore = true
        service.getMore()
            .observeOn(concurrentScheduler)
            .map { $0.sorted { $0.publishedAt > $1.publishedAt } }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] news in
                self?.add(news)
            }).disposed(by: disposeBag)
    }
    
    private func add(_ contents: [News]) {
        self.news += contents
        self.tableView.reloadData()
    }
    
    private func reload(_ contents: [News]) {
        self.news = contents
        self.tableView.reloadData()
    }
    
    @objc private func updateAll() {
        service.update(keys: news.map { $0.uuid })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] updated in
                self?.reload(updated)
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }).disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return news.count
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
        let bottom = tableView.contentSize.height
        let buffer: CGFloat = 20.0
        if position > bottom + buffer {
            loadMoreEvent.onNext(())
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsListTableViewCell", for: indexPath) as? NewsListTableViewCell else { return UITableViewCell() }
        
        let model = news[indexPath.row]
        
        cell.titleLabel.text = model.title
        cell.subtitleLabel.text = model.publisher
        cell.thumbnailImageView.kf.setImage(with: model.images?.last, placeholder: #imageLiteral(resourceName: "icon_world"))

        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNewsContent" {
            if let viewController = segue.destination as? NewsContentViewController, let cell = sender as? NewsListTableViewCell, let index = tableView.indexPath(for: cell)?.row {
                let content = news[index]
                let data = ContentDisplayable(title: content.title,
                                   content: content.content,
                                   link: content.link)
                    viewController.data = data
            }
        }
    }

}
