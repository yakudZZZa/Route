//
//  UIViewController+Ext.swift
//  Route
//
//  Created by Евгений Иванов on 12/08/2019.
//  Copyright © 2019 Евгений Иванов. All rights reserved.
//

import UIKit

// MARK: - Добавляет возможность сохранения фото на диск и загрузки с диска
public extension UIViewController {
    
    private func getDocsDir() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveSelfieToJPEG(image: UIImage?) {
        
        let fileURL = getDocsDir().appendingPathComponent("selfie.jpeg")
        guard let data = image?.jpegData(compressionQuality: 90) else { return }
        try! data.write(to: fileURL)
        
    }
    
    func loadSelfieFromDisk() -> UIImage? {
        
        let fileURL = getDocsDir().appendingPathComponent("selfie.jpeg")
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        } else {
            return UIImage(named: "user.png")
        }
        
    }
    
}
