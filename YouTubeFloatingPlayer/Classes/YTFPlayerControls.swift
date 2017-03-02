//
//  YTDPlayerControls.swift
//  YTDraggablePlayer
//
//  Created by Ana Paula on 5/31/16.
//  Copyright © 2016 Ana Paula. All rights reserved.
//

import UIKit
import AVFoundation.AVPlayer
import youtube_ios_player_helper

extension YTFViewController {
    
    @IBAction func playTouched(sender: AnyObject) {
        
        videoView.playerState()
        
        if (videoView.playerState() == YTPlayerState.playing) {
//            play.setImage(UIImage(named: "pause"), for: .normal)
            videoView.pauseVideo()
        } else {
//            play.setImage(UIImage(named: "play"), for: .normal)
            videoView.playVideo()
        }
    }
    
    @IBAction func fullScreenTouched(sender: AnyObject) {
        if (!isFullscreen) {
            setPlayerToFullscreen()
        } else {
            setPlayerToNormalScreen()
        }
    }
    
    @IBAction func touchDragInsideSlider(sender: AnyObject) {
        dragginSlider = true
//        videoView.pauseVideo()
    }
    
    
    @IBAction func valueChangedSlider(sender: AnyObject) {
        sliderValueChanged = true
    }
    
    @IBAction func touchUpInsideSlider(sender: AnyObject) {
        dragginSlider = false
        videoView.seek(toSeconds: slider.value, allowSeekAhead: true)
//        videoView.playVideo()
    }
    
    @IBAction func touchUpOutsideSlider(sender: AnyObject) {
        dragginSlider = false
        videoView.seek(toSeconds: slider.value, allowSeekAhead: true)
//        videoView.playVideo()
    }
    
    @IBAction func touchDragOutsideSlider(sender: AnyObject) {
        dragginSlider = false
        videoView.seek(toSeconds: slider.value, allowSeekAhead: true)
//        videoView.playVideo()
    }
}

extension YTFViewController: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        setupSlider(with: Float(videoView.duration()))
        videoView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        
        /*if sliderValueChanged == true && state == .playing {
            videoView.seek(toSeconds: slider.value, allowSeekAhead: true)
            sliderValueChanged = false
        }*/
        
        if state == .playing {
            play.setImage(pauseImage, for: .normal)
            isPlaying = true
        } else {
            play.setImage(playImage, for: .normal)
            isPlaying = false
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        let currentTime = Int(playTime)
        
        if (!dragginSlider && (Int(slider.value) != currentTime)) { // Change every second
            slider.value = Float(currentTime)
        }
    }
}
