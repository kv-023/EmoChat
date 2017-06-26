//
//  Message.swift
//  EmoChat
//
//  Created by Kirill on 5/30/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

enum MessageContentType: String {
    case photo
    case video
    case text
}

class Message {
    let uid: String?
    let senderId: String!
    let time: Date!
    var content: (type: MessageContentType, content: String)!


    init (uid: String, senderId: String, time: Date, content: (type: MessageContentType, content: String))
    {
        self.uid = uid
        self.senderId = senderId
        self.time = time
        self.content = content
    }
    
    /*
     Function generates Message from snapshot
     */
    init (data: NSDictionary?, uid: String?) {
        self.uid = uid
        self.senderId = data?["senderId"] as! String?
        let time = data?["time"] as? NSNumber
        self.time = Date(milliseconds: (time?.intValue)!) //(Date(timeIntervalSince1970: time!/1000))
        let media = data?["content"] as? NSDictionary
        if let photo = media?.value(forKey: "photo") {
            self.content = (type: MessageContentType.photo, content: photo as! String)
        } else if let video = media?.value(forKey: "video") {
            self.content = (type: MessageContentType.video, content: video as! String)
        } else if let text = media?.value(forKey: "text") {
            self.content = (type: MessageContentType.text, content: text as! String)
        }
        
    }
    


}
