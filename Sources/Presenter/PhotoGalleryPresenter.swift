//
//  PhotoGalleryPresenter.swift
//  SwiftPhotoGallery
//
//  Created by Ankit Thakur on 27/08/21.
//

import Foundation
import Photos

class PhotoGalleryPresenter {
    
    weak var view: PhotoGalleryPresenterToViewProtocol!
    var dataProvider: PhotoGalleryDataProvider!
    var completion: GalleryModuleCompletionBlock?
    init(view: PhotoGalleryPresenterToViewProtocol, withCompletionBlock completion: GalleryModuleCompletionBlock?) {
        self.view = view
        self.completion = completion
    }
    
}

extension PhotoGalleryPresenter: PhotoGalleryDataProviderDelegate {
    func providerDidFetchedAssets() {
        view?.updateFetchedAssetsUI()
    }
    
    func showPermissionsPopup() {
        view?.showPermissionsPopup()
    }
}

extension PhotoGalleryPresenter: PhotoGalleryViewToPresenterProtocol {
    func viewDidLoad() {
        dataProvider.load()
        view?.initializeView()
    }
    
    func didSelectAsset(asset: PHAsset) {
        dataProvider.updateSelectedAsset(asset)
    }
    
    
    func cancelTapped() {
        guard let viewController = self.view as? UIViewController,
              let navigationController = viewController.navigationController else {return}
        dataProvider._selectedAssets.removeAll()
        self.completion?(nil, true)
        SwiftPhotoGalleryEventManager.shared.didReceiveGallery(nil, isCancelled: true)
        navigationController.dismiss(animated: true, completion: nil)
    }
    
    func doneTapped() {
        var models: [GalleryModel] = []
        
        let mainGroup = DispatchGroup()
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        
        for asset in dataProvider.selectedAssets {
            let model = GalleryModel()
            model.duration = asset.duration
            mainGroup.enter()
            let group = DispatchGroup()
            group.enter()
            group.enter()
            
            PHImageManager.default().requestImage(for: asset, targetSize: UIScreen.main.bounds.size, contentMode: .aspectFit, options: nil) {[weak self] (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
                guard nil != self, let receivedImage = image, let metaData = info,
                      let PHImageResultIsDegradedKey = metaData["PHImageResultIsDegradedKey"] as? Int else {
                    group.leave()
                    return
                }
                if PHImageResultIsDegradedKey == 0 {
                    model.originalImage = receivedImage
                } else if PHImageResultIsDegradedKey == 1 {
                    model.thumbnailImage = receivedImage
                }
                var modelPath = temporaryDirectoryURL.appendingPathComponent("\(asset.localIdentifier).png")
                if PHImageResultIsDegradedKey == 1 {
                    modelPath = temporaryDirectoryURL.appendingPathComponent("\(asset.localIdentifier)_thumb.png")
                }
                FileManager.default.createFile(atPath: modelPath.absoluteString, contents: receivedImage.pngData(), attributes: nil)
//                    try receivedImage.pngData()?.write(to: modelPath)
                if PHImageResultIsDegradedKey == 0 {
                    model.originalImageFilePath = modelPath
                } else if PHImageResultIsDegradedKey == 1 {
                    model.thumbnailImageFilePath = modelPath
                }
                group.leave()
            }
            group.notify(queue: .main, execute: {
                model.assetType = asset.mediaType
                models.append(model)
                mainGroup.leave()
            })
        }
        
        mainGroup.notify(queue: .main, execute: {[weak self] in
            guard let weakSelf = self,
                  let viewController = weakSelf.view as? UIViewController,
                  let navigationController = viewController.navigationController else {return}
            weakSelf.completion?(models, false)
            SwiftPhotoGalleryEventManager.shared.didReceiveGallery(models, isCancelled: false)
            navigationController.dismiss(animated: true, completion: nil)
        })

    }
}

