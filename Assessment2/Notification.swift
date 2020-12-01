//
//  Notification.swift
//  Assessment2
//
//  Created by user173263 on 12/1/20.
//

import UIKit

class Notification: NSObject {

    let id: String
    let name: String
    let date: Date
    
    init(id: String, name: String, date: Date){
        self.id = id
        self.name = name
        self.date = date
    }
}
