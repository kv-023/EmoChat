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
    
    func getMixed2Img(image1: UIImage, image2: UIImage) -> UIImage {
        
        let size = CGSize(width:(image1.size.width + image2.size.width), height:image1.size.height)
        
        UIGraphicsBeginImageContext(size)
        
        image1.draw(in: CGRect(x:0, y:0, width:image1.size.width, height:image1.size.height))
        image2.draw(in: CGRect(x:image1.size.width, y:0, width:image2.size.width, height:image2.size.height))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage!
    }
    
    func getMixed3Img(image1: UIImage, image2: UIImage, image3: UIImage) -> UIImage {
        
        let size = CGSize(width:(image1.size.width + image2.size.width), height:(image2.size.height + image3.size.height))
        
        UIGraphicsBeginImageContext(size)
        
        image1.draw(in: CGRect(x:0, y:(size.height/4), width:image1.size.width, height:image1.size.height))
        image2.draw(in: CGRect(x:image1.size.width, y:0, width:image2.size.width, height:image2.size.height))
        image3.draw(in: CGRect(x:image1.size.width, y:image2.size.height, width:image3.size.width, height:image3.size.height))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage!
    }
    
    func getMixed4Img(image1: UIImage, image2: UIImage, image3: UIImage, image4: UIImage) -> UIImage {
        
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

}
