//
//  User.swift
//  Route
//
//  Created by Евгений Иванов on 12/08/2019.
//  Copyright © 2019 Евгений Иванов. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class User: Object {
    
    enum Properties: String {
        case login
        case password
    }
    
    dynamic var login: String = ""
    dynamic var password: String = ""
    let coordinates = List<Coordinate>()
    
    convenience init(login: String, password: String) {
        self.init()
        self.login = login
        self.password = password
    }
    
    override static func primaryKey() -> String? {
        return Properties.login.rawValue
    }
    
    
}
