//
//  AudioMessageWaveform.swift
//  EmoChat
//
//  Created by Sergii Kyrychenko on 12.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import Accelerate



class AudioMessageWaveForm: UIView {

    var readFile = ReadFile()
    var progressPath = ProgressPath()

// MARK - draw
    override func draw(_ rect: CGRect) {
        //downsample and convert to [CGFloat]
        self.convertToPoints()
        
        var f = 0
        //the waveform on top
        let aPath = UIBezierPath()
        //the waveform on the bottom
        let aPath2 = UIBezierPath()
        
        //lineWidth
        aPath.lineWidth = 2.0
        aPath2.lineWidth = 2.0
        
        //start drawing at:
        aPath.move(to: CGPoint(x:0.0 , y:rect.height/2 ))
        aPath2.move(to: CGPoint(x:0.0 , y:rect.height ))
        
        //Loop the array
        for _ in readFile.points{
            //Distance between points
            var x:CGFloat = 2.5
            //next location to draw
            aPath.move(to: CGPoint(x:aPath.currentPoint.x + x , y:aPath.currentPoint.y ))
            
            //y is the amplitude of each square
            aPath.addLine(to: CGPoint(x:aPath.currentPoint.x  , y:aPath.currentPoint.y - (readFile.points[f] * 200) - 1.0))
            aPath.close()
            x += 1
            f += 1
        }
        
        let upperPathColor = UIColor.orange
        //UIColor.orange.set()
        upperPathColor.set()
        aPath.stroke()
        aPath.fill()
        
        progressPath.upperPath = aPath
        progressPath.upperPathColor = upperPathColor
        
        f = 0
        aPath2.move(to: CGPoint(x:0.0 , y:rect.height/2 ))
        
        //Reflection of waveform
        for _ in readFile.points {
            var x:CGFloat = 2.5
            aPath2.move(to: CGPoint(x:aPath2.currentPoint.x + x , y:aPath2.currentPoint.y ))
            
            //y is the amplitude of each square
            aPath2.addLine(to: CGPoint(x:aPath2.currentPoint.x  , y:aPath2.currentPoint.y - ((-1.0 * readFile.points[f]) * 110)))
            aPath2.close()
            
            //print(aPath.currentPoint.x)
            x += 1
            f += 1
        }

        let lowerPathColor = UIColor.red
//        UIColor.red.set()
        lowerPathColor.set()
        aPath2.stroke(with: CGBlendMode.normal, alpha: 0.5)
        aPath2.fill()


        progressPath.lowerPathColor = lowerPathColor
        progressPath.lowerPath = aPath2
    }
    
    // MARK - convertToPoints
    
    func convertToPoints() {
        var processingBuffer = [Float](repeating: 0.0,
                                       count: Int(readFile.arrayFloatValues.count))
        let sampleCount = vDSP_Length(readFile.arrayFloatValues.count)
        //print(sampleCount)
        vDSP_vabs(readFile.arrayFloatValues, 1, &processingBuffer, 1, sampleCount);
      
        
        var multiplier = 1.0
//        print(multiplier)
        if multiplier < 1 {
            multiplier = 1.0
            
        }
        
        let samplesPerPixel = Int(150 * multiplier)
        let filter = [Float](repeating: 1.0 / Float(samplesPerPixel),
                             count: Int(samplesPerPixel))
        let downSampledLength = Int(readFile.arrayFloatValues.count / samplesPerPixel)
        var downSampledData = [Float](repeating:0.0,
                                      count:downSampledLength)
        vDSP_desamp(processingBuffer,
                    vDSP_Stride(samplesPerPixel),
                    filter, &downSampledData,
                    vDSP_Length(downSampledLength),
                    vDSP_Length(samplesPerPixel))
        // print(" DOWNSAMPLEDDATA: \(downSampledData.count)")
        //convert [Float] to [CGFloat] array
        readFile.points = downSampledData.map{CGFloat($0)}
        
    }

    //MARK:- show playing progress

    func playingProgress(sec audioSecondsVal: Double?) {

        guard let NotNullAudioSecondsVal = audioSecondsVal else {
            print("audio second can't be nil !")
            return
        }

        let pathUp = progressPath.upperPath
        let pathDown = progressPath.lowerPath

        let currentAudioDuration: CFTimeInterval = NotNullAudioSecondsVal
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
                                self.progressPath.removeLayersFromSuperView()
                            }
                    })
                }
        })

    }

    private func setInitialDraw(pathUp: UIBezierPath?,
                        pathDown: UIBezierPath?,
                        duration: CFTimeInterval) {
        let shapeLayerUpper = CAShapeLayer()
        shapeLayerUpper.frame = self.layer.bounds//WaveFormView.layer.bounds
        shapeLayerUpper.path = pathUp?.cgPath
        shapeLayerUpper.strokeColor = UIColor.blue.cgColor

        let shapeLayerLower = CAShapeLayer()
        shapeLayerLower.frame = self.layer.bounds//WaveFormView.layer.bounds
        shapeLayerLower.path = pathDown?.cgPath
        shapeLayerLower.strokeColor = UIColor.cyan.cgColor

        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.duration = duration
        strokeEndAnimation.fromValue = 0.0
        strokeEndAnimation.toValue = 1.0

        shapeLayerUpper.add(strokeEndAnimation, forKey: "strokeEnd")
        shapeLayerLower.add(strokeEndAnimation, forKey: "strokeEnd")

//        self.WaveFormView.
        self.layer.addSublayer(shapeLayerUpper)
//        self.WaveFormView.
        self.layer.addSublayer(shapeLayerLower)

        progressPath.addLayer(layer: shapeLayerUpper)
        progressPath.addLayer(layer: shapeLayerLower)
    }

    private func setOutroDraw(pathUp: UIBezierPath?,
                      pathDown: UIBezierPath?,
                      duration: CFTimeInterval) {
        let shapeLayerUpper = CAShapeLayer()
        shapeLayerUpper.frame = self.layer.bounds//self.WaveFormView.layer.bounds
        shapeLayerUpper.path = pathUp?.cgPath
        shapeLayerUpper.strokeColor = progressPath.upperPathColor.cgColor

        let shapeLayerLower = CAShapeLayer()
        shapeLayerLower.frame = self.layer.bounds//self.WaveFormView.layer.bounds
        shapeLayerLower.path = pathDown?.cgPath
        shapeLayerLower.strokeColor =  progressPath.lowerPathColor.cgColor

        let strokeEndAnimationCleaner = CABasicAnimation(keyPath: "transform.scale.y")
        strokeEndAnimationCleaner.duration = duration
        strokeEndAnimationCleaner.fromValue = 0.0
        strokeEndAnimationCleaner.toValue = 1.0

        shapeLayerUpper.add(strokeEndAnimationCleaner, forKey: nil)
        shapeLayerLower.add(strokeEndAnimationCleaner, forKey: nil)

//        self.WaveFormView.
        self.layer.addSublayer(shapeLayerUpper)
//        self.WaveFormView.
        self.layer.addSublayer(shapeLayerLower)

        progressPath.addLayer(layer: shapeLayerUpper)
        progressPath.addLayer(layer: shapeLayerLower)
    }
}

//Mark:- Auxiliary structures
struct ReadFile {
    static var sharedIstance = ReadFile()

    var arrayFloatValues:[Float] = []
    var points:[CGFloat] = []
}

struct ProgressPath {

    static var sharedIstance = ProgressPath()

    var upperPath: UIBezierPath? = nil
    var lowerPath: UIBezierPath? = nil

    var upperPathColor: UIColor = UIColor.clear
    var lowerPathColor: UIColor = UIColor.clear

    var layerData:[CAShapeLayer]? = []

    mutating func addLayer(layer: CAShapeLayer) {
        layerData?.append(layer)
    }

    mutating func removeLayersFromSuperView() {
        if let arrayFoLayersForRemove = layerData {
            for layerOfData in arrayFoLayersForRemove {

                layerOfData.removeFromSuperlayer()
            }

            layerData?.removeAll()
        }
    }
}
