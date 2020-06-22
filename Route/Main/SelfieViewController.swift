//
//  SelfieViewController.swift
//  Route
//
//  Created by Евгений Иванов on 02/09/2019.
//  Copyright © 2019 Евгений Иванов. All rights reserved.
//

import UIKit

class SelfieViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveSelfieToJPEG(image: image)
        imageView.image = loadSelfieFromDisk()
        
    }

}
