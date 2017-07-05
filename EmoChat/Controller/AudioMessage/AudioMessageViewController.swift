

import UIKit
import AVFoundation



class AudioMessageViewController: UIViewController, AVAudioRecorderDelegate {
    
    //MARK - Variables and outlets
    
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var btnAudioRecord: UIButton!
    
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
        // Dispose of any resources that can be recreated.
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
            print(success)
           // showAudioMessage(url: audioRecorder.url) //???????
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
    
    //MARK - func showAudioMessage
    

//    func showAudioMessage(url: URL) {
//    //    if url.absoluteString.hasSuffix("m4a") {
//
//            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
//            
//            button.layer.cornerRadius = 0.5 * button.bounds.size.width
//            button.clipsToBounds = true
//            
//            button.backgroundColor = .black
//            button.setTitle("▶︎", for: .normal)
//            button.addTarget(self, action: #selector(playAudioMessage), for: .touchUpInside)
//            
//            self.testView.addSubview(button)
//       // }
//    }
    
    
    //MARK - func playAudioMessage
    
//    func playAudioMessage(sender: UIButton!) {
//        if !audioRecorder.isRecording {
//            self.audioPlayer = try! AVAudioPlayer(contentsOf: audioRecorder.url)
//            self.audioPlayer.prepareToPlay()
//            self.audioPlayer.delegate = self as? AVAudioPlayerDelegate
//            self.audioPlayer.play()
//
//            self.audioRecorder = nil
//        }
//    }
    
    
    
    func play (url: URL) {
 
        self.player = AVPlayer(url: url)
        self.player.volume = 1.0
       // self.player.play()
       self.PSButtonOutfit.setImage(#imageLiteral(resourceName: "PlayAudioMessage"), for: .normal)
        self.audioRecorder = nil
    }
    
    
}
