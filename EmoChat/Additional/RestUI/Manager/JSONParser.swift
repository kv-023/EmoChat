//
//  JSONParser.swift
//  EmoChat
//
//  Created by Sergii Kyrychenko on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

class JSONParser: NSObject {

    static let sharedInstance = JSONParser()

    func getJSONDataFromURL(forUrl urlForRequest:String,
                            completion: @escaping (_ jsonData:JsonDataType?) -> Void) {

        let url = URL(string: urlForRequest)
        if let usableUrl = url {
            let request = URLRequest(url: usableUrl)

            let configuration = URLSessionConfiguration.default
            let sharedSession = URLSession(configuration: configuration,
                                           delegate: self,
                                           delegateQueue: nil)

            let task = sharedSession.dataTask(with: request, completionHandler: {
                (data, response, error) in

                if let content = data {
                    do {
                        guard let myJson = try JSONSerialization.jsonObject(with: content,
                                                                            options: JSONSerialization.ReadingOptions.mutableContainers) as? JsonDataType else {
                                                                                let errorMsg = "error trying to convert data to JSON"
                                                                                print(errorMsg)
                                                                                return
                        }

                        completion(myJson)
                    }

                    catch {

                    }
                }
                if error != nil {
                    print (error?.localizedDescription ?? "sm. error occured")
                }
            })

            task.resume()
        }

    }
}

extension JSONParser: URLSessionDelegate {

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
