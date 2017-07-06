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



class SingleConversationViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate{
    
    // MARK: - constants
    let leadingConstraintConstant: CGFloat = 8.0
    let topConstraintConstant: CGFloat = 8.0
    
    // MARK: - IBOutlets
    @IBOutlet weak var emoRequestButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var textMessageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputSubView: UIView!
    
    @IBOutlet weak var textMessage: CustomTextView!
    @IBOutlet weak var additionalBottomBarView: ConversationBottomBarView!
    @IBOutlet weak var textMessageBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var textViewMaxHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!    
    
    var manager: ManagerFirebase?
    var currentUser: User!
    var currentConversation: Conversation!
    var firstMessage : Message?
    
    var sortedSections: [String] = []
    var messagesArrayWithSection: [String : [(Message, UserType)]] = [:]
    
    var messagesArray: [(Message, UserType)] = []
    var refresher: UIRefreshControl!
    var cellResized = Set<CustomTableViewCell>()
    var messageRestModel: [Message: MessageModel?] = [:]
    var messageRecognized: Message!
    var photosArray: [String: UIImage] = [:]
    var group = DispatchGroup()
    var multipleChat = false
    
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
        table.alwaysBounceVertical = true
        loadingIndicator.startAnimating()
        loadingIndicator.hidesWhenStopped = true

        self.setUpTextView()
        manager = ManagerFirebase.shared
        
        group.enter()
        manager?.getUsersInConversation(conversation: self.currentConversation,
                                        completion: { (users) in
            self.currentConversation.usersInConversation = users
            self.downloadPhotos()
            print("new thread")
            self.group.leave()
        
        })
        print("Main thread")
        if currentConversation.usersInConversation.count > 2 {
            multipleChat = true
        } else {
            multipleChat = false
        }
        navigationItem.title = currentConversation.name ?? "Chat"
        
        navigationItem.title = currentConversation.name!

        group.notify(queue: DispatchQueue.main, execute: {
            self.observeNewMessage()
            if self.currentConversation.usersInConversation.count > 2 {
                self.multipleChat = true
            }
        })
        
        group.enter()
        manager?.isConversationEmpty(currentConversation) { result in
            if result {
                self.loadingView.isHidden = true
            }
            self.group.leave()
        }
        
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
        menu.update()
        
        if cell is RightCell {
            menu.menuItems?.append(UIMenuItem(title: "Delete", action: #selector(deleteAction(_:))))
        }
        menu.setMenuVisible(true, animated: true)
        
        messageRecognized = cell.messageEntity
    }
    
    //functionality
    
    func copyAction(_ sender: Any?) {
        UIPasteboard.general.string = messageRecognized.content!.content
    }
    
    func deleteAction(_ sender: Any?) {
        deleteMessage(messageRecognized)
    }
    
    func removeAtUid(_ uid: String) {
        let indexOfMessage: Int = messagesArray.index(where: {tuple in
            if tuple.0.uid == uid {
                return true
            } else {
                return false
            }
        })!

        //nik
        let notNullMessageInArray = messagesArray[indexOfMessage].0
//        messageRestModel.removeValue(forKey: notNullMessageInArray)

        messagesArray.remove(at: indexOfMessage)

        table.reloadData()
    }
    
    func deleteMessage(_ target: Message) {
        manager?.deleteMessage(target.uid!, from: currentConversation)
    }
    
    func observeDeletion () {
        manager?.observeDeletionOfMessages(in: currentConversation) { uid in
            self.removeAtUid(uid)
        }
    }
    
    func observeNewMessage () {
        self.manager?.getMessageFromConversation([self.currentConversation], result: { (conv, newMessage) in
            if let lastSection = self.sortedSections.last, let lastMessageTime = self.messagesArrayWithSection[lastSection]?.last?.0.time {
                if lastMessageTime > newMessage.time {
                    return
                }
            }
            
            if let res = self.manager?.isMessageFromCurrentUser(newMessage) {
                if res == true {
                    
                    //check if sending message was delivered
                    //if yes should mark it as 'sent'
                    var result: (index: Int, section: String)? = nil
                    for section in self.messagesArrayWithSection {
                        if let index = section.value.index(where: { (message, typeRight) -> Bool in
                            message.uid == newMessage.uid
                        }) {
                            result = (index, section.key)
                        }
                    }
                    
                    //find cell with this message
                    if let i = result, let item = (self.table.cellForRow(at: IndexPath.init(row: i.index, section: self.sortedSections.index(of: i.section)!)) as? RightCell) {
                        item.isReceived = true
                        self.messagesArrayWithSection[i.section]?[i.index].1 = .right(.sent)
                    } else {
                        self.insertRow((newMessage, .right(.sent)))
                    }
                    
                } else {
                    self.insertRow((newMessage, .left))
                }
                
            }
            if !self.messagesArrayWithSection.isEmpty {
                self.table.scrollToRow(at: IndexPath.init(row: (self.messagesArrayWithSection[self.sortedSections.last!]?.count)! - 1, section: self.sortedSections.count - 1), at: .top, animated: false)
            }
            self.loadingView.isHidden = true
        })
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        let result:MessageOperationResult? = manager?.createMessage(
            conversation: currentConversation!,
            sender: currentUser,
            content: (.text, textMessage.text))

        switch (result!) {
        case .successSingleMessage(let message):
            insertRow((message, .right(.sending)))
        case .failure(let string):
            print(string)
        default:
            break
        }
        
        if !self.messagesArrayWithSection.isEmpty {
            self.table.scrollToRow(at: IndexPath.init(row: (self.messagesArrayWithSection[self.sortedSections.last!]?.count)! - 1, section: self.sortedSections.count - 1), at: .top, animated: false)
        }

        //clean textView
        textMessage.text = ""
        textMessage.isScrollEnabled = false;

        self.textViewMaxHeightConstraint.isActive = false
        
        
        //firstMessage = messagesArray.first?.0 //messagesArray[0].0
    }
    
    //download 20 last messages
    func updateUI() {
        if let firstMessage = messagesArrayWithSection[sortedSections[0]]!.first?.0 {
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
                let startIndex = self.messagesArrayWithSection[self.sortedSections.first!]?.count
                let startSection = self.sortedSections[0]
                self.insertRows(arrayOfMessagesAndTypes)
                self.table.reloadData()
                self.table.scrollToRow(at: IndexPath.init(row: (self.messagesArrayWithSection[startSection]?.count)! - startIndex!, section: self.sortedSections.index(of: startSection)!), at: .top, animated: false)
                self.table.contentOffset.y += initialOffset
            })
        }
    }


    
    
    //MARK: - photos
    
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
            cell.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if sortedSections.count == 0 {
            let supportLabel = UILabel()
            supportLabel.textColor = UIColor.lightGray
            supportLabel.text = "No messages yet"
            supportLabel.textAlignment = .center
            table.backgroundView = supportLabel
        } else {
            table.backgroundView = nil
        }
        return sortedSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArrayWithSection[sortedSections[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messagesArrayWithSection[sortedSections[indexPath.section]]![indexPath.row]
            //messagesArray[indexPath.row]
        
        
        switch message.1 {
        case .left:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Left", for: indexPath) as? LeftCell else {
                fatalError("Cell was not casted!")
            }
            cell.message.text = ""
            cell.singleConversationControllerDelegate = self
            if multipleChat {
                let user = currentConversation.usersInConversation.first(where: {user in
                    print("first")
                    return user.uid == message.0.senderId
                })
                print("second")
                var name = ""
                if let first = user?.firstName {
                    name.append(first)
                }
                if let second = user?.secondName {
                    name.append(" \(second)")
                }
                if name == "" {
                    name.append((user?.username)!)
                }
                cell.message.text.append(name)
                cell.message.text.append("\n")
            }
            cell.messageEntity = message.0

            setMessageModelInCell(currentCell: cell, message: cell.messageEntity)

            cell.time.text = message.0.time.formatDate()
            cell.userPic.image = self.photosArray[message.0.senderId]
            cell.delegate = self
            return cell
        case .right:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Right", for: indexPath) as? RightCell else {
                fatalError("Cell was not casted!")
            }
            cell.message.text = ""
            cell.singleConversationControllerDelegate = self
            cell.message.text = ""
            cell.messageEntity = message.0

            setMessageModelInCell(currentCell: cell, message: cell.messageEntity)

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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:18))
        let label = UILabel(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:18))
        label.font = UIFont.systemFont(ofSize: 14)
        
        label.text = sortedSections[section];
        label.textAlignment = .center
       // label.backgroundColor = UIColor(red: 242, green: 242, blue: 242)
        view.addSubview(label);
        view.backgroundColor = UIColor(red: 242, green: 242, blue: 242)
        return view
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedSections[section]
    }

    //nik
    private func setMessageModelInCell(currentCell cell: CustomTableViewCell,
                                       message messageEntity: Message?) {
        if let notNullMessageEntity = messageEntity,
            let messageModelInDictionary = messageRestModel[notNullMessageEntity],
            messageModelInDictionary != nil {
            cell.messageModel = messageModelInDictionary
            cell.updateUIForMessageModel()
        } else {
            cell.parseDataFromMessageTextForCell()
        }
    }

    func setUpFrame() {
        if let rect = self.navigationController?.navigationBar.frame {
            let y = rect.size.height + rect.origin.y
            table.frame = CGRect(x: table.frame.minX, y: table.frame.minY + y, width: table.frame.width, height: table.frame.height - y)
        }
    }
    
    func createNewSection (date: Date) -> String {
        if !sortedSections.isEmpty && (date.dayFormatStyle() < (messagesArrayWithSection[sortedSections[0]]?.first!.0.time.dayFormatStyle())!) {
            self.sortedSections.insert(date.dayFormatStyle(), at: 0)
        } else {
            self.sortedSections.append(date.dayFormatStyle())
        }
        
        self.messagesArrayWithSection.updateValue([], forKey: date.dayFormatStyle())
        table.reloadData()
        return date.dayFormatStyle()
    }

    func findAppropriateSection(for message: Message) -> String? {
        return sortedSections.contains(message.time.dayFormatStyle()) ? message.time.dayFormatStyle() : nil
    }
    
    func addMessageToTheEndOfDictionary (_ message: (Message, UserType)) -> IndexPath {
        let nameOfSection = self.findAppropriateSection(for: message.0) ?? self.createNewSection(date: message.0.time)
        self.messagesArrayWithSection[nameOfSection]?.append(message)
        return IndexPath(row: (messagesArrayWithSection[nameOfSection]?.count)! - 1, section: sortedSections.index(of: nameOfSection)!)
    }
    
    func addMessageAtTheBeginningOfDictionary (_ message: (Message, UserType))  {
        let nameOfSection = self.findAppropriateSection(for: message.0) ?? self.createNewSection(date: message.0.time)
        self.messagesArrayWithSection[nameOfSection]?.insert(message, at: 0)
    }
    
    func addMessagesToDictionary (_ messages: [(Message, UserType)]) {
        for each in messages.reversed() {
            self.addMessageAtTheBeginningOfDictionary(each)
        }
    }
    
    func insertRow(_ newMessage: (Message, UserType)) {
        let indexPath = self.addMessageToTheEndOfDictionary(newMessage)
        table.insertRows(at: [indexPath], with: .none)

    }
    
    func insertRows (_ newMessages: [(Message, UserType)]) {
        self.addMessagesToDictionary(newMessages)
    }
    

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {

//        var cellHeightForReturn:CGFloat = UITableViewAutomaticDimension
//
//        if let cellInstance = table.cellForRow(at: indexPath) as? SingleConversationUITableViewCell {
//            if cellResized.contains(cellInstance) {
//
//                cellHeightForReturn = cellInstance.temporaryCellHeight + cellInstance.extraCellHeiht
//            }
//
//            return cellHeightForReturn
//        } else {
//            return UITableViewAutomaticDimension
//        }

        return UITableViewAutomaticDimension
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
        
        self.animateTextViewTransitions(becomeFirstResponder: true)
        if plusButton.isSelected {
            plusButton.isSelected = false
            animateBottomBar(plusIsSelected: plusButton.isSelected)
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        if (textView.text == ""){
            textView.text = "Type message..."
            textView.textColor = .lightGray
        }
        textView.isScrollEnabled = false;
        self.textViewMaxHeightConstraint.isActive = false
        textView.resignFirstResponder()
        
        self.animateTextViewTransitions(becomeFirstResponder: false)
    }
    
    //MARK: - subview to text and send message
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    func handleKeyboardWillHide (notification: Notification) {
        if let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            
            self.bottomConstraint.constant = 0
            UIView.animate(withDuration: keyboardDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func handleKeyboardWillShow (notification: Notification) {
        if let keyboardSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect, let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            self.bottomConstraint.constant = keyboardSize.height
            UIView.animate(withDuration: keyboardDuration,
                           animations: {
                self.view.layoutIfNeeded()
            })

            if !self.messagesArrayWithSection.isEmpty {
                self.table.scrollToRow(at: IndexPath.init(row: (self.messagesArrayWithSection[self.sortedSections.last!]?.count)! - 1, section: self.sortedSections.count - 1), at: .top, animated: false)
            }        }
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

//MARK:- SingleConversationCellProtocol
extension SingleConversationViewController: SingleConversationControllerProtocol {

    func resizeSingleConversationCell(cell: CustomTableViewCell) {
        if let indexPath = table.indexPath(for: cell) {

            cellResized.insert(cell)

            table.beginUpdates()
            table.rectForRow(at: indexPath)

            cell.temporaryCellHeight = table.rectForRow(at: indexPath).height// - cell.extraCellHeiht

            //self.tableView.reloadRows(at: [indexPath],
            //                          with: UITableViewRowAnimation.automatic)
            // self.tableView.moveRow(at: indexPath, to: indexPath)
            cell.updateConstraintsIfNeeded()
            cell.previewContainer.updateConstraintsIfNeeded()
            table.endUpdates()
            
        }
    }

    func addMessageModelInSingleConversationDictionary(message: Message,
                                                       model: MessageModel?) {

//        messageRestModel.updateValue(model, forKey: message)
    }
    
}

//MARK:- SingleConversationViewController
extension SingleConversationViewController : CellDelegate {
    func cellDelegate(_ sender: UITableViewCell, didHandle action: Action) {
        if action == .longPress {
            
            if let cell = sender as? CustomTableViewCell {
                cell.message.becomeFirstResponder()
                //SingleConversationViewController.selectedCell = cell
                showMenu(forCell: cell)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func actionEmoRequestButton(_ sender: UIButton) {
        if emoRequestButton.isSelected {
            emoRequestButton.isSelected = false
        } else {
            emoRequestButton.isSelected = true
        }
    }
    
    @IBAction func actionPlusButton(_ sender: UIButton) {
        
        if plusButton.isSelected {
            plusButton.isSelected = false
        } else {
            plusButton.isSelected = true
        }
        self.animateBottomBar(plusIsSelected: plusButton.isSelected)
    }
    
    // MARK: - BottomBarAnimations
    
    func animateBottomBar(plusIsSelected: Bool) {
        
        view.layoutIfNeeded()
        
        let height = additionalBottomBarView.frame.height
        
        if plusIsSelected {
            textMessageBottomConstraint.constant += height + topConstraintConstant
            self.additionalBottomBarView.isHidden = !plusIsSelected
        } else {
            textMessageBottomConstraint.constant -= height + topConstraintConstant
        }
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0,
                       initialSpringVelocity: 0,
                       options: [.curveLinear],
                       animations: {
                        self.view.layoutIfNeeded()
                        if plusIsSelected {
                            self.additionalBottomBarView.alpha = 1.0
                        } else {
                            self.additionalBottomBarView.alpha = 0.0
                        }
        },
                       completion: { _ in
                        self.additionalBottomBarView.isHidden = !plusIsSelected
        })
    }
    
    func animateTextViewTransitions(becomeFirstResponder: Bool) {
        
        view.layoutIfNeeded()
    
        let width = plusButton.frame.width + leadingConstraintConstant
        
        if becomeFirstResponder {
            textMessageLeadingConstraint.constant -= width
        } else {
            textMessageLeadingConstraint.constant += width
            self.plusButton.isHidden = becomeFirstResponder
        }
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0,
                       initialSpringVelocity: 0,
                       options: [.curveLinear],
                       animations: {
                        self.view.layoutIfNeeded()
                        if becomeFirstResponder {
                            self.plusButton.alpha = 0.0
                        } else {
                            self.plusButton.alpha = 1.0
                        }
        },
                       completion: { (_) in
                        self.plusButton.isHidden = becomeFirstResponder
        })
    }
    
}
