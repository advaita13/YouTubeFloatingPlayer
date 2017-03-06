//
//  ViewController.swift
//  YouTubePlayer
//
//  Created by Pandya, Advaita on 3/1/17.
//  Copyright © 2017 Pandya, Advaita. All rights reserved.
//

import UIKit
import YouTubeFloatingPlayer

class ViewController: UITableViewController {
    
    let videoIds = ["9_hAGoth6BI", "GkJQ7JziOrc", "pnkS9tlJSf0", "DGt1yBxBw9k", "tL7GJpU9M6Y"]
    let videoTitles = ["Video 1", "Video 2", "Video 3", "Video 4", "Video 5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoIds.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell") as? VideoCell {
            let link = "http://img.youtube.com/vi/\(videoIds[indexPath.row])/0.jpg"
            cell.setup(with: link)
            
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        YTFPlayer.initYTF(videoID: videoIds[indexPath.row], delegate: self, dataSource: self)
        YTFPlayer.showYTFView(viewController: self)
    }
}

