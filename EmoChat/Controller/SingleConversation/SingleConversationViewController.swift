//
//  SingleConversationViewController.swift
//  EmoChat
//
//  Created by Olga Saliy on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class SingleConversationViewController: UIViewController {
    
    @IBOutlet weak var textMessage: UITextView!
    
    @IBAction func sendMessage(_ sender: UIButton) {

        let result:MessageOperationResult? = manager?.createMessage(conversation: currentConversation!, sender: currentUser, content: (.text, textMessage.text))

        switch (result!) {
        case .successSingleMessage(let message):
            print(message.content)
        case .failure(let string):
            print(string)
        default:
            break
        }
    }
    
    var manager: ManagerFirebase?
    
    var currentUser: User!
    
    var currentConversation: Conversation! { didSet { updateUI() } }
    
    func updateUI() {
        //download 20 last messages
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = ManagerFirebase.shared
        manager?.getCurrentUser { (result) in
            switch (result) {
            case .successSingleUser(let user):
                self.currentUser = user
                self.currentConversation = user.userConversations?.first!
            case .failure(let error):
                print(error)
            default:
                break
            }
            
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
