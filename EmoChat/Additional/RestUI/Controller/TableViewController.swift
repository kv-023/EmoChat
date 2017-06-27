//
//  TableViewController.swift
//  EmoChat
//
//  Created by Sergii Kyrychenko on 19.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

protocol TestResizeCell {
    func resizeMyCell(cell: UITableViewCell)
}

class TableViewController: UITableViewController,TestResizeCell {

    var cellResized = Set<IndexPath>()
    var stringURL: String?
    var imageData: Data?

    override func viewDidLoad() {
        super .viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 240
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "prototypeCell", for: indexPath) as! TableViewCell

        guard !cellResized.contains(indexPath) else {
            cellResized.remove(indexPath)
            return cell
        }

        // TEST @@@@@@@@@@@@ +++
        let textDataForTest = "bla-bla bla https://9gag.com/gag/aRjwVVG bla-bla bla"


        let testFireBaseMessage = Message(uid: "0099887766545433",
                                          senderId: "id2222222Id",
                                          time: Date(),
                                          content: (type: MessageContentType.text, content: textDataForTest))
        cell.testRDelegate = self
        cell.message = testFireBaseMessage

//        let ccView = Bundle.main.loadNibNamed("RestUIInfo", owner: self, options: nil)?.first as! UITableViewCell
//        //).contentView as! RestUIInfoView
//
//        cell.contentView.addSubview(ccView)

        // TEST @@@@@@@@@@@@ ---


        return cell
    }

    func resizeMyCell(cell: UITableViewCell) {
        let indexPath = tableView.indexPath(for: cell)
        cellResized.insert(indexPath!)
        self.tableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        //if cellResized.contains(indexPath) {
            return 500
//        } else {
//            return UITableViewAutomaticDimension//auto//tableView.rectForRow(at: indexPath).height
//        }
    }

}
