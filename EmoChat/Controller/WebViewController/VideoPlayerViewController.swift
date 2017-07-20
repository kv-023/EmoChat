//
//  VideoPlayerViewController.swift
//  EmoChat
//
//  Created by Admin on 17.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerViewController: UIViewController {
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    var videoURL: URL!

    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        //view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        
        avPlayer.play()
        
    }
    
}


