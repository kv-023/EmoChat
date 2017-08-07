//
//  WebViewController.swift
//  EmoChat
//
//  Created by Admin on 16.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import AVFoundation

class WebViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var videoButton: UIButton!
    
    // MARK: - WebView's variables
    var blurredView: UIVisualEffectView!
    var webViewURL: URL!
    
    // MARK: - Camera's variables
    var cameraController = CameraView()
    //temp var
    var recordedVideo: URL!
    
    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        cameraController.delegate = self
        cameraController.camPreview = camPreview
        
        let blurEffect = UIBlurEffect(style: .light)
        blurredView = UIVisualEffectView(effect: blurEffect)
        blurredView.frame = self.view.bounds
        blurredView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurredView)
        
        if cameraController.setupSession() {
            cameraController.setupPreview()
            cameraController.startSession()
        }
        
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
        
        webView.loadRequest(URLRequest(url: webViewURL))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopRecording()
    }
    
    // MARK: - Layout
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        
        layer.videoOrientation = orientation
        
        cameraController.previewLayer.frame = camPreview.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection = cameraController.previewLayer?.connection {
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
    
    // MARK: - Camera actions
    
    func startCapture() {
        cameraController.startRecording()
        let title = NSLocalizedString("Stop", comment: "")
        videoButton.titleLabel?.text = title
    }
    
    func stopRecording() {
        cameraController.stopRecording()

        let title = NSLocalizedString("Record", comment: "")
        videoButton.titleLabel?.text = title
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

extension WebViewController: cameraControllerDelegate {
    func getRecordedVideo(recordedVideo: URL) {
        self.recordedVideo = recordedVideo
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

