//
//  VideoCell.swift
//  YouTubeFloatingPlayer
//
//  Created by Pandya, Advaita on 3/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {
    
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func setup(with link: String, title: String) {
        videoImage.downloadedFrom(link: link)
        titleLabel.text = title
    }
    
}
