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

//        testDataRequest()

        // TEST @@@@@@@@@@@@ +++
        let textDataForTest = "bla-bla bla https://9gag.com/gag/aRjwVVG bla-bla bla"


        let testFireBaseMessage = Message(uid: "0099887766545433",
                                          senderId: "id2222222Id",
                                          time: Date(),
                                          content: (type: MessageContentType.text, content: textDataForTest))
        cell.message = testFireBaseMessage

        // TEST @@@@@@@@@@@@ ---


        return cell
    }


    override func viewDidLoad() {
        super .viewDidLoad()

    }

    private func testDataRequest() {

        RestUIController.sharedInstance.testDataFirst()
    }

}
