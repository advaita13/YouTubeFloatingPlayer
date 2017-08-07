//
//  YTDPlayerControls.swift
//  YTDraggablePlayer
//
//  Created by Ana Paula on 5/31/16.
//  Copyright © 2016 Ana Paula. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

extension YTFViewController {
    
    @IBAction func playTouched(sender: AnyObject) {
        
        videoView.playerState()
        
        if (videoView.playerState() == YTPlayerState.playing) {
            videoView.pauseVideo()
        } else {
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

        resetHideTimer()
    }
    
    @IBAction func valueChangedSlider(sender: AnyObject) {
        
        currentTimeLabel.text = timeFormatted(totalSeconds: Int(slider.value))
        videoView.seek(toSeconds: slider.value, allowSeekAhead: true)
    }
    
    @IBAction func touchCancelledSlider(sender: AnyObject) {
        
    }
    
    func timeFormatted(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension YTFViewController: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        
        setupSlider(with: videoView.duration())
        entireTimeLabel.text = timeFormatted(totalSeconds: Int(videoView.duration()))
        videoView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        
        print("STATE", state.rawValue)
        
        switch state {
        case .playing:
            play.setImage(pauseImage, for: .normal)
            isPlaying = true
            currentTimeLabel.text = timeFormatted(totalSeconds: Int(videoView.currentTime()))
            entireTimeLabel.text = timeFormatted(totalSeconds: Int(videoView.duration()))
        case .paused:
            play.setImage(playImage, for: .normal)
            isPlaying = false
        case .queued:
            play.setImage(playImage, for: .normal)
            isPlaying = false
            currentTimeLabel.text = timeFormatted(totalSeconds: 0)
            slider.value = 0
            videoView.playVideo()
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
        
        if (Int(slider.value) != currentTime) { // Change every second
            slider.value = Float(currentTime)
            currentTimeLabel.text = timeFormatted(totalSeconds: currentTime)
        }
    }
}
