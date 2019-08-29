//
//  PlayerView.swift
//  RDV
//
//  Created by Bin CHEN on 5/23/18.
//  Copyright © 2018 TELEFUN. All rights reserved.
//

import Foundation
import AVKit
import CoreMedia

class VideoPlayerView: UIView {    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var videoURL: URL? {
        didSet {
            if let url = videoURL {
                player = AVPlayer(url: url)
            }
        }        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func playerDidFinishPlaying(_ notification: Notification) {
        player?.seek(to: CMTime(seconds: 0.0, preferredTimescale: CMTimeScale(1.0)))
        player?.play()
    }
    
    func play() {
        if let player = self.player {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(VideoPlayerView.playerDidFinishPlaying(_:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: player.currentItem)
        }

        player?.seek(to: CMTime(seconds: 0.0, preferredTimescale: CMTimeScale(1.0)))
        player?.play()
    }
    
    func stop() {
        player?.pause()
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
