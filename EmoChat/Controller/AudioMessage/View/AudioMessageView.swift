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
}

class AudioMessageView: AdditionalCellView {

    @IBOutlet weak var playStopButton: UIButton!
    //    @IBOutlet weak var captionLabel: UILabel!
    @IBAction func playStopButtonPressed(_ sender: UIButton) {
        if let notNullURL = url {
            audioPlaybackDelegate?.playAudio(urlFromFireBase: URL(string: notNullURL))
        }

        WaveFormView.playingProgress(sec: audioPlaybackDelegate?.audioSecondsVal)
    }
    @IBOutlet weak var WaveFormView: AudioMessageWaveForm!
    //    @IBOutlet weak var spinner: UIActivityIndicatorView!

    weak var audioPlaybackDelegate: AudioRecordPlaybackProtocol?

    override var url: String? {
        didSet{
            if self.url != nil {

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

        if let castedData = data as? DataForAudioMessageInfoView {

        }
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
    
    private func commonInit() {
        heightOriginal = self.bounds.height
        audioPlaybackDelegate = AudioMessageControl.cInit()
    }

}
