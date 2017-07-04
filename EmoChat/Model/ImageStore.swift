//
//  ImageStore.swift
//  Homepwner
//
//  Created by Admin on 13.04.17.
//  Copyright © 2017 Dmitriy Golubovskiy. All rights reserved.
//

import UIKit

class ImageStore {
    
    let cache = NSCache<NSString, UIImage>()
    static let shared = ImageStore()
    
    private init() {
    }

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
}
