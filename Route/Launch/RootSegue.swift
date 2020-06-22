//
//  RootSegue.swift
//  Route
//
//  Created by Евгений Иванов on 12/08/2019.
//  Copyright © 2019 Евгений Иванов. All rights reserved.
//

import UIKit

class RootSegue: UIStoryboardSegue {

    override func perform() {
        UIApplication.shared.keyWindow?.rootViewController = destination
    }
    
}
