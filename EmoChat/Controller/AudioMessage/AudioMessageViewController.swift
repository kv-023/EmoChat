
import UIKit
import AVFoundation


class AudioMessageViewController: UIViewController, AVAudioRecorderDelegate {
    
    //MARK - Variables and outlets
    
    @IBOutlet weak var audioSecondsValLabel: UILabel!
    @IBOutlet weak var btnAudioRecord: UIButton!
    @IBOutlet weak var WaveFormView: AudioMessageWaveForm!
    @IBOutlet weak var PSButtonOutfit: UIButton!
    @IBAction func playStopButton(_ sender: Any) {
        self.player.play()

        playingProgress()
    }
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var settings = [String : Int]()
    var player = AVPlayer()
    var manager: ManagerFirebase?

    var audioSecondsVal: Double {
        get {
//            var valueForReturn: Double = 0.0
//            if let tempVal = player.currentItem?.duration {
//                valueForReturn = CMTimeGetSeconds(tempVal)
//            }
            let valueForReturn = calcLenthOfAudioFile()
            return valueForReturn.roundTo(places: 2)
        }
    }

    //MARK - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PSButtonOutfit.isEnabled = false // disable play button
        
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                
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

        audioSecondsValLabel.text = String(audioSecondsVal)
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
            audioSecondsValLabel.text = String(audioSecondsVal)

            self.btnAudioRecord.setImage(#imageLiteral(resourceName: "RecordAudioMessage"), for: UIControlState.normal)
            
            self.finishRecording(success: true)

            manager = ManagerFirebase.shared
            manager?.handleAudioSendWith(url: audioRecorder.url, result:{ [unowned self] (urlFromFireBase) in
               // self.showAudioMessage(url: urlFromFireBase)
                self.initPlayer(url: urlFromFireBase)
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

    func urlOfCurrentlyPlayingInPlayer(player: AVPlayer) -> URL? {
        return ((player.currentItem?.asset) as? AVURLAsset)?.url
    }

    func calcLenthOfAudioFile() -> Double {
        var valueForReturn: Double = 0
        if let urlFromPlayer = urlOfCurrentlyPlayingInPlayer(player: self.player) {
            let asset: AVURLAsset = AVURLAsset.init(url: urlFromPlayer)
            let durationInSeconds: Double = CMTimeGetSeconds(asset.duration)

            valueForReturn = durationInSeconds
        }
        return valueForReturn
    }

    func showCalcLenthOfAudioFile() {
        self.audioSecondsValLabel.text = String(audioSecondsVal)
    }
    
    func initPlayer (url: URL) {
        print("URL: \(url)")

        self.player = AVPlayer(url: url)
        self.player.volume = 1.0
        // self.player.play()
        self.PSButtonOutfit.setImage(#imageLiteral(resourceName: "PlayAudioMessage"), for: .normal)
        self.audioRecorder = nil

        showCalcLenthOfAudioFile()
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
    
    func playingProgress() {

        let pathUp = ProgressPath.sharedIstance.upperPath
        let pathDown = ProgressPath.sharedIstance.lowerPath

        let currentAudioDuration: CFTimeInterval = audioSecondsVal
        setInitialDraw(pathUp: pathUp,
                       pathDown: pathDown,
                       duration: currentAudioDuration)

        //outro animation
        DispatchQueue.global(qos: .userInitiated).asyncAfter(
            deadline: .now() + .seconds(2), execute: {
                DispatchQueue.main.async {

                    let outroDuration: CFTimeInterval = 3.0
                    self.setOutroDraw(pathUp: pathUp,
                                      pathDown: pathDown,
                                      duration: outroDuration)

                    //remove all layers
                    let eraseLayerDelay: Int = Int(outroDuration) + 1
                    DispatchQueue.global(qos: .userInitiated).asyncAfter(
                        deadline: .now() + .seconds(eraseLayerDelay), execute: {
                            DispatchQueue.main.async {
                                ProgressPath.sharedIstance.removeLayersFromSuperView()
                            }
                    })
                }
        })
        
    }

    func setInitialDraw(pathUp: UIBezierPath?,
               pathDown: UIBezierPath?,
               duration: CFTimeInterval) {
        let shapeLayerUpper = CAShapeLayer()
        shapeLayerUpper.frame = WaveFormView.layer.bounds
        shapeLayerUpper.path = pathUp?.cgPath
        shapeLayerUpper.strokeColor = UIColor.blue.cgColor

        let shapeLayerLower = CAShapeLayer()
        shapeLayerLower.frame = WaveFormView.layer.bounds
        shapeLayerLower.path = pathDown?.cgPath
        shapeLayerLower.strokeColor = UIColor.cyan.cgColor

        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.duration = duration
        strokeEndAnimation.fromValue = 0.0
        strokeEndAnimation.toValue = 1.0

        shapeLayerUpper.add(strokeEndAnimation, forKey: "strokeEnd")
        shapeLayerLower.add(strokeEndAnimation, forKey: "strokeEnd")

        self.WaveFormView.layer.addSublayer(shapeLayerUpper)
        self.WaveFormView.layer.addSublayer(shapeLayerLower)

        ProgressPath.sharedIstance.addLayer(layer: shapeLayerUpper)
        ProgressPath.sharedIstance.addLayer(layer: shapeLayerLower)
    }

    func setOutroDraw(pathUp: UIBezierPath?,
                      pathDown: UIBezierPath?,
                      duration: CFTimeInterval) {
        let shapeLayerUpper = CAShapeLayer()
        shapeLayerUpper.frame = self.WaveFormView.layer.bounds
        shapeLayerUpper.path = pathUp?.cgPath
        shapeLayerUpper.strokeColor = ProgressPath.sharedIstance.upperPathColor.cgColor

        let shapeLayerLower = CAShapeLayer()
        shapeLayerLower.frame = self.WaveFormView.layer.bounds
        shapeLayerLower.path = pathDown?.cgPath
        shapeLayerLower.strokeColor =  ProgressPath.sharedIstance.lowerPathColor.cgColor

        let strokeEndAnimationCleaner = CABasicAnimation(keyPath: "transform.scale.y")
        strokeEndAnimationCleaner.duration = duration
        strokeEndAnimationCleaner.fromValue = 0.0
        strokeEndAnimationCleaner.toValue = 1.0

        shapeLayerUpper.add(strokeEndAnimationCleaner, forKey: nil)
        shapeLayerLower.add(strokeEndAnimationCleaner, forKey: nil)

        self.WaveFormView.layer.addSublayer(shapeLayerUpper)
        self.WaveFormView.layer.addSublayer(shapeLayerLower)

        ProgressPath.sharedIstance.addLayer(layer: shapeLayerUpper)
        ProgressPath.sharedIstance.addLayer(layer: shapeLayerLower)
    }

}
