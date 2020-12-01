//
//  GameData.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/20.
//

import UIKit

class GameData: NSObject, Decodable {
    var name: String?
    var imageURL: String?
    
    private enum RootKeys: String, CodingKey {
        case name
        case imageURL = "image_url"
        
    }
    
    required init(from decoder: Decoder) throws {
        let cardContainer = try decoder.container(keyedBy: RootKeys.self)
        
        name = try cardContainer.decode(String.self, forKey: .name)
        imageURL = try? cardContainer.decode(String.self, forKey: .imageURL)
        
    }
    
}

