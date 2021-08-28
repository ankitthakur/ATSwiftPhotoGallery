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
    func showManagePermissions() {
        view?.showManagePermissions()
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
            let uuid = NSUUID().uuidString
            group.enter()
            
            // this will be used for both video and image
            PHImageManager.default().requestImage(for: asset, targetSize: UIScreen.main.bounds.size, contentMode: .aspectFit, options: nil) {[weak self] (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
                guard model.originalImage == nil else {return}
                guard nil != self, let receivedImage = image,
                      let metaData = info else {
                    group.leave()
                    return
                }
                print("info - \(metaData)")
                model.originalImage = receivedImage
                model.originalImageSize = receivedImage.size
                
                let modelPath = temporaryDirectoryURL.appendingPathComponent("\(uuid).png")
                FileManager.default.createFile(atPath: modelPath.path, contents: receivedImage.pngData() ?? Data())
                model.originalImageFilePath = modelPath
                
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: modelPath.path)
                    model.mediaSizeInBytes = attributes[FileAttributeKey.size] as? UInt64 ?? UInt64(0)
                } catch let error {
                    print("\(#line) \(error)")
                }
                
                group.leave()
            }
            group.enter()
            
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 120, height: 120), contentMode: .aspectFit, options: nil) {[weak self] (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
                guard model.thumbnailImage == nil else {return}
                guard nil != self, let receivedImage = image, let metaData = info else {
                    group.leave()
                    return
                }
                print("info - \(metaData)")
                model.thumbnailImage = receivedImage
                let modelPath = temporaryDirectoryURL.appendingPathComponent("\(uuid)_thumb.png")
                FileManager.default.createFile(atPath: modelPath.path, contents: receivedImage.pngData() ?? Data())
                model.thumbnailImageFilePath = modelPath
                model.thumbnailImageSize = receivedImage.size
                group.leave()
            }
            
            
            if asset.mediaType == .video {
                group.enter()
                PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil) {[weak self] (videoasset, audioMix, info) in
                    guard nil != self, let videoAsset = videoasset as? AVURLAsset,
                          let _ = info else {
                        group.leave()
                        return
                    }
                    
                    model.duration = videoAsset.duration.seconds
                    let lastPathComponent = videoAsset.url.lastPathComponent
                    let modelPath = temporaryDirectoryURL.appendingPathComponent("\(lastPathComponent)")
                    
                    do {
                        try FileManager.default.copyItem(at: videoAsset.url, to: modelPath)
                        let attributes = try FileManager.default.attributesOfItem(atPath: modelPath.absoluteString)
                        model.originalVideoFilePath = modelPath
                        model.mediaSizeInBytes = attributes[FileAttributeKey.size] as? UInt64 ?? UInt64(0)
                    } catch let error {
                        print("\(#line) \(error)")
                        let attributes = try? FileManager.default.attributesOfItem(atPath: videoAsset.url.absoluteString)
                        model.originalVideoFilePath = videoAsset.url
                        model.mediaSizeInBytes = attributes?[FileAttributeKey.size] as? UInt64 ?? UInt64(0)
                    }
                    group.leave()
                }
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

