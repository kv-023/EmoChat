//
//  SingleConversationViewController.swift
//  EmoChat
//
//  Created by Olga Saliy on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

enum RightType {
    case sent
    case sending
}

enum UserType {
    case left
    case right (RightType)
}

extension SingleConversationViewController : CellDelegate {
    func cellDelegate(_ sender: UITableViewCell, didHandle action: Action) {
        if action == .longPress {
            //recognizer.view!.becomeFirstResponder()
            //let menu = UIMenuController.shared
            
            if let cell = sender as? CustomTableViewCell {
                //menu.setTargetRect(cell.message.frame, in: cell)
                showMenu(forCell: cell)
                //messageRecognized = cell.messageEntity
            }
            
            //        if let cell = sender as? LeftCell {
            //            menu.setTargetRect(cell.message.frame, in: cell)
            //            messageRecognized = cell.messageEntity
            //        } else if let cell = sender as? RightCell {
            //            menu.setTargetRect(cell.message.frame, in: cell)
            //            messageRecognized = cell.messageEntity
            //        }
            //menu.setMenuVisible(true, animated: true)
        }
    }
}

class SingleConversationViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var inputSubView: UIView!
    
    @IBOutlet weak var textMessage: UITextView!
    
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var textViewMaxHeightConstraint: NSLayoutConstraint!
    
    var manager: ManagerFirebase?
    
    var currentUser: User!
    
    var currentConversation: Conversation!
    
    var firstMessage : Message?
    
    var messagesArray: [(Message, UserType)] = []
    
    var refresher: UIRefreshControl!
    
    var messageRecognized: Message!
    
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.estimatedRowHeight = table.rowHeight
        table.rowHeight = UITableViewAutomaticDimension
        table.alwaysBounceVertical = false
        refresher = UIRefreshControl()
        table.backgroundView = refresher
        refresher.addTarget(self, action: #selector(updateUI), for: UIControlEvents.valueChanged)
        table.addSubview(refresher)
        
        if !messagesArray.isEmpty {
            table.scrollToRow(at: IndexPath.init(row: messagesArray.count - 1, section: 0), at: .top, animated: false)
        }
        self.setUpTextView()
        manager = ManagerFirebase.shared
        
        
        group.enter()
        manager?.getUsersInConversation(conversation: self.currentConversation, completion: { (users) in
            self.currentConversation.usersInConversation = users
            self.downloadPhotos()
            self.group.leave()
        })
        
        
        group.notify(queue: DispatchQueue.main, execute: {
            self.observeNewMessage()
        })
        
        self.observeDeletion()
        
        print(self.currentConversation.uuid)
        
        setupKeyboardObservers()
        
        self.setUpFrame()
        
        
    }
    
    
    func showMenu(forCell cell: CustomTableViewCell) {
        guard table.indexPath(for: cell) != nil else {
            return
        }
        
        let menu = UIMenuController.shared
        menu.setTargetRect(cell.contentRect, in: cell.contentView)
        let item = UIMenuItem(title: "Copy", action: #selector(copyAction(_:)))
        menu.menuItems = [item]
        
        if cell is RightCell {
            menu.menuItems?.append(UIMenuItem(title: "Delete", action: #selector(deleteAction(_:))))
        }
        menu.setMenuVisible(true, animated: true)
        
        messageRecognized = cell.messageEntity
    }
    
    //functionality
    
    func removeAtUid(_ uid: String) {
        let indexOfMessage: Int = messagesArray.index(where: {tuple in
            if tuple.0.uid == uid {
                return true
            } else {
                return false
            }
        })!
        messagesArray.remove(at: indexOfMessage)
        table.reloadData()
    }
    
    func deleteMessage(_ target: Message) {
        manager?.deleteMessage(target.uid!, from: currentConversation)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(copyAction(_:)):
            return true
        case #selector(deleteAction(_:)):
            return true
        default:
            return false
        }
    }
    
    func copyAction(_ sender: Any?) {
        UIPasteboard.general.string = messageRecognized.content!.content
        //.setValue(messageRecognized.content!.content, forPasteboardType: "TEXT")
    }
    
    func deleteAction(_ sender: Any?) {
        deleteMessage(messageRecognized)
    }
    
    func observeDeletion () {
        manager?.observeDeletionOfMessages(in: currentConversation) { uid in
            self.removeAtUid(uid)
        }
    }
    
    func observeNewMessage () {
        self.manager?.getMessageFromConversation([self.currentConversation], result: { (conv, newMessage) in
            if let lastMessageTime = self.messagesArray.last?.0.time {
                if lastMessageTime > newMessage.time {
                    return
                }
            }
            if let res = self.manager?.isMessageFromCurrentUser(newMessage) {
                if res == true {
                    
                    let index = self.messagesArray.index(where: { (message, typeRight) -> Bool in
                        message.uid == newMessage.uid
                    })
                    
                    if let i = index, let item = (self.table.cellForRow(at: IndexPath.init(row: i, section: 0)) as? RightCell) {
                        item.isReceived = true
                        self.messagesArray[i].1 = .right(.sent)
                    } else {
                        self.insertRow((newMessage, .right(.sent)))
                    }
                    
                } else {
                    self.insertRow((newMessage, .left))
                }
                
            }
            if !self.messagesArray.isEmpty {
                self.table.scrollToRow(at: IndexPath.init(row: self.messagesArray.count - 1, section: 0), at: .top, animated: false)
            }
        })
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        let result:MessageOperationResult? = manager?.createMessage(conversation: currentConversation!, sender: currentUser, content: (.text, textMessage.text))
        
        switch (result!) {
        case .successSingleMessage(let message):
            insertRow((message, .right(.sending)))
        case .failure(let string):
            print(string)
        default:
            break
        }
        
        if !messagesArray.isEmpty {
            self.table.scrollToRow(at: IndexPath.init(row: messagesArray.count - 1, section: 0), at: .top, animated: false)
        }
        //clean textView
        
        textMessage.text = ""
        
        textMessage.isScrollEnabled = false;
        self.textViewMaxHeightConstraint.isActive = false
        
        firstMessage = messagesArray[0].0
        
    }
    
    //download 20 last messages
    func updateUI() {
        if let firstMessage = messagesArray.first?.0 {
            self.refresher.endRefreshing()
            let initialOffset = self.table.contentOffset.y
            
            manager?.getBunchOfMessages(in: currentConversation, startingFrom: firstMessage.uid!, count: 20, result: { (result) in
                var arrayOfMessagesAndTypes = [(Message, UserType)] ()
                for each in result {
                    if (self.manager?.isMessageFromCurrentUser(each))! {
                        arrayOfMessagesAndTypes.append((each, .right(.sent)))
                    } else {
                        arrayOfMessagesAndTypes.append((each, .left))
                    }
                }
                self.insertRows(arrayOfMessagesAndTypes)
                self.table.reloadData()
                self.table.scrollToRow(at: IndexPath.init(row: arrayOfMessagesAndTypes.count+1, section: 0), at: .top, animated: false)
                self.table.contentOffset.y += initialOffset
            })
        }
    }


    
    
    //MARK: - photos
    
    var photosArray: [String: UIImage] = [:]
    
    var group = DispatchGroup()
    
    func downloadPhotos () {
        
        for member in currentConversation.usersInConversation{
            group.enter()
            if let photoURL = member.photoURL {
                manager?.getUserPic(from: photoURL, result: { (result) in
                    switch result {
                    case .successUserPic(let image):
                        self.photosArray.updateValue(image, forKey: member.uid)
                    case .failure(let error) :
                        print(error)
                    default:
                        break
                    }
                    self.group.leave()
                })
            }
            else {
                self.photosArray.updateValue(UIImage(named: "question_mark")!, forKey: member.uid)
                self.group.leave()
            }
        }
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
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
            cell.time.text = message.0.time.formatDate()
            cell.userPic.image = self.photosArray[message.0.senderId]
            
            cell.delegate = self
            
            return cell
        case .right:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Right", for: indexPath) as? RightCell else {
                fatalError("Cell was not casted!")
            }
            cell.messageEntity = message.0
            cell.userPic.image = self.photosArray[message.0.senderId]
            switch message.1 {
            case .right(.sent) :
                cell.isReceived = true
            case .right(.sending):
                cell.isReceived = false
            default:
                break
            }
            cell.delegate = self
            return cell
        }
    }
    
    
    func setUpFrame() {
        if let rect = self.navigationController?.navigationBar.frame {
            let y = rect.size.height + rect.origin.y
            table.frame = CGRect(x: table.frame.minX, y: table.frame.minY + y, width: table.frame.width, height: table.frame.height - y)
        }
    }
    
    
    func insertRow(_ newMessage: (Message, UserType)) {
        messagesArray.append((newMessage.0, newMessage.1))
        table.beginUpdates()
        table.insertRows(at: [IndexPath(row: messagesArray.count - 1, section: 0)], with: .automatic)
        table.endUpdates()
    }
    
    func insertRows (_ newMessages: [(Message, UserType)]) {
        messagesArray = newMessages + messagesArray
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
    
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.bounds.size
        //change the height of UITextView depending of a fixed width
        let newSize = textView.sizeThatFits( CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        
        if (newSize.height >= self.textViewMaxHeightConstraint.constant && !textView.isScrollEnabled) {
            textView.isScrollEnabled = true
            self.textViewMaxHeightConstraint.isActive = true
            
        } else if (newSize.height < self.textViewMaxHeightConstraint.constant && textView.isScrollEnabled) {
            textView.isScrollEnabled = false
            self.textViewMaxHeightConstraint.isActive = false
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
        if (textView.textColor == .lightGray){
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        if (textView.text == ""){
            textView.text = "Type message..."
            textView.textColor = .lightGray
        }
        textView.isScrollEnabled = false;
        self.textViewMaxHeightConstraint.isActive = false
        textView.resignFirstResponder()
    }
    
    //MARK: - subview to text and send message
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillChangeFrame, object: nil)
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
        if let keyboardSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect, let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            self.bottomConstraint.constant = keyboardSize.height
            UIView.animate(withDuration: keyboardDuration, animations: {
                self.view.layoutIfNeeded()
            })
            if !messagesArray.isEmpty {
                table.scrollToRow(at: IndexPath.init(row: messagesArray.count - 1, section: 0), at: .top, animated: false)
            }
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
        //TODO: remove observers
    }
    
    
    
}
