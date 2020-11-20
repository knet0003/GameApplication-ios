//
//  GameSession.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/20.
//

import UIKit
import CoreLocation

class GameSession: NSObject, Codable {
    var id: String?
    var gamename: String?
    var sessionname: String?
    var playersneeded: Int?
    var latitude: String?
    var longitude: String?
    var sessiontime: Date?
    

     private enum CodingKeys: String, CodingKey {
        case id
        case gamename
        case sessionname
        case playersneeded
        case latitude
        case longitude
        case sessiontime
     }
}
