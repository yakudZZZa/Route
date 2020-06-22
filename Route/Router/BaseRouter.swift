//
//  BaseRouter.swift
//  Route
//
//  Created by Евгений Иванов on 12/08/2019.
//  Copyright © 2019 Евгений Иванов. All rights reserved.
//

import UIKit

class BaseRouter: NSObject {
    
    @IBOutlet weak var controller: UIViewController!
    
    // Метод, принимающий идентификатор сигвея и замыкание, которое будет вызвано
    // при переходе. Метод является дженериком
    func perform <Controller: UIViewController> (
        segue: String,
        performAction: ((Controller) -> Void)? = nil) {
        
        // Оборачиваем замыкание в другое замыкание, принимающее обобщённый
        // контроллер и пытаемся привести его к типу требуемого контроллера
        let performAction = performAction.map { action in
        { (controller: UIViewController) in
            // Выбрасывает исключение в режиме дебага, если тип контроллера неверный
            guard let controller = controller as? Controller else {
                assertionFailure("Ожидался \(Controller.self)")
                return
            }
            action(controller)
            }
        }
        
        controller?.performSegue(withIdentifier: segue, sender: performAction)
    }
    
    func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?) {
        
        guard let action = sender as? ((UIViewController) -> Void) else { return }
        action(segue.destination)
    }
    
}
