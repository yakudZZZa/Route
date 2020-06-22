//
//  Coordinate.swift
//  Route
//
//  Created by Евгений Иванов on 08/08/2019.
//  Copyright © 2019 Евгений Иванов. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

@objcMembers
class Coordinate: Object {
    
    dynamic var latitude: Double = 0
    dynamic var longitude: Double = 0
    let user = LinkingObjects(fromType: User.self, property: "coordinates")
    
    convenience init(coordinates: CLLocationCoordinate2D) {
        self.init()
        self.latitude = coordinates.latitude
        self.longitude = coordinates.longitude
    }
}
