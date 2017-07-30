//
//  AudioMessageView.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 28.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

protocol AudioRecordPlaybackProtocol: class {

    func playAudio(urlFromFireBase url: URL?)
    var audioSecondsVal: Double { get }
    func analyzeAudioMessage(url: URL, waveFormView: AudioMessageWaveForm?)
}

class AudioMessageView: AdditionalCellView {

    @IBOutlet weak var playStopButton: UIButton!
    //    @IBOutlet weak var captionLabel: UILabel!
    @IBAction func playStopButtonPressed(_ sender: UIButton) {
        if let notNullURL = url {
            audioPlaybackDelegate?.playAudio(urlFromFireBase: URL(fileURLWithPath: notNullURL))
        }

        WaveFormView.playingProgress(sec: audioPlaybackDelegate?.audioSecondsVal)
    }
    @IBOutlet weak var WaveFormView: AudioMessageWaveForm!
    //    @IBOutlet weak var spinner: UIActivityIndicatorView!

    var audioPlaybackDelegate: AudioRecordPlaybackProtocol?

    override var url: String? {
        didSet{
            if let notNullURL = self.url, notNullURL != "" {
                let localUrlPath = URL(fileURLWithPath: notNullURL)

                audioPlaybackDelegate?.analyzeAudioMessage(url: localUrlPath, waveFormView: self.WaveFormView)
                if let currentAudioSecondsVal = audioPlaybackDelegate?.audioSecondsVal {
                    captionLabel.textAlignment = .left
                    captionLabel.text = String(currentAudioSecondsVal) + " sec."
                }

                WaveFormView.setNeedsDisplay()
            }
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

//        if let castedData = data as? DataForAudioMessageInfoView {
//
//        }
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
            if WaveFormView != nil {
                WaveFormView.backgroundColor = backgroundColor?.withAlphaComponent(0.3)
            }
        }
    }
    
    private func commonInit() {
        heightOriginal = self.bounds.height
        //CustomTableViewCell.backGroundColorOfExtraView
        audioPlaybackDelegate = AudioMessageControl.cInit()
    }

}
