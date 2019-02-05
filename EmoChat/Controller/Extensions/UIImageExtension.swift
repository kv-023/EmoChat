//
//  UIImageExtension.swift
//  EmoChat
//
//  Created by Vladyslav Tsykhmystro on 19.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
	
	switch (lhs, rhs) {
	case let (l?, r?):
		return l < r
	case (nil, _?):
		return true
	default:
		return false
	}

}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
	
	switch (lhs, rhs) {
	case let (l?, r?):
		return l <= r
	default:
		return !(rhs < lhs)
	}

}


let _imageSourceKey = malloc(4)!
let _displayRefreshFactorKey = malloc(4)!
let _imageCountKey = malloc(4)!
let _displayOrderKey = malloc(4)!
let _imageSizeKey = malloc(4)!
let _imageDataKey = malloc(4)!

let defaultLevelOfIntegrity: Float = 0.8


fileprivate enum GifParseError:Error {
	
	case noProperties
	case noGifDictionary
	case noTimingInfo

}


extension UIImage {
	
	class func imageFromURL(url: String) -> UIImage {
		
		var imageFromURL = UIImage()
		if let url = NSURL(string: url) {
			if let data = NSData(contentsOf: url as URL) {
				imageFromURL = UIImage(data: data as Data)!
			}
		}
		return imageFromURL
	}

	
    class func createFinalImg(logoImages: Array<UIImage>)  -> UIImage {

        var finalMixedImage = UIImage()
        
        if (logoImages.count == 1) {
            finalMixedImage = logoImages[0]
        } else if (logoImages.count == 2) {
            finalMixedImage = getMixed2Img(image1: logoImages[0], image2: logoImages[1])
        } else if (logoImages.count == 3) {
            finalMixedImage = getMixed3Img(image1: logoImages[0], image2: logoImages[1], image3: logoImages[2])
        } else if (logoImages.count == 4) {
            finalMixedImage = getMixed4Img(image1: logoImages[0], image2: logoImages[1], image3: logoImages[2], image4: logoImages[3])
        } else if (logoImages.count > 4) {
            var tempArray = logoImages
            
            let randomIndex1 = Int(arc4random_uniform(UInt32(tempArray.count)))
            let image1 = tempArray[randomIndex1]
            tempArray.remove(at: randomIndex1)
            let randomIndex2 = Int(arc4random_uniform(UInt32(tempArray.count)))
            let image2 = tempArray[randomIndex2]
            tempArray.remove(at: randomIndex2)
            let randomIndex3 = Int(arc4random_uniform(UInt32(tempArray.count)))
            let image3 = tempArray[randomIndex3]
            tempArray.remove(at: randomIndex3)
            let randomIndex4 = Int(arc4random_uniform(UInt32(tempArray.count)))
            let image4 = tempArray[randomIndex4]
            tempArray.remove(at: randomIndex4)
            finalMixedImage = getMixed4Img(image1: image1, image2: image2, image3: image3, image4: image4)
        }
        
        return finalMixedImage
    }
    
    class func getMixed2Img(image1: UIImage, image2: UIImage) -> UIImage {
        
        let size = CGSize(width:(image1.size.width + image2.size.width), height:image1.size.height)
        
        UIGraphicsBeginImageContext(size)
        
        image1.draw(in: CGRect(x:0, y:0, width:image1.size.width, height:image1.size.height))
        image2.draw(in: CGRect(x:image1.size.width, y:0, width:image2.size.width, height:image2.size.height))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage!
    }
    
    class func getMixed3Img(image1: UIImage, image2: UIImage, image3: UIImage) -> UIImage {
        
        let size = CGSize(width:(image1.size.width + image2.size.width), height:(image2.size.height + image3.size.height))
        
        UIGraphicsBeginImageContext(size)
        
        image1.draw(in: CGRect(x:0, y:(size.height/4), width:image1.size.width, height:image1.size.height))
        image2.draw(in: CGRect(x:image1.size.width, y:0, width:image2.size.width, height:image2.size.height))
        image3.draw(in: CGRect(x:image1.size.width, y:image2.size.height, width:image3.size.width, height:image3.size.height))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage!
    }
    
    class func getMixed4Img(image1: UIImage, image2: UIImage, image3: UIImage, image4: UIImage) -> UIImage {
        
        let size = CGSize(width:(image1.size.width + image2.size.width), height:(image1.size.height + image3.size.height))
        
        UIGraphicsBeginImageContext(size)
        
        image1.draw(in: CGRect(x:0, y:0, width:image1.size.width, height:image1.size.height))
        image2.draw(in: CGRect(x:image1.size.width, y:0, width:image2.size.width, height:image2.size.height))
        image3.draw(in: CGRect(x:0, y:(size.height/2), width:image3.size.width, height:image3.size.height))
        image4.draw(in: CGRect(x:(size.height/2), y:(size.height/2), width:image4.size.width, height:image4.size.height))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage!
    }
	
	func resizeImageWith(newSize: CGSize) -> UIImage {
		
		let horizontalRatio = newSize.width / size.width
		let verticalRatio = newSize.height / size.height
		
		let ratio = max(horizontalRatio, verticalRatio)
		let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
		
		UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
		draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage!
	}
	
	public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
		let rect = CGRect(origin: .zero, size: size)
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
		color.setFill()
		UIRectFill(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		guard let cgImage = image?.cgImage else { return nil }
		self.init(cgImage: cgImage)
	}
	
	// MARK: - GIF Animation extension
	
	/**
	Convenience initializer. Creates a gif with its backing data.
	- Parameter gifData: The actual gif data
	- Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
	*/
	
	public convenience init(gifData:Data, levelOfIntegrity:Float) {
		self.init()
		setGifFromData(gifData,levelOfIntegrity: levelOfIntegrity)
	}
	
	/**
	Convenience initializer. Creates a gif with its backing data. Defaulted level of integrity.
	- Parameter gifName: Filename
	*/
	
	public convenience init(gifName: String) {
		self.init()
		setGif(gifName, levelOfIntegrity: defaultLevelOfIntegrity)
	}
	
	/**
	Convenience initializer. Creates a gif with its backing data.
	- Parameter gifName: Filename
	- Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
	*/
	public convenience init(gifName: String, levelOfIntegrity: Float) {
		self.init()
		setGif(gifName, levelOfIntegrity: levelOfIntegrity)
	}
	
	/**
	Set backing data for this gif. Overwrites any existing data.
	- Parameter data: The actual gif data
	- Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
	*/
	public func setGifFromData(_ data:Data,levelOfIntegrity:Float) {

		guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return }
		self.imageSource = imageSource
		self.imageData = data
		
		do {
			calculateFrameDelay(try delayTimes(imageSource), levelOfIntegrity: levelOfIntegrity)
		} catch {
			print("Could not determine delay times for GIF.")
			return
		}
		calculateFrameSize()

	}
	
	/**
	Set backing data for this gif. Overwrites any existing data.
	- Parameter name: Filename
	*/
	public func setGif(_ name: String) {

		setGif(name, levelOfIntegrity: defaultLevelOfIntegrity)

	}
	
	/**
	Check the number of frame for this gif
	- Return number of frames
	*/
	public func framesCount() -> Int{

		if let orders = self.displayOrder{
			return orders.count
		}
		return 0

	}
	
	/**
	Set backing data for this gif. Overwrites any existing data.
	- Parameter name: Filename
	- Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
	*/

	public func setGif(_ name: String, levelOfIntegrity: Float) {
		
		if let url = Bundle.main.url(forResource: name,
		                             withExtension: name.getPathExtension() == "gif" ? "" : "gif") {
			if let data = try? Data(contentsOf: url) {

				setGifFromData(data,levelOfIntegrity: levelOfIntegrity)
	
			} else {

				print("Error : Invalid GIF data for \(name).gif")

			}
		} else {
	
			print("Error : Gif file \(name).gif not found")
		}
	}
	
	// MARK: Logic

	fileprivate func convertToDelay(_ pointer:UnsafeRawPointer?) -> Float? {

		if pointer == nil {
			return nil
		}

		let value = unsafeBitCast(pointer, to:AnyObject.self)
		return value.floatValue
	}
	
	/**
	Get delay times for each frames
	- Parameter imageSource: reference to the gif image source
	- Returns array of delays
	*/

	fileprivate func delayTimes(_ imageSource:CGImageSource) throws ->[Float] {
		
		let imageCount = CGImageSourceGetCount(imageSource)
		var imageProperties = [CFDictionary]()

		for i in 0..<imageCount {
			
			if let dict = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) {

				imageProperties.append(dict)

			} else {
				
				throw GifParseError.noProperties
	
			}

		}
		
		let frameProperties = try imageProperties.map() {

			(dict:CFDictionary)->CFDictionary in
			
			let key = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
			
			let value = CFDictionaryGetValue(dict, key)
			
			if value == nil {
				throw GifParseError.noGifDictionary
			}

			return unsafeBitCast(value, to:CFDictionary.self)
		}
		
		let EPS:Float = 1e-6

		let frameDelays:[Float] = try frameProperties.map(){

			let unclampedKey = Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()
			let unclampedPointer:UnsafeRawPointer? = CFDictionaryGetValue($0, unclampedKey)

			if let value = convertToDelay(unclampedPointer), value >= EPS {
				return value
			}

			let clampedKey = Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()
			let clampedPointer:UnsafeRawPointer? = CFDictionaryGetValue($0, clampedKey)
			
			if let value = convertToDelay(clampedPointer) {
				return value
			}

			throw GifParseError.noTimingInfo
		}
		return frameDelays
	}
	
	/**
	Compute backing data for this gif
	- Parameter delaysArray: decoded delay times for this gif
	- Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
	*/

	fileprivate func calculateFrameDelay(_ delaysArray:[Float],levelOfIntegrity:Float){
		
		var delays = delaysArray
		
		//Factors send to CADisplayLink.frameInterval
		let displayRefreshFactors = [60,30,20,15,12,10,6,5,4,3,2,1]
		
		//maxFramePerSecond,default is 60
		let maxFramePerSecond = displayRefreshFactors.first
		
		//frame numbers per second
		let displayRefreshRates = displayRefreshFactors.map{maxFramePerSecond!/$0}
		
		//time interval per frame
		let displayRefreshDelayTime = displayRefreshRates.map{1.0/Float($0)}
		
		//caclulate the time when each frame should be displayed at(start at 0)
		for i in 1..<delays.count{ delays[i] += delays[i-1] }
		
		//find the appropriate Factors then BREAK
		for i in 0..<displayRefreshDelayTime.count{
			
			let displayPosition = delays.map{Int($0/displayRefreshDelayTime[i])}
			
			var framelosecount: Float = 0

			for j in 1..<displayPosition.count{
				if displayPosition[j] == displayPosition[j-1] {
					framelosecount += 1
				}
			}
			
			if(displayPosition[0] == 0){
				framelosecount += 1
			}
			
			if framelosecount <= Float(displayPosition.count) * (1.0 - levelOfIntegrity) ||
				i == displayRefreshDelayTime.count-1 {
				
				self.imageCount = displayPosition.last!
				self.displayRefreshFactor = displayRefreshFactors[i]
				self.displayOrder = [Int]()
				var indexOfold = 0
				var indexOfnew = 1
				while indexOfnew <= imageCount {
					if indexOfnew <= displayPosition[indexOfold] {
						self.displayOrder!.append(indexOfold)
						indexOfnew += 1
					}else{
						indexOfold += 1
					}
				}
				break
			}
		}
	}
	
	/**
	Compute frame size for this gif
	*/
	fileprivate func calculateFrameSize(){

		guard let imageSource = imageSource else {
			return
		}
		
		guard let imageCount = imageCount else {
			return
		}
		
		guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource,0,nil) else {
			return
		}
		
		let image = UIImage(cgImage:cgImage)
		self.imageSize = Int(image.size.height*image.size.width*4)*imageCount/1000000

	}
	
	// MARK: get / set associated values
	
	public var imageSource: CGImageSource? {
		
		get {
            let result = objc_getAssociatedObject(self, _imageSourceKey)
			if result == nil {
				return nil
			}
			return (result as! CGImageSource)
		}
		set {
			objc_setAssociatedObject(self, _imageSourceKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
		}
		
	}
	
	public var displayRefreshFactor: Int?{
		
		get {
			return objc_getAssociatedObject(self, _displayRefreshFactorKey) as? Int
		}
		set {
			objc_setAssociatedObject(self, _displayRefreshFactorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
		}
		
	}
	
	public var imageSize: Int?{
		
		get {
			return objc_getAssociatedObject(self, _imageSizeKey) as? Int
		}
		
		set {
			objc_setAssociatedObject(self, _imageSizeKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
		}
		
	}
	
	public var imageCount: Int?{
		
		get {
			return objc_getAssociatedObject(self, _imageCountKey) as? Int
		}
		
		set {
			objc_setAssociatedObject(self, _imageCountKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
		}

	}
	
	public var displayOrder: [Int]?{
		
		get {
			return objc_getAssociatedObject(self, _displayOrderKey) as? [Int]
		}
		
		set {
			objc_setAssociatedObject(self, _displayOrderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
		}
	}
	
	public var imageData:Data? {
		
		get {

			let result = objc_getAssociatedObject(self, _imageDataKey)
			if result == nil {
				return nil
			}
			return (result as! Data)

		}
		
		set {
			objc_setAssociatedObject(self, _imageDataKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
		}
	}
}
