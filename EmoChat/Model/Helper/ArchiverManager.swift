//
//  ArchiverManager.swift
//  EmoChat
//
//  Created by Olga Saliy on 15.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

class ArchiverManager {
    
    public static let shared = ArchiverManager()
    
    private init () {
        
    }
    
    var filePath: String {
        //1 - manager lets you examine contents of a files and folders in your app; creates a directory to where we are saving it
        let manager = FileManager.default
        //2 - this returns an array of urls from our documentDirectory and we take the first path
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        //3 - creates a new path component and creates a new file called "User" which is where we will store our user.
        return (url!.appendingPathComponent("User").path)
    }
    
    func saveData(user: User) {
        //5 - archive root object saves our user (our data) to our filepath url
        NSKeyedArchiver.archiveRootObject(user, toFile: filePath)
    }
    
    func loadData() -> User? {
        //6 - if we can get back our data from our archives (load our data), get our data along our file path and cast it as an user of User class
        guard let ourData = (NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? User) else {
            return nil
        }
        return(ourData)
    }
    
}
