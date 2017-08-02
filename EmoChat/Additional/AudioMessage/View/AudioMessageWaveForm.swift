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
        self.convertToPoints(viewWidth: Int(rect.width))

        var f = 0
        //the waveform on top
        let aPath = UIBezierPath()
        //the waveform on the bottom
        let aPath2 = UIBezierPath()

        //lineWidth
        let lineWidth: CGFloat = 2.0
        aPath.lineWidth = lineWidth
        aPath2.lineWidth = lineWidth

        //start drawing at:
        aPath.move(to: CGPoint(x:0.0 , y:rect.height/2 ))

        //let maxHeight = rect.height/2
        let upperHeightMultiplier: CGFloat = 200
        let lowerHeightMultiplier: CGFloat = 110

        //let step:CGFloat =  CGFloat(readFile.points.count/Int(rect.width))
        //Loop the array
        for _ in readFile.points {
            //Distance between points
            var x: CGFloat = 2.5
            //next location to draw
            aPath.move(to: CGPoint(x: aPath.currentPoint.x + x, y: aPath.currentPoint.y))

            //y is the amplitude of each square
            let yPoint: CGFloat = aPath.currentPoint.y - (readFile.points[f] * upperHeightMultiplier) - 1.0
            aPath.addLine(to: CGPoint(x: aPath.currentPoint.x, y: yPoint))

            aPath.close()
            x += 1
            f += 1
        }

        //#FF8FA0
        let upperPathColor = UIColor(red: 255, green: 143, blue: 160)//UIColor.orange
        let upperPathColorAlpha: CGFloat = 1
        upperPathColor.set()
        aPath.stroke(with: .normal, alpha: upperPathColorAlpha)
        aPath.fill()

        progressPath.upperPath = aPath
        progressPath.upperPathColor = upperPathColor
        progressPath.upperPathColorAlpha = upperPathColorAlpha

        f = 0
        aPath2.move(to: CGPoint(x:0.0 , y:rect.height/2 ))

        //Reflection of waveform
        for _ in readFile.points {
            var x: CGFloat = 2.5
            aPath2.move(to: CGPoint(x: aPath2.currentPoint.x + x, y: aPath2.currentPoint.y))

            //y is the amplitude of each square
            let yPoint: CGFloat = aPath2.currentPoint.y - ((-1.0 * readFile.points[f]) * lowerHeightMultiplier)
             aPath2.addLine(to: CGPoint(x: aPath2.currentPoint.x, y: yPoint))
            aPath2.close()

            x += 1
            f += 1
        }

        //e76b90
        let lowerPathColor = UIColor(red: 231, green: 107, blue: 144)//UIColor.red
        let lowerPathColorAlpha: CGFloat = 1
        lowerPathColor.set()
        aPath2.stroke(with: .normal, alpha: lowerPathColorAlpha)
        aPath2.fill()

        progressPath.lowerPathColor = lowerPathColor
        progressPath.lowerPath = aPath2
        progressPath.lowerPathColorAlpha = lowerPathColorAlpha
    }

    // MARK - convertToPoints

    func convertToPoints(viewWidth: Int = 150) {

        var processingBuffer = [Float](repeating: 0.0,
                                       count: Int(readFile.arrayFloatValues.count))
        var multiplier = 1.0
        let sampleCount = vDSP_Length(readFile.arrayFloatValues.count)
        vDSP_vabs(readFile.arrayFloatValues, 1, &processingBuffer, 1, sampleCount)

        if multiplier < 1 {
            multiplier = 1.0
        }

        let samplesPerPixel = Int(Double(viewWidth) * multiplier)
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
        //convert [Float] to [CGFloat] array
        readFile.points = downSampledData.map{CGFloat($0)}
    }

    //MARK:- show playing progress
    func playingProgress(sec audioSecondsVal: Double?,
                         uidStream: String? = "") {

        guard let NotNullAudioSecondsVal = audioSecondsVal else {
            print("audio second can't be nil !")
            return
        }

        self.progressPath.removeAllLayersFromSuperView()

        let pathUp = progressPath.upperPath
        let pathDown = progressPath.lowerPath

        let currentAudioDuration: CFTimeInterval = NotNullAudioSecondsVal
        setInitialDraw(pathUp: pathUp,
                       pathDown: pathDown,
                       duration: currentAudioDuration,
                       uidStream: uidStream)

        //outro animation
        DispatchQueue.global(qos: .userInitiated).asyncAfter(
            deadline: .now() + .seconds(2), execute: {
                DispatchQueue.main.async {

                    let outroDuration: CFTimeInterval = 1.3
                    self.setOutroDraw(pathUp: pathUp,
                                      pathDown: pathDown,
                                      duration: outroDuration,
                                      uidStream: uidStream)

                    //remove all layers
                    let eraseLayerDelay: Int = Int(outroDuration) + 1
                    DispatchQueue.global(qos: .userInitiated).asyncAfter(
                        deadline: .now() + .seconds(eraseLayerDelay), execute: {
                            DispatchQueue.main.async {
                                self.progressPath.removeLayersFromSuperView(uidSession: uidStream ?? "")
                            }
                    })
                }
        })

    }

    private func setInitialDraw(pathUp: UIBezierPath?,
                                pathDown: UIBezierPath?,
                                duration: CFTimeInterval,
                                uidStream: String? = "") {

        let shapeLayerUpper = CAShapeLayer()
        shapeLayerUpper.frame = self.layer.bounds
        shapeLayerUpper.path = pathUp?.cgPath
        //e9525a
        shapeLayerUpper.strokeColor = UIColor(red: 233, green: 82, blue: 90).cgColor//UIColor.blue.cgColor

        let shapeLayerLower = CAShapeLayer()
        shapeLayerLower.frame = self.layer.bounds
        shapeLayerLower.path = pathDown?.cgPath
        //8f4767
        shapeLayerLower.strokeColor = UIColor(red: 143, green: 71, blue: 103).cgColor//UIColor.cyan.cgColor

        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.duration = duration
        strokeEndAnimation.fromValue = 0.0
        strokeEndAnimation.toValue = 1.0

        shapeLayerUpper.add(strokeEndAnimation, forKey: "strokeEnd")
        shapeLayerLower.add(strokeEndAnimation, forKey: "strokeEnd")

        self.layer.addSublayer(shapeLayerUpper)
        self.layer.addSublayer(shapeLayerLower)

        progressPath.addLayer(uidSession: uidStream, layer: shapeLayerUpper)
        progressPath.addLayer(uidSession: uidStream, layer: shapeLayerLower)
    }

    private func setOutroDraw(pathUp: UIBezierPath?,
                              pathDown: UIBezierPath?,
                              duration: CFTimeInterval,
                              uidStream: String? = "") {
        let shapeLayerUpper = CAShapeLayer()
        shapeLayerUpper.frame = self.layer.bounds
        shapeLayerUpper.path = pathUp?.cgPath
        shapeLayerUpper.strokeColor = progressPath.upperPathColor.withAlphaComponent(progressPath.upperPathColorAlpha).cgColor

        let shapeLayerLower = CAShapeLayer()
        shapeLayerLower.frame = self.layer.bounds
        shapeLayerLower.path = pathDown?.cgPath
        shapeLayerLower.strokeColor =  progressPath.lowerPathColor.withAlphaComponent(progressPath.lowerPathColorAlpha).cgColor

        let strokeEndAnimationCleaner = CABasicAnimation(keyPath: "transform.scale.y")
        strokeEndAnimationCleaner.duration = duration
        strokeEndAnimationCleaner.fromValue = 0.0
        strokeEndAnimationCleaner.toValue = 1.0

        shapeLayerUpper.add(strokeEndAnimationCleaner, forKey: nil)
        shapeLayerLower.add(strokeEndAnimationCleaner, forKey: nil)

        self.layer.addSublayer(shapeLayerUpper)
        self.layer.addSublayer(shapeLayerLower)

        progressPath.addLayer(uidSession: uidStream, layer: shapeLayerUpper)
        progressPath.addLayer(uidSession: uidStream, layer: shapeLayerLower)

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
    typealias  LayerArrayType = [(uid: String, layer: CAShapeLayer)]
    var upperPath: UIBezierPath? = nil
    var lowerPath: UIBezierPath? = nil

    var upperPathColor: UIColor = UIColor.clear
    var upperPathColorAlpha: CGFloat = 0
    var lowerPathColor: UIColor = UIColor.clear
    var lowerPathColorAlpha: CGFloat = 0

    var layerDataM: LayerArrayType? = []

    mutating func addLayer(uidSession uid: String? = "", layer: CAShapeLayer) {
        layerDataM?.append((uid: uid!, layer: layer))
    }

    mutating func removeAllLayersFromSuperView() {
        if let arrayOfLayersForRemove = layerDataM {
            for layerTuplesOfData in arrayOfLayersForRemove {
                let (_,layerOfData) = layerTuplesOfData
                layerOfData.removeFromSuperlayer()
            }
            layerDataM?.removeAll()
        }
    }

    mutating func removeLayersFromSuperView(uidSession sUid: String = "") {

        guard var arrayOfLayersForRemove = layerDataM,
            arrayOfLayersForRemove.contains(where: {($0.uid == sUid)}) else {
                return
        }

        for index in stride(from: arrayOfLayersForRemove.count - 1, through: 0, by: -1) {
            let layerTuplesOfData = arrayOfLayersForRemove[index]
            
            let (uidData,layerOfData) = layerTuplesOfData
            guard uidData == sUid else {
                continue
            }
            
            layerOfData.removeFromSuperlayer()
            
            arrayOfLayersForRemove.remove(at: index)
            layerDataM?.remove(at: index)
        }
    }
}
