//
//  JSONParser.swift
//  EmoChat
//
//  Created by Sergii Kyrychenko on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation


func GetJson(jsonString: String) {

let url = URL(string: jsonString)
    
let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
    if error != nil {
        print ("Error")
    }else{
        if let content = data {
            do {
                let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                
                if let type = myJson["query"] as? NSDictionary {
                    print (type)
                }
            }
            catch {
                
                }
            }
        }
    }
    task.resume()
    }
