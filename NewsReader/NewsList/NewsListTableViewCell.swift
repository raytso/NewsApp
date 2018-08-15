//
//  NewsListTableViewCell.swift
//  NewsReader
//
//  Created by Ray Tso on 2018/8/15.
//  Copyright © 2018 Ray Tso. All rights reserved.
//

import UIKit

class NewsListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
