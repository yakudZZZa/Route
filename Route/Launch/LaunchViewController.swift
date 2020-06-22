//
//  LaunchViewController.swift
//  Route
//
//  Created by Евгений Иванов on 12/08/2019.
//  Copyright © 2019 Евгений Иванов. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import LocalAuthentication

class LaunchViewController: UIViewController {
    
    var context = LAContext()
    
    @IBOutlet weak var router: LaunchRouter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The biometryType, which affects this app's UI when state changes, is only meaningful
        //  after running canEvaluatePolicy. But make sure not to run this test from inside a
        //  policy evaluation callback (for example, don't put next line in the state's didSet
        //  method, which is triggered as a result of the state change made in the callback),
        //  because that might result in deadlock.
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        if KeychainWrapper.standard.bool(forKey: "isLogin") ?? false {
            testID()
        } else {
            router.toAuth()
        }
    }
    
}

extension LaunchViewController {
    
    func testID() {
        
        if KeychainWrapper.standard.bool(forKey: "isLogin") ?? false {
            
            // Get a fresh context for each login. If you use the same context on multiple attempts
            //  (by commenting out the next line), then a previously successful authentication
            //  causes the next policy evaluation to succeed without testing biometry again.
            //  That's usually not what you want.
            context = LAContext()
            
            context.localizedCancelTitle = "Enter Username/Password"
            
            // First check if we have the needed hardware support.
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                
                let reason = "Log in to your account"
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                    
                    if success {
                        
                        // Move to the main thread because a state update triggers UI changes.
                        DispatchQueue.main.async { [unowned self] in
                            self.router.toMain()
                        }
                        
                    } else {
                        print(error?.localizedDescription ?? "Failed to authenticate")
                        DispatchQueue.main.async { [unowned self] in
                            KeychainWrapper.standard.set(false, forKey: "isLogin")
                            KeychainWrapper.standard.set("", forKey: "currentUser")
                            self.router.toAuth()
                            // Fall back to a asking for username and password.
                            // ...
                        }
                    }
                }
            } else {
                print(error?.localizedDescription ?? "Can't evaluate policy")
                DispatchQueue.main.async { [unowned self] in
                    KeychainWrapper.standard.set(false, forKey: "isLogin")
                    KeychainWrapper.standard.set("", forKey: "currentUser")
                    self.router.toAuth()
                    // Fall back to a asking for username and password.
                    // ...
                }
            }
            
        } else {
            self.router.toAuth()
        }
    }
}

final class LaunchRouter: BaseRouter {
    
    func toMain() {
        perform(segue: "toMain")
    }
    
    func toAuth() {
        perform(segue: "toAuth")
    }
    
    func toLuanch() {
        perform(segue: "toLuanch")
    }
    
}

