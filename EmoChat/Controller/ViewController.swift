//
//  ViewController.swift
//  EmoChat
//
//  Created by Igor Demchenko on 5/29/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

    var ref: FIRDatabaseReference?
    
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

    @IBAction func testFirebase(_ sender: Any) {
        
        ref = FIRDatabase.database().reference()
        
        let tempUser:Users = Users(userId: "1", name: "srg", email: "srdg")
        
        ref?.child("list").childByAutoId().setValue(tempUser.userId)
    }
    
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

