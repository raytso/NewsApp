//
//  NewsContentViewController.swift
//  NewsReader
//
//  Created by Ray Tso on 2018/8/15.
//  Copyright © 2018 Ray Tso. All rights reserved.
//

import UIKit

protocol ContentDisplayableProtocol {
    var title: String { get }
    var content: String { get }
    var link: URL? { get }
}

struct ContentDisplayable: ContentDisplayableProtocol {
    var title: String
    var content: String
    var link: URL?
}

class NewsContentViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    var data: ContentDisplayableProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = data?.title
        
        contentLabel.text = data?.content
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
