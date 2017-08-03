//
//  111.swift
//  EmoChat
//
//  Created by 3 on 03.08.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

struct DataForPhotoMessageInfoView: DataForMediaMessageInfoProtocol {
    
    var captionLabel: String?
    var url: String?
    var rurl: String?
    
    init(url: String?) {
        self.url = url
    }
    
    init(captionLabel: String?,
         url: String?) {
        
        self.captionLabel = captionLabel
        self.url = url
    }
    
    init(captionLabel: String?,
         url: String?,
         remoteUrl: String?) {
        
        self.captionLabel = captionLabel
        self.url = url
        self.rurl = remoteUrl
    }
    
    init(dict dicTemData: [String: Any?]) {
        self.captionLabel = dicTemData["captionLabel"] as? String ?? ""
        self.url =  dicTemData["url"] as? String ?? ""
        self.rurl =  dicTemData["rurl"] as? String ?? ""
    }
}
