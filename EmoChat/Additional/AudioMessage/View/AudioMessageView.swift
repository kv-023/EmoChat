//
//  AudioMessageView.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 28.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

protocol AudioRecordPlaybackProtocol: class {
    var audioMessageViewDelegate: AudioMessageViewProtocol? {get set}
    func playAudio(urlFromFireBase url: URL?)
    var audioSecondsVal: Double { get }
    func analyzeAudioMessage(url: URL, waveFormView: AudioMessageWaveForm?)
}

class AudioMessageView: AdditionalCellView {

    var audioPlaybackDelegate: AudioRecordPlaybackProtocol?

    @IBOutlet weak var playStopButton: UIButton!
    @IBOutlet weak var WaveFormView: AudioMessageWaveForm!
    @IBAction func playStopButtonPressed(_ sender: UIButton) {
        if let notNullURL = url {
            sender.isSelected = true

            audioPlaybackDelegate?.playAudio(urlFromFireBase: URL(fileURLWithPath: notNullURL))

            WaveFormView.playingProgress(sec: audioPlaybackDelegate?.audioSecondsVal, uidStream: Auxiliary.getUUID())
        }
    }
    var heightOriginal: CGFloat = 0

    override var url: String? {
        didSet {
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

        // data as? DataForAudioMessageInfoView
    }

    override func setDataForMediaContentFromDictionary(dict: [String: Any?]) {
        let tempDataForMediaInfoView = DataForAudioMessageInfoView(dict: dict)
        dataForMediaInfoView = tempDataForMediaInfoView
    }

    override  func eraseAllFields() {
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

    deinit {
        audioPlaybackDelegate = nil
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
        audioPlaybackDelegate = AudioMessageControl.cInit()
        audioPlaybackDelegate?.audioMessageViewDelegate = self
    }
}

//MARK:- AudioMessageViewProtocol implementation

extension AudioMessageView: AudioMessageViewProtocol {
    func audioPlayerFinishedPlaying() {
        playStopButton.isSelected = false
    }
}
