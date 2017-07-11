//
//  SingleConversationViewController.swift
//  EmoChat
//
//  Created by Olga Saliy on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import SystemConfiguration

enum RightType {
    case sent
    case sending
}

enum UserType {
    case left
    case right (RightType)
}



class SingleConversationViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
//    
//    private struct Constants {
//        static let leadingConstraint: CGFloat = 8.0
//    }
//    
    // MARK: - constants
    let leadingConstraintConstant: CGFloat = 8.0
    let trailingConstraintConstant: CGFloat = 8.0
    let topConstraintConstant: CGFloat = 8.0
    
    // MARK: - IBOutlets
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var emoRequestButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var textMessageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputSubView: UIView!
    
    @IBOutlet weak var textMessage: CustomTextView!
    @IBOutlet weak var additionalBottomBarView: ConversationBottomBarView!
    @IBOutlet weak var textMessageBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textMessageTrailingConstraint: NSLayoutConstraint!
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
            self.group.leave()
        
        })
        
        navigationItem.title = currentConversation.name!
        
        self.observeDeletion()
        
        print(self.currentConversation.uuid)
        
        setupKeyboardObservers()
        
        self.setUpFrame()

        group.notify(queue: DispatchQueue.main, execute: {
            DispatchQueue.global().async {
                self.observeNewMessage()
                self.loadingView.isHidden = true
            }
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
        
    }

    
//    override func viewWillAppear(_ animated: Bool) {
//        if !messagesArray.isEmpty {
//            table.scrollToRow(at: IndexPath(row: messagesArray.count - 1, section: 0),
//                              at: .bottom, animated: false)
//        }
//    }
    
    func showMenu(forCell cell: CustomTableViewCell) {
        
        
        
        guard table.indexPath(for: cell) != nil else {
            return
        }
        
        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: true)
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
        var content: String
        if multipleChat && !(manager?.isMessageFromCurrentUser(messageRecognized))! {
            var contentArray = messageRecognized.content!.content.characters.split(separator: "\n")
            contentArray.remove(at: 0)
            let tempContent = contentArray.flatMap({String($0)})
            content = tempContent.joined(separator: "\n")
        } else {
            content = messageRecognized.content!.content
        }
        UIPasteboard.general.string = messageRecognized.content!.content
    }
    
    func deleteAction(_ sender: Any?) {
        deleteMessage(messageRecognized)
    }
    
    func removeMessageFromDictionary (index: (index: Int, section: String)?) {
        if let indexResult = index, let count = messagesArrayWithSection[index!.section]?.count {
            switch count {
            case 0:
                return
            case 1:
                sortedSections.remove(at: (sortedSections.index(of: indexResult.section))!)
                messagesArrayWithSection.removeValue(forKey: indexResult.section)
            default:
                messagesArrayWithSection[indexResult.section]?.remove(at: indexResult.index)
            }
        }
    }
    
    func removeAtUid(_ uid: String) {
        let result = self.findMessageInDictionary(with: uid)
        self.removeMessageFromDictionary(index: result)
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
    
    func findMessageInDictionary(with uid: String) -> (index: Int, section: String)? {
        var result: (index: Int, section: String)? = nil
        for section in self.messagesArrayWithSection {
            if let index = section.value.index(where: { (message, typeRight) -> Bool in
                message.uid == uid
            }) {
                result = (index, section.key)
            }
        }
        return result
    }
    
    func observeNewMessage () {
        manager?.getMessageFromConversation([self.currentConversation]) { (conv, newMessage) in
            if let lastSection = self.sortedSections.last, let lastMessageTime = self.messagesArrayWithSection[lastSection]?.last?.0.time {
                if lastMessageTime > newMessage.time {
                    return
                }
            }
            
            if let res = self.manager?.isMessageFromCurrentUser(newMessage) {
                if res == true {
                    
                    //check if sending message was delivered via findMessageInDictionary
                    //if yes should mark it as 'sent' 
                    
                    //find cell with this message
                    if let i = self.findMessageInDictionary(with: newMessage.uid!), let item = (self.table.cellForRow(at: IndexPath.init(row: i.index, section: self.sortedSections.index(of: i.section)!)) as? RightCell) {
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
            
        }
        
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        if textMessage.textColor != UIColor.lightGray && !textMessage.text.isEmpty && textMessage.text[textMessage.text.startIndex] != " " {
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
            refresher.removeFromSuperview()
            table.backgroundView = supportLabel
        } else {
            table.backgroundView = nil
            table.addSubview(refresher)
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
            cell.message.attributedText = NSAttributedString(string: "")
            cell.singleConversationControllerDelegate = self
            if multipleChat {
                let user = currentConversation.usersInConversation.first(where: {user in
                    return user.uid == message.0.senderId
                })
                var name = NSMutableAttributedString(string: "")
                if let first = user?.firstName {
                    name.append(NSMutableAttributedString(string: first, attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: CGFloat.init(15.0))]))
                }
                if let second = user?.secondName {
                    name.append(NSMutableAttributedString(string: " \(second)", attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: CGFloat.init(15.0))]))
                }
                if name == NSMutableAttributedString(string: "") {
                    name.append(NSMutableAttributedString(string: (user?.username)!, attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: CGFloat.init(15.0))]))
                }
                name.append(NSAttributedString(string: "\n"))
                cell.name = name
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

        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 242, green: 242, blue: 242)
        let newlabel = UILabel()
        newlabel.textAlignment = .center
        newlabel.font = UIFont.systemFont(ofSize: 14)
        newlabel.text = sortedSections[section]
        
        headerView.addSubview(newlabel)
        newlabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addConstraint(NSLayoutConstraint(item: newlabel, attribute: .leading, relatedBy: .equal, toItem: headerView, attribute: .leading, multiplier: 1.0, constant: 0))
        headerView.addConstraint(NSLayoutConstraint(item: newlabel, attribute: .trailing, relatedBy: .equal, toItem: headerView, attribute: .trailing, multiplier: 1.0, constant: 20.0))
        headerView.addConstraint(NSLayoutConstraint(item: newlabel, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1.0, constant: 0))
        headerView.addConstraint(NSLayoutConstraint(item: newlabel, attribute: .bottom, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        return headerView
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
    
    //MARK: - Additional methods for adding new message to tableView
    func createNewSection (date: Date) -> String {
        if !sortedSections.isEmpty && (date.dayFormatStyleDate() < (messagesArrayWithSection[sortedSections[0]]?.first!.0.time.dayFormatStyleDate())!) {
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
        //textView.becomeFirstResponder() //Optional
        
        if plusButton.isSelected {
            plusButton.isSelected = false
            animateBottomBar(plusIsSelected: plusButton.isSelected)
        }
        self.animateTextViewTransitions(becomeFirstResponder: true)
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
    
//    override func viewWillLayoutSubviews() {
//        table.reloadData()
//    }
    
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
    
    // MARK: - Check Internet Connection
    
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
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
            textMessageLeadingConstraint.constant -= (leadingConstraintConstant * 2) + emoRequestButton.frame.width + plusButton.frame.width//two buttons so 2 extra spaces
            textMessageTrailingConstraint.constant -= sendMessageButton.frame.width + trailingConstraintConstant
            self.additionalBottomBarView.isHidden = !plusIsSelected
        } else {
            textMessageBottomConstraint.constant -= height + topConstraintConstant
            textMessageLeadingConstraint.constant = leadingConstraintConstant
            textMessageTrailingConstraint.constant = trailingConstraintConstant
        }

        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.7,
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
                       usingSpringWithDamping: 0.7,
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
//                if self.inputSubView.isFirstResponder {
//                    self.textMessage.overrideNextResponder = cell
//                } else {
                    cell.message.becomeFirstResponder()
                    showMenu(forCell: cell)
//                }
                
            }
        }
    }
    
}
