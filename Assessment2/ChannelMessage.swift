//
//  ChannelMessage.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/04.
//

import MessageKit
import UIKit

class ChannelMessage: MessageType{
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    init(sender: Sender, messageId: String, sentDate: Date, message: String){
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = .text(message)
    }
}
