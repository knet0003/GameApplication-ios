//
//  GameSession.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/20.
//

import UIKit
import CoreLocation

class GameSession: NSObject, Codable {
    var sessionid: String?
    var gamename: String?
    var sessionname: String?
    var playersneeded: Int?
    var latitude: Double?
    var longitude: Double?
    var sessiontime: Date?
    var sessionowner: String?
    var gameimage: String?
    var players: [String]?
    
    
    private enum CodingKeys: String, CodingKey {
        case sessionid
        case gamename
        case sessionname
        case playersneeded
        case latitude
        case longitude
        case sessiontime
        case sessionowner
        case gameimage
        case players
    }
}
