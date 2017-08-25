//
//  YTDProtocol.swift
//  YTDraggablePlayer
//
//  Created by Ana Paula on 6/6/16.
//  Copyright © 2016 Ana Paula. All rights reserved.
//

import UIKit

public struct YTFPlayer {
    
    public static var delegate: YTFPlayerDelegate?
    
    public static func initYTF(with tableView: UITableView, tableCellNibName: String, tableCellReuseIdentifier: String, videoID: String) {
        
        if dragViewController == nil {
            let bundle = Bundle(identifier: "org.cocoapods.YouTubeFloatingPlayer")
            if let pathForAssetBundle = bundle?.path(forResource: "YouTubeFloatingPlayer", ofType: "bundle") {
                if let resourceBundle = Bundle(path: pathForAssetBundle) {
                    dragViewController = YTFViewController(nibName: "YTFViewController", bundle: resourceBundle)
                }
            }
            
            dragViewController?.videoID = videoID
            dragViewController?.delegate = tableView.delegate
            dragViewController?.dataSource = tableView.dataSource
            dragViewController?.tableCellNibName = tableCellNibName
            dragViewController?.tableCellReuseIdentifier = tableCellReuseIdentifier
        } else  {
            if dragViewController?.videoID != videoID {
                dragViewController?.videoID = videoID
                dragViewController?.cuePlayerVideo()
            }
            
            dragViewController?.customView = nil
            dragViewController?.delegate = tableView.delegate
            dragViewController?.dataSource = tableView.dataSource
            dragViewController?.tableCellNibName = tableCellNibName
            dragViewController?.tableCellReuseIdentifier = tableCellReuseIdentifier
            dragViewController?.initDetailsView()
            
            dragViewController?.expandViews()
        }
        
        dragViewController?.playerDelegate = delegate
    }
    
    public static func initYTF(with customView: UIView, videoID: String) {
        
        if dragViewController == nil {
            let bundle = Bundle(identifier: "org.cocoapods.YouTubeFloatingPlayer")
            if let pathForAssetBundle = bundle?.path(forResource: "YouTubeFloatingPlayer", ofType: "bundle") {
                if let resourceBundle = Bundle(path: pathForAssetBundle) {
                    dragViewController = YTFViewController(nibName: "YTFViewController", bundle: resourceBundle)
                }
            }
            
            dragViewController?.videoID = videoID
            dragViewController?.customView = customView
        } else {
            if dragViewController?.videoID != videoID {
                dragViewController?.videoID = videoID
                dragViewController?.cuePlayerVideo()
            }
            
            dragViewController?.delegate = nil
            dragViewController?.customView = customView
            dragViewController?.initDetailsView()
            
            dragViewController?.expandViews()
        }
        
        dragViewController?.playerDelegate = delegate
    }
    
    public static func showYTFView(viewController: UIViewController) {
        
        if dragViewController!.isOpen == false {
            dragViewController!.view.frame = CGRect(x: viewController.view.frame.size.width, y: viewController.view.frame.size.height, width: viewController.view.frame.size.width, height: viewController.view.frame.size.height)
            dragViewController!.view.alpha = 0
            dragViewController!.view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            dragViewController!.onView = viewController.view
            
            UIApplication.shared.keyWindow?.addSubview(dragViewController!.view)
            UIView.animate(withDuration: 0.5, animations: {
                dragViewController!.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                dragViewController!.view.alpha = 1
                
                dragViewController!.view.frame = CGRect(x: 0, y: 0, width: UIApplication.shared.keyWindow!.bounds.width, height: UIApplication.shared.keyWindow!.bounds.height)
                
                dragViewController!.isOpen = true
            }, completion: { completed in
                dragViewController!.transparentView?.alpha = 1.0
                self.delegate?.playerStateChanged(to: .expanded)
            })
        }
    }
        
    public static func isOpen() -> Bool {
        return dragViewController?.isOpen == true ? true : false
    }
    
    public static func getYTFViewController() -> UIViewController? {
        return dragViewController
    }
    
    public static func finishYTFView(animated: Bool) {
        
        if(dragViewController != nil) {
            dragViewController?.isOpen = false
            dragViewController?.finishViewAnimated(animated: animated)
        }
    }
}

var dragViewController: YTFViewController?
