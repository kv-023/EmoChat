//
//  Notifications.swift
//  EmoChat
//
//  Created by Sergii Kyrychenko on 25.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation
import UserNotifications



func notifyAboutNewMessage() {
    
    
    
   
    
    let content = UNMutableNotificationContent()
    
    content.title = "Emochat"
    content.subtitle = "New message"
    content.body = "You have a new message"
    content.badge = 1
    content.sound = UNNotificationSound.default()
    
    
    
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    let requst = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(requst, withCompletionHandler: nil)
}

func requestPermissionForNotifications() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge],  completionHandler: {didAllow, error in
        if error != nil {
            print("error on requestPermissionForNotifications() stage")
        }
    })
}





