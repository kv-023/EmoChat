//
//  SingleConversationViewController.swift
//  EmoChat
//
//  Created by Olga Saliy on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

enum UserType {
    case left
    case right
}

class SingleConversationViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var inputSubView: UIView!
    
    @IBOutlet weak var textMessage: UITextView!
    
    // MARK: -TODO
    func recieveMessage() {
        
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {

        let result:MessageOperationResult? = manager?.createMessage(conversation: currentConversation!, sender: currentUser, content: (.text, textMessage.text))
        switch (result!) {
        case .successSingleMessage(let message):
            print(message.content)
            messagesArray.append((message, .right))
            table.beginUpdates()
            table.insertRows(at: [IndexPath(row: messagesArray.count - 1, section: 0)], with: .automatic)
            table.endUpdates()
        case .failure(let string):
            print(string)
        default:
            break
        }
    }
    
    var manager: ManagerFirebase?
    
    var currentUser: User!
    
    var currentConversation: Conversation! { didSet { updateUI() } }
    
    var messagesArray: [(Message, UserType)] = [(Message(uid: "123", senderId: "123", time: Date.init(milliseconds: 100), content: (type: .text, content: "HEi")), .left), (Message(uid: "123", senderId: "123", time: Date.init(milliseconds: 100), content: (type: .text, content: "HELLOk.zdjxvl;dfjsldfjkgvdfi")), .right), (Message(uid: "123", senderId: "123", time: Date.init(milliseconds: 100), content: (type: .text, content: "HELLOk.zdjxvl;dfjsldfjkgvdfi")), .right), (Message(uid: "123", senderId: "123", time: Date.init(milliseconds: 100), content: (type: .text, content: "HELLOk.zdjxvl;dfjsldfjkgvdfi")), .right), (Message(uid: "123", senderId: "123", time: Date.init(milliseconds: 100), content: (type: .text, content: "HELLOk.zdjxvl;dfjsldfjkgvdfi")), .right), (Message(uid: "123", senderId: "123", time: Date.init(milliseconds: 100), content: (type: .text, content: "HELLOk.zdjxvl;dfjsldfjkgvdfi")), .right), (Message(uid: "123", senderId: "123", time: Date.init(milliseconds: 100), content: (type: .text, content: "HELLOk.zdjxvl;dfjsldfjkgvdfi")), .right), (Message(uid: "123", senderId: "123", time: Date.init(milliseconds: 100), content: (type: .text, content: "HELLOk.zdjxvl;dfjsldfjkgvdfi")), .right), (Message(uid: "123", senderId: "123", time: Date.init(milliseconds: 100), content: (type: .text, content: "HELLOk.zdjxvl;dfjsldfjkgvdfi")), .right), (Message(uid: "123", senderId: "123", time: Date.init(milliseconds: 100), content: (type: .text, content: "HELLOk.zdjxvl;dfjsldfjkgvdfi")), .right), (Message(uid: "123", senderId: "123", time: Date.init(milliseconds: 100), content: (type: .text, content: "HELLOk.zdjxvl;dfjsldfjkgvdfi")), .right), (Message(uid: "123", senderId: "123", time: Date.init(milliseconds: 100), content: (type: .text, content: "HELLOk.zdjxvl;dfjsldfjkgvdfi")), .right), (Message(uid: "123", senderId: "123", time: Date.init(milliseconds: 100), content: (type: .text, content: "last")), .right)]
    
    @IBOutlet weak var table: UITableView!
    
    func updateUI() {
        //download 20 last messages
    }
    
   /* func insertRows(_ newMessages: [Message]) {
        table.beginUpdates()
        table.insertRows(at: [IndexPath(row: messagesArray.count - 1, section: 0)], with: .automatic)
        table.endUpdates()
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        table.estimatedRowHeight = table.rowHeight
        table.rowHeight = UITableViewAutomaticDimension
        /*table.contentInset.bottom = 20
        table.scrollIndicatorInsets.bottom = 20*/
        table.reloadData()
        table.scrollToRow(at: IndexPath.init(row: messagesArray.count - 1, section: 0), at: .top, animated: false)
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messagesArray[indexPath.row]
        switch message.1 {
        case .left:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Left", for: indexPath) as? LeftCell else {
                fatalError("Cell was not casted!")
            }
            cell.messageEntity = message.0
            return cell
        case .right:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Right", for: indexPath) as? RightCell else {
                fatalError("Cell was not casted!")
            }
            cell.messageEntity = message.0
            return cell
        }
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
    
    @IBOutlet weak var textViewMaxHeightConstraint: NSLayoutConstraint!
    func textViewDidChange(_ textView: UITextView) {
        
        //разм
        let size = textView.bounds.size
       //change the height of UITextView depending of a fixed width
        let newSize = textView.sizeThatFits( CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        
        if (newSize.height >= self.textViewMaxHeightConstraint.constant && !textView.isScrollEnabled) {
            textView.isScrollEnabled = true;
            self.textViewMaxHeightConstraint.isActive = true;
        } else if (newSize.height < self.textViewMaxHeightConstraint.constant && textView.isScrollEnabled) {
            textView.isScrollEnabled = false;
            self.textViewMaxHeightConstraint.isActive = false;
        }
        
        
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
