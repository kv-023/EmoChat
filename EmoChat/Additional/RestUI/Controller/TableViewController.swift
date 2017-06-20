//
//  TableViewController.swift
//  EmoChat
//
//  Created by Sergii Kyrychenko on 19.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var stringURL: String?
    var imageData: Data?



    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    func getImage(info: String) {
        stringURL = info
        let task = URLSession.shared.dataTask(with: (URL(string: info))!) {(data, responce, error) in

            if error != nil {
                print("error")
            }

            else {
                self.imageData = data
            }
        }
        task.resume()

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "prototypeCell", for: indexPath) as! TableViewCell


        dataRequest()


        return cell
    }


    override func viewDidLoad() {
        super .viewDidLoad()

    }


    //MARK:- Get Jddd

    let urlToRequest: String = "https://urlembed.com/json/WDYyREZLSlU2TUk0Qlk2V0xMUklYM01JS0M1VUxJREZXVDZMUU1IQ0tXREhCN0s1TURGQT09PT0=/https://9gag.com/gag/aoOmXeA"


    func dataRequest() {

        //---------------
        let url = URL(string: urlToRequest)
        if let usableUrl = url {
            let request = URLRequest(url: usableUrl)

            let configuration = URLSessionConfiguration.default
            let sharedSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

            let task = sharedSession.dataTask(with: request, completionHandler: { (data, response, error) in

                if let content = data {
                    do {
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject

                        if let type = myJson["type"] as? NSDictionary {
                            print (type)

                        }
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

extension TableViewController: URLSessionDelegate {


    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        
    }
    
}
