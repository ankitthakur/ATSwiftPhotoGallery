//
//  ViewController.swift
//  ATSwiftPhotoGallery
//
//  Created by ankitthakur on 08/28/2021.
//  Copyright (c) 2021 ankitthakur. All rights reserved.
//

import UIKit
import ATSwiftPhotoGallery
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loadSwiftPhotoGallery() {
        let module = SwiftPhotoGalleryModule()
        module.build(inputModel: nil) { models, isCancelled in
            guard let receivedModels = models else {return}
            print(receivedModels.compactMap{$0.thumbnailImageFilePath})
            print(receivedModels.compactMap{$0.originalImageFilePath})
            print(receivedModels.compactMap{$0.originalVideoFilePath})
            print(receivedModels.compactMap{$0.duration})
            print(receivedModels.compactMap{$0.assetType.rawValue})
        }
        guard let navigationController = module.navigationController else {return}
        present(navigationController, animated: true, completion: nil)
    }

}

