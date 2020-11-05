//
//  Sender.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/04.
//

import UIKit
import MessageKit

class Sender: SenderType {
    var senderId: String
    var displayName: String
    
    init(id: String, name: String){
        senderId = id
        displayName = name
    }
}
