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
            guard let mediaModels = models else {return}
            for model in mediaModels {
                print("""
                                        localIdentifier- \(model.localIdentifier)
                                        thumbnailImage- \(model.thumbnailImage)
                                        originalImage- \(model.originalImage)
                                        originalVideoFilePath- \(model.originalVideoFilePath)
                                        originalImageFilePath- \(model.originalImageFilePath)
                                        originalImageSize- \(model.originalImageSize)
                                        thumbnailImageSize- \(model.thumbnailImageSize)
                                        mediaSizeInBytes- \(model.mediaSizeInBytes)
                                        assetType- \(model.assetType)
                                        duration in seconds - \(model.duration)
                    """)
            }
        }
        guard let navigationController = module.navigationController else {return}
        present(navigationController, animated: true, completion: nil)
    }

}

