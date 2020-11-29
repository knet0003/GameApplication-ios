//
//  User.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/24.
//

import UIKit
import CoreLocation

class User: NSObject, Codable {
    var uid: String?
    var name: String?
    var latitude: Double?
    var longitude: Double?
  //  var profileImage: String?
    var DoB: Date?
    var email: String?
    

     private enum CodingKeys: String, CodingKey {
        case uid
        case name
        case latitude
        case longitude
    //    case profileImage
        case DoB
        case email
     }
}
