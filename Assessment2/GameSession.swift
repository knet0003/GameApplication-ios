//
//  GameSession.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/20.
//

import UIKit
import CoreLocation

class GameSession: NSObject, Decodable {
    var id: String?
    var gamename: String?
    var sessionname: String?
    var playersneeded: Int?
    var location: CLLocationCoordinate2D?
    var sessiontime: Date?
    

     private enum CodingKeys: String, CodingKey {
        case id
        case gamename
        case sessionname
        case playersneeded
        case location
        case sessiontime
        
     }
}
