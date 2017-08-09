//
//  YTFFullScreenViewController.swift
//  Pods
//
//  Created by Pandya, Advaita on 2017/08/01.
//
//

import UIKit
import youtube_ios_player_helper

class YTFFullscreenViewController: UIViewController {
    
    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var fullscreen: UIButton!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playerControlsView: UIView!
    @IBOutlet weak var backPlayerControlsView: UIView!
    @IBOutlet weak var slider: CustomSlider!
    @IBOutlet weak var progress: CustomProgress!
    @IBOutlet weak var entireTimeLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    var playerTapGesture: UITapGestureRecognizer?
    
    var ytPlayerView: YTPlayerView?
    var webView: UIWebView?
    
    var isOpen: Bool = false
    var isPlaying: Bool = false
    var isFullscreen: Bool = false
    var sliderValueChanged: Bool = false
    var isMinimized: Bool = false
    
    var hideTimer: Timer?
    
    var playImage: UIImage?
    var pauseImage: UIImage?
    var fullscreenImage: UIImage?
    var unfullscreenImage: UIImage?
    var minimizeImage: UIImage?
    
    var ytfViewController: YTFViewController?
    
    var orientation = UIInterfaceOrientationMask.landscapeRight
    var shouldHideStatusBar = true
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return orientation
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ytPlayerView?.delegate = self
        setupGestureRecognizer()
        setupImageAssets()
        showPlayerControls()
        setupSlider(with: (ytPlayerView?.duration())!)
    }
    
    func setupGestureRecognizer() {
        self.webView?.isUserInteractionEnabled = false
        self.playerTapGesture = UITapGestureRecognizer(target: self, action: #selector(showPlayerControls))
        self.playerView.addGestureRecognizer(self.playerTapGesture!)
    }
    
    func setupImageAssets() {
        
        let bundle = Bundle(identifier: "org.cocoapods.YouTubeFloatingPlayer")
        if let pathForAssetBundle = bundle?.path(forResource: "YouTubeFloatingPlayer", ofType: "bundle") {
            if let assetBundle = Bundle(path: pathForAssetBundle) {
                playImage = UIImage(named: "play", in: assetBundle, compatibleWith: nil)
                pauseImage = UIImage(named: "pause", in: assetBundle, compatibleWith: nil)
                fullscreenImage = UIImage(named: "fullscreen", in: assetBundle, compatibleWith: nil)
                unfullscreenImage = UIImage(named: "unfullscreen", in: assetBundle, compatibleWith: nil)
                minimizeImage = UIImage(named: "NowPlayingCollapseChevronMask", in: assetBundle, compatibleWith: nil)
            }
        }
    }
    
    func setHideTimer() {
        
        hideTimer?.invalidate()
        hideTimer = nil
        hideTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(hidePlayerControls(dontAnimate:)), userInfo: 1.0, repeats: false)
    }
    
    func resetHideTimer() {
        
        if hideTimer != nil {
            hideTimer?.invalidate()
            hideTimer = nil
        }
        setHideTimer()
    }
    
    func showPlayerControls() {
        
        if (!isMinimized) {
            UIView.animate(withDuration: 0.6, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.backPlayerControlsView.alpha = 0.55
                self.playerControlsView.alpha = 1.0
                
            }, completion: nil)
            setHideTimer()
        }
    }
    
    func hidePlayerControls(dontAnimate: Bool = false) {
        
        if (dontAnimate) {
            self.backPlayerControlsView.alpha = 0.0
            self.playerControlsView.alpha = 0.0
        } else {
            if (isPlaying) {
                UIView.animate(withDuration: 0.6, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.backPlayerControlsView.alpha = 0.0
                    self.playerControlsView.alpha = 0.0
                    
                }, completion: nil)
            }
        }
    }

    func setupSlider(with duration: Double, currentTime: Float = 0.0) {
        
        slider.minimumValue = 0.0
        slider.maximumValue = Float(duration)
        slider.value = currentTime
    }
}

extension YTFFullscreenViewController {
    
    @IBAction func playTouched(sender: AnyObject) {
        
        ytPlayerView?.playerState()
        
        if (ytPlayerView?.playerState() == YTPlayerState.playing) {
            ytPlayerView?.pauseVideo()
        } else {
            ytPlayerView?.playVideo()
        }
    }
    
    @IBAction func fullScreenTouched(sender: AnyObject) {
        
        orientation = UIInterfaceOrientationMask.portrait
        shouldHideStatusBar = false
        self.setNeedsStatusBarAppearanceUpdate()
        
        ytfViewController?.setPlayerToNormalScreen()
        
        if (!isFullscreen) {
            
        } else {
            
        }
    }
    
    @IBAction func touchDragInsideSlider(sender: AnyObject) {
        
        resetHideTimer()
    }
    
    @IBAction func valueChangedSlider(sender: AnyObject) {
        
        currentTimeLabel.text = timeFormatted(totalSeconds: Int(slider.value))
        ytPlayerView?.seek(toSeconds: slider.value, allowSeekAhead: true)
    }
    
    @IBAction func touchCancelledSlider(sender: AnyObject) {

    }
    
    func timeFormatted(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension YTFFullscreenViewController: YTPlayerViewDelegate {
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {

        guard let ytPlayerView = ytPlayerView else {
            return
        }
        
        switch state {
        case .playing:
            play.setImage(pauseImage, for: .normal)
            isPlaying = true
            currentTimeLabel.text = timeFormatted(totalSeconds: Int(ytPlayerView.currentTime()))
            entireTimeLabel.text = timeFormatted(totalSeconds: Int(ytPlayerView.duration()))
        case .paused:
            play.setImage(playImage, for: .normal)
            isPlaying = false
        case .queued:
            play.setImage(playImage, for: .normal)
            isPlaying = false
            currentTimeLabel.text = timeFormatted(totalSeconds: 0)
            slider.value = 0
            ytPlayerView.playVideo()
        case .buffering:
            play.setImage(pauseImage, for: .normal)
            isPlaying = true
        default:
            play.setImage(playImage, for: .normal)
            isPlaying = false
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        
        let currentTime = Int(playTime)
        play.setImage(pauseImage, for: .normal)
        isPlaying = true
        
        if (Int(slider.value) != currentTime) { // Change every second
            slider.value = Float(currentTime)
            currentTimeLabel.text = timeFormatted(totalSeconds: currentTime)
        }
    }
}
