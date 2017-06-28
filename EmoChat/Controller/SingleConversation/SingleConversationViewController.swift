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

class SingleConversationViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var leftCell = LeftCell()

    @IBOutlet weak var inputSubView: UIView!
    
    @IBOutlet weak var textMessage: UITextView!
    
    @IBAction func sendMessage(_ sender: UIButton) {
    
        
        let result:MessageOperationResult? = manager?.createMessage(conversation: currentConversation!, sender: currentUser, content: (.text, textMessage.text))
        
        switch (result!) {
        case .successSingleMessage(let message):
            insertRow((message, .right(.sending)))
            if !messagesArray.isEmpty {
                self.table.scrollToRow(at: IndexPath.init(row: messagesArray.count - 1, section: 0), at: .top, animated: false)
               // message.content.type = MessageContentType.emotion
            }
        case .failure(let string):
            print(string)
        default:
            break
        }
        
        //clean textView
        
        textMessage.text = ""
        
        textMessage.isScrollEnabled = false;
        self.textViewMaxHeightConstraint.isActive = false
        
        firstMessage = messagesArray[0].0
        
    }
    
    var manager: ManagerFirebase?
    
    var currentUser: User!
    
    var currentConversation: Conversation!
    
    var firstMessage : Message? {didSet {updateUI()}}
    
    var messagesArray: [(Message, UserType)] = []
    
    var load = false
    
    @IBOutlet weak var table: UITableView!
    
    func updateUI() {
        manager?.getBunchOfMessages(in: currentConversation, startingFrom: (firstMessage?.uid)!, count: 25, result: { (result) in
            var arrayOfMessagesAndTypes = [(Message, UserType)] ()
            for each in result {
                if (self.manager?.isMessageFromCurrentUser(each))! {
                    arrayOfMessagesAndTypes.append((each, .right(.sent)))
                    
                    
                } else {
                    arrayOfMessagesAndTypes.append((each, .left))
                }
            }
            
            self.insertRows(arrayOfMessagesAndTypes)
            
        })
        //download 20 last messages
    }
    
    func insertRow(_ newMessage: (Message, UserType)) {
        messagesArray.append((newMessage.0, newMessage.1))
        table.beginUpdates()
        table.insertRows(at: [IndexPath(row: messagesArray.count - 1, section: 0)], with: .automatic)
        table.endUpdates()
    }
    
    func insertRows (_ newMessages: [(Message, UserType)]) {
        self.table.beginUpdates()
        var indexPaths: [IndexPath] = []
        for i in 0..<newMessages.count {
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        messagesArray = newMessages + messagesArray
        table.insertRows(at: indexPaths, with: .automatic)
        
        self.table.endUpdates()
        //table.scrollToRow(at: indexPaths.last!, at: .top, animated: true)
        
        //load = false
    }
    
    
    //MARK: - photos
    
    var photosArray: [String: UIImage] = [:]
    
    var group = DispatchGroup()
    
    func downloadPhotos () {
        
        for member in currentConversation.usersInConversation{
            group.enter()
            manager?.getUserPic(from: member.photoURL!, result: { (result) in
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.estimatedRowHeight = table.rowHeight
        table.rowHeight = UITableViewAutomaticDimension
        table.allowsSelection = true
        if !messagesArray.isEmpty {
            table.scrollToRow(at: IndexPath.init(row: messagesArray.count - 1, section: 0), at: .top, animated: false)
            load = true
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
            self.manager?.getMessageFromConversation([self.currentConversation], result: { (conv, newMessage) in
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
//                    self.load = true
                }
                self.load = true
            })
        })
    
        print(self.currentConversation.uuid)
       
        
        
        setupKeyboardObservers()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
        if indexPath.row == 0 && load {
            firstMessage = messagesArray[0].0
    
            load = false
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
            
            if message.0.content.type == MessageContentType.emotion   {
                cell.blur.alpha = 0.35
                
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(recordEmotion))
                cell.isUserInteractionEnabled = true
                cell.addGestureRecognizer(tapGestureRecognizer)
            } else {
                cell.blur.alpha = 0
            }
            
            return cell
            
        case .right:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Right", for: indexPath) as? RightCell else {
                fatalError("Cell was not casted!")
            }
            cell.messageEntity = message.0
            //cell.time.text = message.0.time.formatDate()
            
            cell.userPic.image = self.photosArray[message.0.senderId]
            
            switch message.1 {
            case .right(.sent) :
                cell.isReceived = true
            case .right(.sending):
                cell.isReceived = false
            //cell.activityIndicator.startAnimating()
            default:
                break
            }
            //
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
   
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let s = table.indexPath(for: leftCell)
        
        if indexPath == s {
            print("12222")
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
        textView.isScrollEnabled = false;
        self.textViewMaxHeightConstraint.isActive = false
        textView.resignFirstResponder()
    }
    
    //MARK: - subview to text and send message
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewOnTable: UIView!
    
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
    
    override func viewDidLayoutSubviews() {
        if let rect = self.navigationController?.navigationBar.frame {
            let y = rect.size.height + rect.origin.y
            self.table.contentInset = UIEdgeInsetsMake( y, 0, 0, 0)
        }
    }
    
    func handleKeyboardWillShow (notification: Notification) {
        if let keyboardSize = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect, let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            self.bottomConstraint.constant = keyboardSize.height
            UIView.animate(withDuration: keyboardDuration, animations: {
                self.view.layoutIfNeeded()
            })
            if !messagesArray.isEmpty {
                table.scrollToRow(at: IndexPath.init(row: messagesArray.count - 1, section: 0), at: .top, animated: false)
//                load = true
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
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func recordEmotion(tapGestureRecognizer: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        //leftCell.blur.alpha = 0
        print("RECORD EMO")
        imagePicker.delegate = self
        //imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .video
        imagePicker.cameraDevice = .front
        imagePicker.startVideoCapture()
        present(imagePicker, animated: true, completion: nil)
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            imagePicker.stopVideoCapture()
            self.dismiss(animated:true, completion: nil)

        }
    }
    
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("FINISH PROSTO FINISH IMAGEPICKER")
        let tempImage = info[UIImagePickerControllerMediaURL] as! NSURL!
        let pathString = tempImage?.relativePath
        
        self.dismiss(animated: true, completion: nil)
        
        UISaveVideoAtPathToSavedPhotosAlbum(pathString!, self, nil, nil)
        print(pathString!)
    }
}
