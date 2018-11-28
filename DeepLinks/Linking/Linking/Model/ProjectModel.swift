//
//  ProjectModel.swift
//  Linking
//
//  Created by Glny Gl on 1.11.2018.
//  Copyright © 2018 Glny Gl. All rights reserved.
//

import Foundation

struct ProjectModel{
    var id: String?
    var name: String?
    var type: String?
    var links: [String]?
    
    init(_ id: String, _ name: String, _ type: String, _ links: [String]){
        self.id = id
        self.name = name
        self.type = type
        self.links = links
    }
}
