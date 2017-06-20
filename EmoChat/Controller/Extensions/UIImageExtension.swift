//
//  UIImageExtension.swift
//  EmoChat
//
//  Created by Vladyslav Tsykhmystro on 19.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
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

}
