//
//  AudioMessageControl.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 25.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import AVFoundation


class AudioMessageControl: NSObject, AVAudioRecorderDelegate {//UIViewController,

    weak var audioMessageWaveForm: AudioMessageWaveForm?
    weak var audioMessageViewDelegate: AudioMessageViewProtocol?
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var settings = [String : Int]()
    var player = AVPlayer()

    var audioSecondsVal: Double {
        get {

            return calcLenthOfAudioFile()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    static func cInit() -> AudioMessageControl {
        let newInstance = AudioMessageControl()
        newInstance.initiateSVariable()

        return newInstance
    }

    func initiateSVariable() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in

                DispatchQueue.main.async {
                    if allowed {
                        //print("Allow")
                    } else {
                        print("RecordPermission: Dont Allow")
                    }
                }
            }
        } catch {
            print("failed to record!")
        }

        // Audio Settings
        settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }

    //MARK - directoryURL

    func directoryURL() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent("sound.m4a")
        return soundURL as URL?
    }

    //MARK - StartRecording
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            audioRecorder = try AVAudioRecorder(url: self.directoryURL()! as URL,
                                                settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            finishRecording(success: false)
        }
        do {
            try audioSession.setActive(true)
            audioRecorder.record()

        } catch {
        }
    }

    //MARK - finishRecording

    func finishRecording(success: Bool) {
        guard let notNullAudioRecorder =  audioRecorder else {
            print("Somthing Wrong.")
            return
        }

        notNullAudioRecorder.stop()
        if success {
            print("success")

        } else {
            audioRecorder = nil
            print("Somthing Wrong.")
        }
    }

    func startAudioRecorder() {
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
        }

        DispatchQueue.main.async {
            self.startRecording()
        }
    }

    func stopAudioRecorder() {
        self.finishRecording(success: true)
    }

    //MARK - audioRecorderDidFinishRecording

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }

    //MARK - Play

    func urlOfCurrentlyPlayingInPlayer(player: AVPlayer) -> URL? {
        return ((player.currentItem?.asset) as? AVURLAsset)?.url
    }

    func urlOfCurrentlyPlayingInPlayer() -> URL? {
        return  urlOfCurrentlyPlayingInPlayer(player: self.player)
    }

    func calcLenthOfAudioFile() -> Double {
        var valueForReturn: Double = 0
        if let urlFromPlayer = urlOfCurrentlyPlayingInPlayer(player: self.player) {

            valueForReturn = calcLenthOfAudioFile(url: urlFromPlayer)

        }
        return valueForReturn
    }

    func calcLenthOfAudioFile(url: URL) -> Double {
        var valueForReturn: Double = 0

        let asset: AVURLAsset = AVURLAsset.init(url: url)
        let durationInSeconds: Double = CMTimeGetSeconds(asset.duration)

        valueForReturn = durationInSeconds

        return valueForReturn.roundTo(places: 2)
    }

    func initPlayer (url: URL) {

        let playerItem = AVPlayerItem(url: url)
        self.player.replaceCurrentItem(with: playerItem)
        self.player.volume = 1.0
        self.audioRecorder = nil
    }

    //MARK - audioMessageToAnalyze

    func audioMessageToAnalyze(url: URL) {
        //Read File into AVAudioFile
        do {
            let file = try AVAudioFile(forReading: url)

            //let file = try! AVAudioFile(forReading: url)
            //Format of the file
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
            //Buffer
            let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))
            try! file.read(into: buf)//Read Floats
            //Store the array of floats in the struct
            audioMessageWaveForm?.readFile.arrayFloatValues = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
        } catch {
            print(error.localizedDescription)
            return
        }
        
    }
}

//MARK:- AudioMessageViewProtocol
protocol AudioMessageViewProtocol: class {
    func audioPlayerFinishedPlaying()
}

//MARK:- AudioRecordProtocol
extension AudioMessageControl: AudioRecordProtocol {

    func startRecordingAudio() {
        startAudioRecorder()
    }

    func finishRecordingAudio() -> URL? {
        stopAudioRecorder()

        return audioRecorder.url
    }
}

//MARK:- AudioRecordPlayback
extension AudioMessageControl: AudioRecordPlaybackProtocol {

    func analyzeAudioMessage(url: URL, waveFormView: AudioMessageWaveForm?) {
        //try to link wave form, if needed
        if self.audioMessageWaveForm == nil
            &&  waveFormView != nil {
            self.audioMessageWaveForm = waveFormView
        }

        self.initPlayer(url: url)

        audioMessageToAnalyze(url: url)
    }

    func playAudio(urlFromFireBase url: URL?) {

        guard let notNullUrl = url else {
            print("url for audio playing can't be nil !")
            return
        }

        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
        }

        self.initPlayer(url: notNullUrl)//not necessary!
        self.player.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: self.player.currentItem)
        
        
        if urlOfCurrentlyPlayingInPlayer() != notNullUrl {
            audioMessageToAnalyze(url: notNullUrl)
        }
        
    }
    
    func playerDidFinishPlaying(sender: Notification) {
        audioMessageViewDelegate?.audioPlayerFinishedPlaying()
    }
    
}
