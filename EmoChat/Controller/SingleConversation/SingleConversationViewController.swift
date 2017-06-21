//
//  SingleConversationViewController.swift
//  EmoChat
//
//  Created by Olga Saliy on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class SingleConversationViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var inputSubView: UIView!
    
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
        
        self.setUpTextView()
        
        manager = ManagerFirebase.shared
        manager?.getCurrentUser { (result) in
            switch (result) {
            case .successSingleUser(let user):
                self.currentUser = user
                self.currentConversation = user.userConversations?.first!
                print(self.currentConversation.uuid)
            case .failure(let error):
                print(error)
            default:
                break
            }
            
        }
        
        setupKeyboardObservers()

    }

    //MARK: - text view
    
    func setUpTextView () {
        textMessage.delegate = self
        textMessage.text = "Type message..."
        textMessage.textColor = .lightGray
        
        textMessage.layer.cornerRadius = 10
        textMessage.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        textMessage.layer.borderWidth = 0.5
        textMessage.clipsToBounds = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.textColor == .lightGray)
        {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = "Type message..."
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
    
    //MARK: - subview to text and send message
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func handleKeyboardWillHide (notification: Notification) {
        if let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue{
            
            self.bottomConstraint.constant = 0
            UIView.animate(withDuration: keyboardDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func handleKeyboardWillShow (notification: Notification) {
        if let keyboardSize = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect, let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            

            self.bottomConstraint.constant = keyboardSize.height
            UIView.animate(withDuration: keyboardDuration, animations: {
                self.view.layoutIfNeeded()
            })
//            subViewBottomAnchor?.constant = keyboardSize.height
//            inputSubView.bottomAnchor.constraint(equalTo: subViewBottomAnchor)
//            subViewBottomAnchor?.isActive = true
        }
    }
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
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
