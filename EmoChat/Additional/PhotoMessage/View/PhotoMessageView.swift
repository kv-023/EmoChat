//
//  File.swift
//  EmoChat
//
//  Created by 3 on 03.08.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class PhotoMessageView: AdditionalCellView {
    
    // look in superView
//        @IBOutlet weak var captionLabel: UILabel!
//        @IBOutlet weak var spinner: UIActivityIndicatorView!
  
    
    override var url: String? {
        didSet{
//            if let notNullURL = self.url, notNullURL != "" {
//                let localUrlPath = URL(fileURLWithPath: notNullURL)
//                
//                
//                audioPlaybackDelegate?.analyzeAudioMessage(url: localUrlPath, waveFormView: self.WaveFormView)
//                if let currentAudioSecondsVal = audioPlaybackDelegate?.audioSecondsVal {
//                    captionLabel.textAlignment = .left
//                    captionLabel.text = String(currentAudioSecondsVal) + " sec."
//                    //audioPlaybackDelegate?.test()
//                }
//                
//                WaveFormView.setNeedsDisplay()
//            }
        }
    }
    
    override var dataForMediaInfoView: DataForMediaMessageInfoProtocol? {
        didSet {
            if let notNullDataForMediaInfoView = dataForMediaInfoView {
                fullFillViewFromDataInfo(data: notNullDataForMediaInfoView)
            }
        }
    }
    
    override func fullFillViewFromDataInfo(data: DataForMediaMessageInfoProtocol) {
        super.fullFillViewFromDataInfo(data: data)
        
        // data as? DataForAudioMessageInfoView
    }
    
    override func setDataForMediaContentFromDictionary(dict: [String: Any?]) {
        let tempDataForMediaInfoView = DataForAudioMessageInfoView(dict: dict)
        dataForMediaInfoView = tempDataForMediaInfoView
    }
    
    var heightOriginal:CGFloat = 0
    //    weak var dataModel: UrlembedModel?
    
    override   func eraseAllFields() {
        super.eraseAllFields()
        
    }
    
    override init(frame: CGRect) { // for using CustomView in code
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    override func awakeFromNib() {
        //        addUrlTapRecognizer()
    }
    
    override var backgroundColor: UIColor? {
        didSet {
//            if WaveFormView != nil {
//                WaveFormView.backgroundColor = backgroundColor?.withAlphaComponent(0.3)
//            }
        }
    }
    
    private func commonInit() {
        heightOriginal = self.bounds.height
//        audioPlaybackDelegate = AudioMessageControl.cInit()
//        audioPlaybackDelegate?.audioMessageViewDelegate = self
    }
    
}

////MARK:- AudioMessageViewProtocol implementation
//
//extension AudioMessageView: AudioMessageViewProtocol {
//    func audioPlayerFinishedPlaying() {
//        playStopButton.isSelected = false
//    }
//}
