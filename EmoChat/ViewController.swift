//
//  ViewController.swift
//  EmoChat
//
//  Created by Igor Demchenko on 5/29/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController {

    var ref: FIRDatabaseReference?

    @IBAction func regexTestButtoPressed(_ sender: UIButton) {
        regexTest()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func testFirebase(_ sender: Any) {

        ref = FIRDatabase.database().reference()

        let tempUser:User = User(userId: "userID123", name: "Galja", email: "galja@ukr.net")
        let tempUser2:User = User(userId: "userID009", name: "Petja", email: "petja@gmail.com")

        let usersInArray = [tempUser,tempUser2];


        let tempConversation:Conversation = Conversation(conversationId: "conversationId-456", usersInConversation: usersInArray)
        let tempMessage:Message = Message(messageId: "messageId-789",
                                            sender: tempUser, conversation: tempConversation.uuid)
        tempMessage.messageText = "hello world!"

        ref?.child("Message").setValue(tempMessage.toAnyObject())
        if let notNullUsersInConversation = tempConversation.usersInConversation {
            for itemUserConversation in notNullUsersInConversation {
                if let itemUserConversation = itemUserConversation {
                    itemUserConversation.appendConversation(tempConversation)
                }
            }
        }

        ref?.child("User").setValue(User.toAnyObject(users: usersInArray))
        
        tempConversation.appendMessage(tempMessage)
        ref?.child("Conversation").setValue(tempConversation.toAnyObject())


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //
    }
    ////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////LOGIN//////////////////////////////////////////
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var hintsLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var buttonLogin: UIButton!
    @IBAction func buttonSignUp(_ sender: UIButton) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            if segmentControl.selectedSegmentIndex == 0 {    // login
                
                FIRAuth.auth()?.signIn(withEmail: emailTextField.text!,
                                       password: passwordTextField.text!,
                                       completion: { (user, error) in
                if user != nil && (user?.isEmailVerified)! {
                  self.hintsLabel.text = ("success! you are in")
                } else {
                    if let myError = error?.localizedDescription {
                        self.hintsLabel.text = myError
                    } else {
                        self.hintsLabel.text = ("confirm your e-mail")
                    }
                }
            })
                
            } else {    // sign up
                FIRAuth.auth()?.createUser(withEmail: emailTextField.text!,
                                           password: passwordTextField.text!,
                                           completion: { (user, error) in
                
                                            if user != nil {
                                                 user?.sendEmailVerification(completion: nil) // send verification email
                                                self.hintsLabel.text = ("success")
                                            } else {
                                                if let myError = error?.localizedDescription {
                                                    self.hintsLabel.text = myError
                                                } else {
                                                    self.hintsLabel.text = ("Something went wrong")
                                                }
                                            }
                })
            }
        }
    }
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////LOGIN END//////////////////////////////////////

//MARK:- Regex expression

    func regexTest() {

        let arrayOfTestedData = ["BlaBlaBla", "Bla_Bla%Bla"]
        let regexLoginPattern = "^[a-zA-Z0-9-]*$"

        for itemInArray in arrayOfTestedData {
            let strinIsMatched = Regex.isMatchInString(for: regexLoginPattern, in: itemInArray)
            print ("string is matched: \(strinIsMatched)")
            
        }
        
        
        
    }
    
}























