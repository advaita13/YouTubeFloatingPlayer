//
//  YTDAnimation.swift
//  YTDraggablePlayer
//
//  Created by Ana Paula on 6/6/16.
//  Copyright © 2016 Ana Paula. All rights reserved.
//

import UIKit

enum UIPanGestureRecognizerDirection {
    case Undefined
    case Up
    case Down
    case Left
    case Right
}

extension YTFViewController {
    
    //MARK: Utility Functions
    
    public func setHideTimer() {
        
        hideTimer?.invalidate()
        hideTimer = nil
        hideTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(YTFViewController.hidePlayerControls(dontAnimate:)), userInfo: 1.0, repeats: false)
    }
    
    public func resetHideTimer() {
        
        if hideTimer != nil {
            hideTimer?.invalidate()
            hideTimer = nil
        }
    }
    
    //MARK: Player Controls Animations
    
    func showPlayerControls() {
        
        if (!isMinimized) {
            UIView.animate(withDuration: 0.6, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.backPlayerControlsView.alpha = 0.55
                self.playerControlsView.alpha = 1.0
                self.minimizeButton.alpha = 1.0
                
                }, completion: nil)
            setHideTimer()
        }
    }
    
    public func hidePlayerControls(dontAnimate: Bool) {
        
        if (dontAnimate) {
            self.backPlayerControlsView.alpha = 0.0
            self.playerControlsView.alpha = 0.0
        } else {
            if (isPlaying) {
                UIView.animate(withDuration: 0.6, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.backPlayerControlsView.alpha = 0.0
                    self.playerControlsView.alpha = 0.0
                    self.minimizeButton.alpha = 0.0
                    
                    }, completion: nil)
            }
        }
    }
    
    //MARK: Video Animations
    
    func setPlayerToFullscreen() {
        
        let rotationAngle = CGFloat(currentDeviceOrientation() == .landscapeRight ? -Double.pi / 2 : Double.pi / 2)
        
        self.hidePlayerControls(dontAnimate: true)
        self.videoView.isHidden = true
        
        let playerAnimation = {
            guard let initialFrame = self.initialFirstViewFrame else {
                return
            }
            
            self.minimizeButton.isHidden = true
            self.playerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
            self.playerView.frame = initialFrame
        }
        
        let playerCompletion: (Bool) -> () = { finished in
            self.isFullscreen = true
            self.videoView.isHidden = false
            self.initFullscreenView()
            self.playerDelegate?.playerStateChanged(to: .fullscreen)
        }
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: playerAnimation,
                       completion: playerCompletion)
    }
    
    func setPlayerToNormalScreen() {
        
        guard let webView = ytfFullscreenViewController?.webView else {
            return
        }
        
        webView.frame = self.videoView.frame
        videoView.addSubview(webView)
        videoView.delegate = self
        
        let playerAnimation = {
            guard let playerFrame = self.playerViewFrame else {
                return
            }
            
            self.playerView.transform = CGAffineTransform(rotationAngle: 0)
            self.playerView.frame = playerFrame
        }
        
        let playerCompletion: (Bool) -> () = { finished in
            self.isFullscreen = false
            self.fullscreen.setImage(self.fullscreenImage, for: UIControlState.normal)
            self.playerDelegate?.playerStateChanged(to: .expanded)
        }
        
        let fullScreenDismissCompletion = {
            self.ytfFullscreenViewController = nil
            
            UIView.animate(withDuration: 0.25,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: playerAnimation,
                           completion: playerCompletion)
        }
        
        ytfFullscreenViewController?.dismiss(animated: false, completion: fullScreenDismissCompletion)
    }
    
    func panAction(recognizer: UIPanGestureRecognizer) {
        
        if (!isFullscreen) {
            let yPlayerLocation = recognizer.location(in: self.view?.window).y
            isExpanded = false
            
            switch recognizer.state {
            case .began:
                onRecognizerStateBegan(yPlayerLocation: yPlayerLocation, recognizer: recognizer)
                break
            case .changed:
                onRecognizerStateChanged(yPlayerLocation: yPlayerLocation, recognizer: recognizer)
                break
            default:
                onRecognizerStateEnded(yPlayerLocation: yPlayerLocation, recognizer: recognizer)
            }
        }
    }
    
    func onRecognizerStateBegan(yPlayerLocation: CGFloat, recognizer: UIPanGestureRecognizer) {
        
        tableViewContainer.backgroundColor = UIColor.white
        hidePlayerControls(dontAnimate: true)
        panGestureDirection = UIPanGestureRecognizerDirection.Undefined
        
        let velocity = recognizer.velocity(in: recognizer.view)
        detectPanDirection(velocity: velocity)
        
        touchPositionStartY = recognizer.location(in: self.playerView).y
        touchPositionStartX = recognizer.location(in: self.playerView).x
        
    }
    
    func onRecognizerStateChanged(yPlayerLocation: CGFloat, recognizer: UIPanGestureRecognizer) {
        
        if (panGestureDirection == UIPanGestureRecognizerDirection.Down ||
            panGestureDirection == UIPanGestureRecognizerDirection.Up) {
            let trueOffset = yPlayerLocation - touchPositionStartY!
            let xOffset = trueOffset * 0.35
            adjustViewOnVerticalPan(yPlayerLocation: yPlayerLocation, trueOffset: trueOffset, xOffset: xOffset, recognizer: recognizer)
            
        } else {
            adjustViewOnHorizontalPan(recognizer: recognizer)
        }
    }
    
    func onRecognizerStateEnded(yPlayerLocation: CGFloat, recognizer: UIPanGestureRecognizer) {
        
        if (panGestureDirection == UIPanGestureRecognizerDirection.Down ||
            panGestureDirection == UIPanGestureRecognizerDirection.Up) {
            if (self.view.frame.origin.y < 0) {
                expandViews()
                recognizer.setTranslation(CGPoint(x: 0, y: 0), in: recognizer.view)
                return
                
            } else {
                if (self.view.frame.origin.y > (initialFirstViewFrame!.size.height / 2)) {
                    minimizeViews()
                    recognizer.setTranslation(CGPoint(x: 0, y: 0), in: recognizer.view)
                    return
                } else {
                    expandViews()
                    recognizer.setTranslation(CGPoint(x: 0, y: 0), in: recognizer.view)
                }
            }
            
        } else if (panGestureDirection == UIPanGestureRecognizerDirection.Left) {
            
            if (tableViewContainer.alpha <= 0) {
                if ((self.view?.frame.origin.x)! < CGFloat(0)) {
                    removeViews()
                    
                } else {
                    animateViewToRightOrLeft(recognizer: recognizer)
                    
                }
            }
            
        } else {
            if (tableViewContainer.alpha <= 0) {
                
                if ((self.view?.frame.origin.x)! > initialFirstViewFrame!.size.width - 50) {
                    removeViews()
                    
                } else {
                    animateViewToRightOrLeft(recognizer: recognizer)
                    
                }
                
            }
            
        }
    }
    
    func detectPanDirection(velocity: CGPoint) {
        
        minimizeButton.isHidden = true
        let isVerticalGesture = fabs(velocity.y) > fabs(velocity.x)
        
        if (isVerticalGesture) {
            
            if (velocity.y > 0) {
                panGestureDirection = UIPanGestureRecognizerDirection.Down
            } else {
                panGestureDirection = UIPanGestureRecognizerDirection.Up
            }
            
        } else {
            
            if (velocity.x > 0) {
                panGestureDirection = UIPanGestureRecognizerDirection.Right
            } else {
                panGestureDirection = UIPanGestureRecognizerDirection.Left
            }
        }
    }
    
    func adjustViewOnVerticalPan(yPlayerLocation: CGFloat, trueOffset: CGFloat, xOffset: CGFloat, recognizer: UIPanGestureRecognizer) {
        
        let percentage = (yPlayerLocation + 200) / self.initialFirstViewFrame!.size.height
        
        if xOffset < 0 {
            return
        } else if (Float(trueOffset) >= (restrictTrueOffset! + 60) ||
            Float(xOffset) >= (restrictOffset! + 60)) {
            
            let trueOffset = initialFirstViewFrame!.size.height - 140
            let xOffset = initialFirstViewFrame!.size.width - 200
            
            //Use this offset to adjust the position of your view accordingly
            viewMinimizedFrame?.origin.y = trueOffset
            viewMinimizedFrame?.origin.x = xOffset - 6 * percentage
            viewMinimizedFrame?.size.width = initialFirstViewFrame!.size.width
            
            playerViewMinimizedFrame!.size.width = self.view.bounds.size.width - xOffset
            playerViewMinimizedFrame!.size.height = playerViewMinimizedFrame!.size.width * 9.0 / 16.0
            
            UIView.animate(withDuration: 0.05, delay: 0.0, options: .curveEaseInOut, animations: {
                self.playerView.frame = self.playerViewMinimizedFrame!
                self.view.frame = self.viewMinimizedFrame!
                self.tableViewContainer.alpha = 0.0
                }, completion: { finished in
                    self.isMinimized = true
                    self.isExpanded = false
            })
            recognizer.setTranslation(CGPoint(x: 0, y: 0), in: recognizer.view)
            
        } else {

            if trueOffset < 20.0 {
                if !shouldHideStatusBar {
                    playerDelegate?.playerStateChanged(to: .expanded)
                }
                shouldHideStatusBar = true
            } else {
                if shouldHideStatusBar {
                    playerDelegate?.playerStateChanged(to: .minimized)
                }
                shouldHideStatusBar = false
            }
            
            //Use this offset to adjust the position of your view accordingly
            viewMinimizedFrame?.origin.y = trueOffset
            viewMinimizedFrame?.origin.x = xOffset - 6 * percentage
            viewMinimizedFrame?.size.width = initialFirstViewFrame!.size.width
            
            playerViewMinimizedFrame!.size.width = self.view.bounds.size.width - xOffset
            playerViewMinimizedFrame!.size.height = playerViewMinimizedFrame!.size.width * 9.0 / 16.0
            
            let restrictY = initialFirstViewFrame!.size.height - playerView!.frame.size.height - 10
            
            if (self.detailsView.frame.origin.y < restrictY && self.detailsView.frame.origin.y > 0) {
                UIView.animate(withDuration: 0.09, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.playerView.frame = self.playerViewMinimizedFrame!
                    self.view.frame = self.viewMinimizedFrame!
                    
                    self.tableViewContainer.alpha = 1.0 - percentage
                    self.transparentView!.alpha = 1.0 - percentage
                    
                    }, completion: { finished in
                        if (self.panGestureDirection == UIPanGestureRecognizerDirection.Down) {
                            self.onView?.bringSubview(toFront: self.view)
                        }
                })
                
            } else if (viewMinimizedFrame!.origin.y < restrictY && viewMinimizedFrame!.origin.y > 0) {
                UIView.animate(withDuration: 0.09, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.playerView.frame = self.playerViewMinimizedFrame!
                    self.view.frame = self.viewMinimizedFrame!
                    
                    }, completion: nil)
            }
            
            recognizer.setTranslation(CGPoint(x: 0, y: 0), in: recognizer.view)
        }
    }
    
    func adjustViewOnHorizontalPan(recognizer: UIPanGestureRecognizer) {
        
        let x = self.view.frame.origin.x
        
        if (panGestureDirection == UIPanGestureRecognizerDirection.Left ||
            panGestureDirection == UIPanGestureRecognizerDirection.Right) {
            if (self.tableViewContainer.alpha <= 0) {
                let velocity = recognizer.velocity(in: recognizer.view)
                
                let isVerticalGesture = fabs(velocity.y) > fabs(velocity.x)
                
                let translation = recognizer.translation(in: self.view)
                self.view?.center = CGPoint(x: self.view!.center.x + translation.x, y: self.view!.center.y)
                
                if (!isVerticalGesture) {
                    recognizer.view?.alpha = detectHorizontalPanRecognizerViewAlpha(x: x, velocity: velocity, recognizer: recognizer)
                }
                recognizer.setTranslation(CGPoint(x: 0, y: 0), in: recognizer.view)
            }
            
        }
    }
    
    func detectHorizontalPanRecognizerViewAlpha(x: CGFloat, velocity: CGPoint, recognizer: UIPanGestureRecognizer) -> CGFloat {
        
        let percentage = x / self.initialFirstViewFrame!.size.width
        
        if (panGestureDirection == UIPanGestureRecognizerDirection.Left) {
            return percentage
            
        } else {
            if (velocity.x > 0) {
                return 1.0 - percentage
            } else {
                return percentage
            }
        }
    }
    
    func animateViewToRightOrLeft(recognizer: UIPanGestureRecognizer) {
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.frame = self.viewMinimizedFrame!
            self.playerView!.frame = self.playerViewFrame!
            self.playerView.frame = CGRect(x: self.playerView!.frame.origin.x, y: self.playerView!.frame.origin.x, width: self.playerViewMinimizedFrame!.size.width, height: self.playerViewMinimizedFrame!.size.height)
            self.tableViewContainer!.alpha = 0.0
            self.playerView.alpha = 1.0
            
            }, completion: nil)
        
        recognizer.setTranslation(CGPoint(x: 0, y: 0), in: recognizer.view)
        
    }
    
    func minimizeViews() {
        tableViewContainer.backgroundColor = UIColor.white
        minimizeButton.isHidden = true
        hidePlayerControls(dontAnimate: true)
        let trueOffset = initialFirstViewFrame!.size.height - 140
        let xOffset = initialFirstViewFrame!.size.width - 200
        
        viewMinimizedFrame!.origin.y = trueOffset + 2
        viewMinimizedFrame!.origin.x = xOffset - 6
        viewMinimizedFrame!.size.width = initialFirstViewFrame!.size.width
        
        playerViewMinimizedFrame!.size.width = self.view.bounds.size.width - xOffset
        playerViewMinimizedFrame!.size.height = playerViewMinimizedFrame!.size.width / (16/9)
        shouldHideStatusBar = false
        playerDelegate?.playerStateChanged(to: .minimized)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.playerView.frame = self.playerViewMinimizedFrame!
            self.view.frame = self.viewMinimizedFrame!
            
            self.playerView.layer.borderWidth = 1
            self.playerView.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 0.5).cgColor
            
            self.tableViewContainer.alpha = 0.0
            self.transparentView?.alpha = 0.0
            }, completion: { finished in
                self.isMinimized = true
                self.isExpanded = false
                
                if let playerGesture = self.playerTapGesture {
                    self.playerView.removeGestureRecognizer(playerGesture)
                }
                self.playerTapGesture = nil
                self.playerTapGesture = UITapGestureRecognizer(target: self, action: #selector(YTFViewController.expandViews))
                self.playerView.addGestureRecognizer(self.playerTapGesture!)
                
                self.view.frame.size.height = self.playerView.frame.height
        })
    }
    
    func expandViews() {
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            self.playerView.frame = self.playerViewFrame!
            self.videoView.frame = self.playerView.frame
            self.view.frame = self.initialFirstViewFrame!
            self.playerView.alpha = 1.0
            self.tableViewContainer.alpha = 1.0
            self.transparentView?.alpha = 1.0
            }, completion: { finished in
                self.isMinimized = false
                self.isExpanded = true
                self.minimizeButton.isHidden = false
                self.playerDelegate?.playerStateChanged(to: .expanded)
                if let playerGesture = self.playerTapGesture {
                    self.playerView.removeGestureRecognizer(playerGesture)
                    self.playerTapGesture = nil
                }
                self.playerTapGesture = UITapGestureRecognizer(target: self, action: #selector(YTFViewController.showPlayerControls))
                self.playerView.addGestureRecognizer(self.playerTapGesture!)
                self.tableViewContainer.backgroundColor = UIColor.black
                self.showPlayerControls()
                self.shouldHideStatusBar = true
                self.playerDelegate?.playerStateChanged(to: .expanded)
        })
    }
    
    func finishViewAnimated(animated: Bool) {
        
        if (animated) {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                self.view.frame = CGRect(x: 0.0, y: self.view!.frame.origin.y, width: self.view!.frame.size.width, height: self.view!.frame.size.height)
                self.view.alpha = 0.0
                
                }, completion: { finished in
                    self.removeViews()
            })
        } else {
            removeViews()
        }
    }
    
    func removeViews() {
        
        resetHideTimer()
        
        self.view.removeFromSuperview()
        self.playerView.removeFromSuperview()
        self.detailsView.removeFromSuperview()
        self.tableViewContainer.removeFromSuperview()
        self.transparentView?.removeFromSuperview()
        self.playerControlsView.removeFromSuperview()
        self.backPlayerControlsView.removeFromSuperview()
        
        dragViewController = nil
    }
    
}
