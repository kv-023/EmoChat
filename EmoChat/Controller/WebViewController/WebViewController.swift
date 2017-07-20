//
//  WebViewController.swift
//  EmoChat
//
//  Created by Admin on 16.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import AVFoundation

class WebViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var videoButton: UIButton!
    
    // MARK: - Constants
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    
    // MARK: - Variables
    var url: URL!
    var blurredView: UIVisualEffectView!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    //temp var
    var recordedVideo: URL!
    
    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        let blurEffect = UIBlurEffect(style: .light)
        blurredView = UIVisualEffectView(effect: blurEffect)
        blurredView.frame = self.view.bounds
        blurredView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurredView)
        
        if setupSession() {
            setupPreview()
            startSession()
        }
        
        //camPreview.isUserInteractionEnabled = true
        //let cameraButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(WebViewController.startCapture))
        //camPreview.addGestureRecognizer(cameraButtonRecognizer)
        
        // temp button
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightButtonAction(sender:)))
        navigationItem.rightBarButtonItem = button
    }
    
    //temp action
    func rightButtonAction(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showVideo", sender: recordedVideo)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        webView.loadRequest(URLRequest(url: url))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopRecording()
    }
    
    // MARK: - Layout
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        
        layer.videoOrientation = orientation
        
        previewLayer.frame = camPreview.bounds
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection =  self.previewLayer?.connection  {
            let currentDevice: UIDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection : AVCaptureConnection = connection
            if previewLayerConnection.isVideoOrientationSupported {
                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                    break
                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                    break
                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                    break
                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                }
            }
        }
    }
    
    //MARK:- Setup Camera
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = camPreview.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        camPreview.layer.addSublayer(previewLayer)
    }
    
    
    func setupSession() -> Bool {
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        // Setup Camera
        
        let session = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified)
        guard let cameras = (session?.devices.flatMap { $0 }), !cameras.isEmpty else {
            return false
        }
        var frontCamera: AVCaptureDevice?
        
        //2
        for camera in cameras {
            if camera.position == .front {
                frontCamera = camera
            }
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Setup Microphone
        let microphone = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        
        
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {
        // Video Mode
        
    }
    
    //MARK:- Camera Session
    func startSession() {
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    func startCapture() {
        
        startRecording()
        
    }
    
    //EDIT 1: I FORGOT THIS AT FIRST
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    func startRecording() {
        
        if movieOutput.isRecording == false {
            
            let title = NSLocalizedString("Stop", comment: "")
            videoButton.titleLabel?.text = title
            
            let connection = movieOutput.connection(withMediaType: AVMediaTypeVideo)
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            if (device?.isSmoothAutoFocusSupported)! {
                do {
                    try device?.lockForConfiguration()
                    device?.isSmoothAutoFocusEnabled = false
                    device?.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
                
            }
            
            //EDIT2: And I forgot this
            outputURL = tempURL()
            movieOutput.startRecording(toOutputFileURL: outputURL, recordingDelegate: self)
            
        }
        else {
            stopRecording()
        }
        
    }
    
    func stopRecording() {
        
        if movieOutput.isRecording == true {
            
            let title = NSLocalizedString("Record", comment: "")
            videoButton.titleLabel?.text = title
            
            movieOutput.stopRecording()
        }
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            
            recordedVideo = outputURL as URL
        }
        
        outputURL = nil
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "showVideo":
            let vc = segue.destination as! VideoPlayerViewController
            vc.videoURL = sender as! URL
        default:
            preconditionFailure("Wrong segue identifier")
        }
    }
    
    // MARK: - Actions
    
    @IBAction func actionVideoButton(_ sender: Any) {
        startCapture()
    }
    
    
}

extension WebViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        guard !webView.isLoading else { return }
        UIView.animate(withDuration: 0.5, animations: { [weak self] () in
                self?.blurredView.alpha = 0.0
            }, completion: { [weak self] (_) in
                self?.blurredView.isHidden = true
                self?.startCapture()
        })
    }
}

