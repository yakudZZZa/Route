//
//  MainViewController.swift
//  Route
//
//  Created by Евгений Иванов on 12/08/2019.
//  Copyright © 2019 Евгений Иванов. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class MainViewController: UIViewController {

    @IBOutlet weak var router: MainRouter!
    
    @IBAction func showMap(_ sender: Any) {
        router.toMap()
    }
    
    @IBAction func logout(_ sender: Any) {
        KeychainWrapper.standard.set(false, forKey: "isLogin")
        KeychainWrapper.standard.set("", forKey: "currentUser")
        router.toLaunch()
    }
    
    @IBAction func takePicture(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router.prepare(for: segue, sender: sender)
    }
    
}

extension MainViewController: UINavigationControllerDelegate {
    
}

extension MainViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let image = self?.extractImage(from: info) else { return }
            self?.router.toSelfie(image: image)
        }
    }
    
    // Метод, извлекающий изображение
    private func extractImage(from info: [UIImagePickerController.InfoKey : Any]) -> UIImage? {
        // Пытаемся извлечь отредактированное изображение
        if let image = info[.editedImage] as? UIImage {
            return image
            // Пытаемся извлечь оригинальное
        } else if let image = info[.originalImage] as? UIImage {
            return image
        } else {
            // Если изображение не получено, возвращаем nil
            return nil
        }
    }
    
}

final class MainRouter: BaseRouter {
    func toMap() {
        perform(segue: "toMap")
    }
    
    func toLaunch() {
        perform(segue: "toLaunch")
    }
    
    func toSelfie(image: UIImage) {
        perform(segue: "toSelfie") { (controller: SelfieViewController) in
            controller.image = image
        }
    }
}
