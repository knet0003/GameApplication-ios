//
//  VolumeData.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/20.
//

import UIKit

class VolumeData: NSObject , Decodable {
    var games: [GameData]?
    
    private enum CodingKeys: String, CodingKey {
        case games
    }
}
