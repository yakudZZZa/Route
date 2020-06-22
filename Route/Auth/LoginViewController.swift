//
//  LoginViewController.swift
//  Route
//
//  Created by Евгений Иванов on 12/08/2019.
//  Copyright © 2019 Евгений Иванов. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    @IBOutlet weak var router: LoginRouter!
    @IBOutlet weak var loginView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLoginBindings()
        loginView.autocorrectionType = .no
        passwordView.isSecureTextEntry = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(_ sender: Any) {
        guard
            let login = loginView.text,
            let password = passwordView.text,
            let user = DatabaseService.getObject(type: User.self, login: login),
            login == user.login && password == user.password
            else {
                let alert = UIAlertController(title: "Ошибка", message: "Неверный логин или пароль", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ок", style: .cancel) { (action) in
                    self.passwordView.text?.removeAll()
                }
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
                return
        }
        KeychainWrapper.standard.set(login, forKey: "currentUser")
        KeychainWrapper.standard.set(true, forKey: "isLogin")
        self.router.toMain()
    }
    
    @IBAction func register(_ sender: Any) {
        
        guard
            let login = loginView.text,
            let password = passwordView.text,
            login.count > 0 && password.count > 0
            else {
                let alert = UIAlertController(title: "Ошибка", message: "Логин и пароль не могут быть пустыми", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ок", style: .cancel)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
                return
        }
        let user = User(login: login, password: password)
        DatabaseService.createNewObject(type: User.self, object: user)
        let alert = UIAlertController(title: "Регистрация", message: "Учетная запись \(login) зарегистрирована.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .default) { (action) in
            self.passwordView.text?.removeAll()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router.prepare(for: segue, sender: sender)
    }
    
    func configureLoginBindings() {
        Observable
            // Объединяем два обсервера в один
            .combineLatest(
                // Обсервер изменения текста
                loginView.rx.text,
                // Обсервер изменения текста
                passwordView.rx.text
            )
            // Модифицируем значения из двух обсерверов в один
            .map { login, password in
                // Если введены логин и пароль больше 3 символов, будет возвращено “истина”
                return !(login ?? "").isEmpty && (password ?? "").count >= 3
            }
            // Подписываемся на получение событий
            .bind { [weak loginButton] inputFilled in
                // Если событие означает успех, активируем кнопку, иначе деактивируем
                loginButton?.isEnabled = inputFilled
        }
    }
    
}

final class LoginRouter: BaseRouter {
    
    func toMain() {
        perform(segue: "toMain")
    }
    
}

