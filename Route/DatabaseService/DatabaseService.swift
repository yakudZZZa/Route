//
//  DatabaseService.swift
//  Route
//
//  Created by Евгений Иванов on 09/08/2019.
//  Copyright © 2019 Евгений Иванов. All rights reserved.
//

import Foundation
import RealmSwift


class DatabaseService {
    
    static func deleteOldDataByType <Element: Object> (type: Element.Type) {
        do {
            let config = Realm.Configuration.defaultConfiguration
            let realm = try Realm(configuration: config)
            let oldCoordinates = realm.objects(type)
            realm.beginWrite()
            realm.delete(oldCoordinates)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }

    static func saveNewData <Element: Object> (data: [Element]) {
        do {
            let config = Realm.Configuration.defaultConfiguration
            let realm = try Realm(configuration: config)
            realm.beginWrite()
            realm.add(data, update: .modified)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    static func createNewObject <Element: Object> (type: Element.Type, object: Element) {
        do {
            let config = Realm.Configuration.defaultConfiguration
            let realm = try Realm(configuration: config)
            realm.beginWrite()
            realm.create(type, value: object, update: .modified)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    static func updateCoordinates (login: String, coordinates: [Coordinate]) {
        do {
            let config = Realm.Configuration.defaultConfiguration
            let realm = try Realm(configuration: config)
            guard let user = DatabaseService.getObject(type: User.self, login: login) else { return }
            realm.beginWrite()
            let coordinatesToDelete = Array(user.coordinates)
            user.coordinates.removeAll()
            realm.delete(coordinatesToDelete)
            user.coordinates.append(objectsIn: coordinates)
            realm.create(User.self, value: user, update: .modified)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    static func getObject <Element: Object>(type: Element.Type, login: String) -> Element? {
        let config = Realm.Configuration.defaultConfiguration
        let realm = try? Realm(configuration: config)
        return realm?.object(ofType: type, forPrimaryKey: login)
    }
    
    

    static func getDataByType <Element: Object>(type: Element.Type) -> Results<Element>? {
        let config = Realm.Configuration.defaultConfiguration
        let realm = try? Realm(configuration: config)
        return realm?.objects(type)
    }
    
    
}
