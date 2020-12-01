//
//  ChatMessagesViewController.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/04.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

class ChatMessagesViewController: MessagesViewController, MessagesDataSource,
                                  MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    var sender: Sender?
    var currentChannel: Channel?
    var messagesList = [ChannelMessage]()
    
    var channelRef: CollectionReference?
    var databaseListener: ListenerRegistration?
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm dd/MM/yy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        
        messageInputBar.delegate = self
        if currentChannel != nil {
            let database = Firestore.firestore()
            channelRef = database.collection("channels")
                .document(currentChannel!.id).collection("messages")
            navigationItem.title = "\(currentChannel!.name)"
        }
        self.messageInputBar.contentView.backgroundColor = UIColor.darkGray
        self.messageInputBar.inputTextView.textColor = UIColor.white
        self.messageInputBar.sendButton.setTitleColor(.green, for: .normal)
        self.messageInputBar.backgroundView.backgroundColor = UIColor.darkGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        databaseListener = channelRef?.order(by: "time")
            .addSnapshotListener { (querySnapshot, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({change in
                    
                    if change.type == .added {
                        let snapshot = change.document
                        
                        let id = snapshot.documentID
                        let senderId = snapshot["senderId"] as! String
                        let senderName = snapshot["senderName"] as! String
                        let messageText = snapshot["text"] as! String
                        let sentTimestamp = snapshot["time"] as! Timestamp
                        let sentDate = sentTimestamp.dateValue()
                        
                        let sender = Sender(id: senderId, name: senderName)
                        let message = ChannelMessage(sender: sender, messageId: id,
                                                     sentDate: sentDate, message: messageText)
                        self.messagesList.append(message)
                        self.messagesCollectionView
                            .insertSections([self.messagesList.count-1])
                    }
                })
                
                self.messagesCollectionView.scrollToBottom()
                self.messagesCollectionView.backgroundColor = UIColor.darkGray
            }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseListener?.remove()
    }
    
    // MARK: - Messages Data Source
    func currentSender() -> SenderType {
        guard let sender = sender else {
            return Sender(id: "",name: "") as! SenderType
        }
        return sender as SenderType
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView:
                            MessagesCollectionView) -> MessageType {
        return messagesList[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView:
                            MessagesCollectionView) -> Int {
        messagesList.count
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at
                                        indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        
        return NSAttributedString(string: name, attributes:
                                    [NSAttributedString.Key.font:
                                        UIFont.preferredFont(forTextStyle: .caption1), NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at
                                            indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes:
                                    [NSAttributedString.Key.font:
                                        UIFont.preferredFont(forTextStyle: .caption2), NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    // MARK: - Message Input Bar Delegate Functions
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith
                    text: String) {
        if text.isEmpty {
            return
        }
        
        channelRef?.addDocument(data: [
            "senderId" : sender!.senderId,
            "senderName" : sender!.displayName,
            "text" : text,
            "time" : Timestamp(date: Date.init())
        ])
        
        inputBar.inputTextView.text = ""
    }
    
    // MARK: - MessagesLayoutDelegate
    
    func cellTopLabelHeight(for message: MessageType, at indexPath:
                                IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath:
                                IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath:
                                IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath:
                                    IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in
                        messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message)
            ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
}
