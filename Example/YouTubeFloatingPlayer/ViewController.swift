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
    
    let videoIds = ["f0NdOE5GTgo", "2q906bSLEkw", "xQ_IQS3VKjA"]
    let videoTitles = ["Blank Details View", "Custom Details View", "TableView"]
    
    var shouldHideStatusBar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        YTFPlayer.delegate = self
        tableView.register(UINib(nibName: "VideoCell", bundle: Bundle.main), forCellReuseIdentifier: "videoCell")
    }
    
    override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
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
            cell.setup(with: link, title: videoTitles[indexPath.row])
            
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            YTFPlayer.initYTF(with: UIView(), videoID: videoIds[indexPath.row])
        case 1:
            let view = UIView()
            view.backgroundColor = UIColor.orange
            YTFPlayer.initYTF(with: view, videoID: videoIds[indexPath.row])
        case 2:
            YTFPlayer.initYTF(with: tableView, tableCellNibName: "VideoCell", tableCellReuseIdentifier: "videoCell", videoID: videoIds[indexPath.row])
        default:
            YTFPlayer.initYTF(with: UIView(), videoID: videoIds[indexPath.row])
        }
        
        YTFPlayer.showYTFView(viewController: self)
    }
}

extension ViewController: YTFPlayerDelegate {
    
    func playerStateChanged(to playerState: YTFPlayerViewState) {
        shouldHideStatusBar = playerState != .minimized
        self.setNeedsStatusBarAppearanceUpdate()
    }
}

