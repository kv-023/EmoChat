

import UIKit
import AVFoundation




class AudioMessageViewController: UIViewController, AVAudioRecorderDelegate {
    
    //MARK - Variables and outlets
    

    @IBOutlet weak var btnAudioRecord: UIButton!
    @IBOutlet weak var WaveFormView: AudioMessageWaveForm!
    @IBOutlet weak var PSButtonOutfit: UIButton!
    @IBAction func playStopButton(_ sender: Any) {
        self.player.play()
       // self.PSButtonOutfit.setImage(#imageLiteral(resourceName: "PauseAudioMessage"), for: UIControlState.normal)
    }
    
    var recordingSession : AVAudioSession!
    var audioRecorder    :AVAudioRecorder!
    var settings         = [String : Int]()
    var player = AVPlayer()
    var manager: ManagerFirebase?
    
    
    //MARK - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PSButtonOutfit.isEnabled = false // disable play button
        
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                
                DispatchQueue.main.async {
                    if allowed {
                        print("Allow")
                    } else {
                        print("Dont Allow")
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     
    }
    
    //MARK - directoryURL
    
    func directoryURL() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent("sound.m4a")
        print(soundURL)
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
        audioRecorder.stop()
        if success {
            print("success")
            
            audioMessageToAnalyze(url: audioRecorder.url)
            self.WaveFormView.setNeedsDisplay()
        } else {
            audioRecorder = nil
            print("Somthing Wrong.")
        }
    }
    
    
    //MARK - button to star/stop recording
    
    @IBAction func click_AudioRecord(_ sender: AnyObject) {
        
        
        if audioRecorder == nil {
        self.btnAudioRecord.setImage(#imageLiteral(resourceName: "StopAudioMessage"), for: UIControlState.normal)
           
            DispatchQueue.main.async {
                self.startRecording()
            }
            
        } else {
            self.btnAudioRecord.setImage(#imageLiteral(resourceName: "RecordAudioMessage"), for: UIControlState.normal)
            
            self.finishRecording(success: true)
            
            manager = ManagerFirebase.shared
            manager?.handleAudioSendWith(url: audioRecorder.url, result:{ (urlFromFireBase) in
               // self.showAudioMessage(url: urlFromFireBase)
                self.play(url: urlFromFireBase)
            })
                
            
        }
    }
    
    //MARK - audioRecorderDidFinishRecording
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    
    //MARK - Play
    
    
    func play (url: URL) {
        print("URL: \(url)")
        
        
        self.player = AVPlayer(url: url)
        self.player.volume = 1.0
       // self.player.play()
       self.PSButtonOutfit.setImage(#imageLiteral(resourceName: "PlayAudioMessage"), for: .normal)
        self.audioRecorder = nil
        
    }
    
    //MARK - audioMessageToAnalyze
    
    func audioMessageToAnalyze(url: URL) {
       // let url = Bundle.main.url(forResource: url.absoluteString, withExtension: "m4a")
        let file = try! AVAudioFile(forReading: url)//Read File into AVAudioFile
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)//Format of the file
        
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))//Buffer
        try! file.read(into: buf)//Read Floats
        //Store the array of floats in the struct
        readFile.arrayFloatValues = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
    }
    
    
}
