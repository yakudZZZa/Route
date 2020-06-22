//
//  AppDelegate.swift
//  Route
//
//  Created by Евгений Иванов on 01/08/2019.
//  Copyright © 2019 Евгений Иванов. All rights reserved.
//

import UIKit
import GoogleMaps
import RealmSwift
import LocalAuthentication
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let blurEffectTag = 221122
    let timeHalfHour: Double = 10

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey("AIzaSyCdlVgVOFc8i7Li6sN5qdOMjejbwNk9ewg")
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        addBlurEffect()
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("background")
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.provisional, .alert, .badge, .sound]) { (result, error) in
            guard result else {
                print("Разрешение не получено")
                return
            }
            
            self.sendNotificatioRequest(
                content: self.makeNotificationContent(),
                trigger: self.makeIntervalNotificatioTrigger()
            )
        }

        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("WillEnterForeground")
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        removeBlurEffect()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = window!.frame
        blurEffectView.tag = blurEffectTag
        self.window?.addSubview(blurEffectView)
    }

    func removeBlurEffect() {
        UIView.animate(withDuration: 0.5, animations: {
            self.window?.viewWithTag(self.blurEffectTag)?.alpha = 0
        }) { (Bool) in
            self.window?.viewWithTag(self.blurEffectTag)?.removeFromSuperview()
        }
    }
    
    func sendNotificatioRequest(
        content: UNNotificationContent,
        trigger: UNNotificationTrigger) {
        
        // Создаём запрос на показ уведомления
        let request = UNNotificationRequest(
            identifier: "alaram",
            content: content,
            trigger: trigger
        )
        
        let center = UNUserNotificationCenter.current()
        // Добавляем запрос в центр уведомлений
        center.add(request) { error in
            // Если не получилось добавить запрос,
            // показываем ошибку, которая при этом возникла
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func makeNotificationContent() -> UNNotificationContent {
        // Внешний вид уведомления
        let content = UNMutableNotificationContent()
        // Заголовок
        content.title = "Мы по вам соскучились!"
        // Подзаголовок
        content.subtitle = "Программа Route Вас потеряла :("
        // Основное сообщение
        content.body = "Вы можете уточнить своё местоположение, если зайдете в приложение"
        // Цифра в бейдже на иконке
        content.badge = 1
        content.sound = UNNotificationSound(named: UNNotificationSoundName("default"))
        return content
    }

    func makeIntervalNotificatioTrigger() -> UNNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(
            // Количество секунд до показа уведомления
            timeInterval: timeHalfHour,
            // Надо ли повторять
            repeats: false
        )
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }
    

}

