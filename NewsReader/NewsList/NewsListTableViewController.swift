//
//  NewsListTableViewController.swift
//  NewsReader
//
//  Created by Ray Tso on 2018/8/15.
//  Copyright © 2018 Ray Tso. All rights reserved.
//

import UIKit
import RxSwift

class NewsListTableViewController: UITableViewController {
    
    private let disposeBag = DisposeBag()
    
    var service: NewsService = NewsService()
    
    var news: [News] = []
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        service.getItems()
            .subscribe(onNext: { [weak self] (news) in
                guard let weakSelf = self else { return }
                weakSelf.news = news
                weakSelf.tableView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        
        tableView.tableFooterView = UIView()
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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsListTableViewCell", for: indexPath) as? NewsListTableViewCell else { return UITableViewCell() }
        
        let model = news[indexPath.row]
        
        cell.titleLabel.text = model.title
        cell.subtitleLabel.text = model.publisher

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
