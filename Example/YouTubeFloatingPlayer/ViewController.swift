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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell") {
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        YTFPlayer.initYTF(videoID: "ROEIKn8OsGU", delegate: self, dataSource: self)
        YTFPlayer.showYTFView(viewController: self)
    }
}

