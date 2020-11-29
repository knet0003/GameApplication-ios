//
//  UserInfoBasic.swift
//  Assessment2
//
//  Created by chayan on 11/30/20.
//

import UIKit

class UserInfo: NSObject {
    
    let uid: String
    let name: String
    let email: String
    
    init(uid: String, name: String, email: String){
        self.uid = uid
        self.name = name
        self.email = email
    }

}
