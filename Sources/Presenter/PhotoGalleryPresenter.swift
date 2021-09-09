//
//  PhotoGalleryPresenter.swift
//  SwiftPhotoGallery
//
//  Created by Ankit Thakur on 27/08/21.
//

import Foundation
import Photos

typealias ExportedURLCallback = (URL?) -> Void
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
        print("processing number of assets - \(dataProvider.selectedAssets.count)")
        for asset in dataProvider.selectedAssets {
            let model = GalleryModel()
            let retinaMultiplier = UIScreen.main.scale
            
            model.duration = asset.duration
            mainGroup.enter()
            let group = DispatchGroup()
            let uuid = NSUUID().uuidString
            group.enter()
            
            let highQualityOptions = PHImageRequestOptions()
            highQualityOptions.deliveryMode = .highQualityFormat
            // this will be used for both video and image
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 1024, height: 1024), contentMode: .aspectFit, options: highQualityOptions) {[weak self] (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
                guard nil != self, let receivedImage = image else {
                    group.leave()
                    return
                }
                
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
            
            
            let retinaSquare = CGSize(width:256 * retinaMultiplier, height: 256 * retinaMultiplier);

            
            PHImageManager.default().requestImage(for: asset, targetSize: retinaSquare, contentMode: .aspectFit, options: highQualityOptions) {[weak self] (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
                guard nil != self, let receivedImage = image else {
                    group.leave()
                    return
                }
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
                    guard let weakSelf = self,
                          let videoAsset = videoasset as? AVURLAsset,
                          let _ = info else {
                        group.leave()
                        return
                    }
                    
                    model.duration = videoAsset.duration.seconds
                    let lastPathComponent = videoAsset.url.lastPathComponent
                    model.mediaName = lastPathComponent
                    let modelPath = temporaryDirectoryURL.appendingPathComponent("\(uuid)_\(lastPathComponent)")
                    
                    weakSelf.copyVideoToAppDir(videoAsset: videoAsset, destinationPath: modelPath) { url in
                        if url != nil {
                            do {
                                let attributes = try FileManager.default.attributesOfItem(atPath: modelPath.path)
                                model.originalVideoFilePath = modelPath
                                model.mediaSizeInBytes = attributes[FileAttributeKey.size] as? UInt64 ?? UInt64(0)
                                group.leave()
                            }
                            catch let error {
                                print("\(#line) \(error)")
                                let attributes = try? FileManager.default.attributesOfItem(atPath: videoAsset.url.absoluteString)
                                model.originalVideoFilePath = videoAsset.url
                                model.mediaSizeInBytes = attributes?[FileAttributeKey.size] as? UInt64 ?? UInt64(0)
                                group.leave()
                            }
                        } else {
                            let attributes = try? FileManager.default.attributesOfItem(atPath: videoAsset.url.absoluteString)
                            model.originalVideoFilePath = videoAsset.url
                            model.mediaSizeInBytes = attributes?[FileAttributeKey.size] as? UInt64 ?? UInt64(0)
                            group.leave()
                        }
                    }
                }
            }
            
            group.notify(queue: .main, execute: {
                model.assetType = asset.mediaType
                models.append(model)
                mainGroup.leave()
            })
        }
        
        mainGroup.notify(queue: .main, execute: {[weak self] in
            
            print("processing assets completed")
            guard let weakSelf = self,
                  let viewController = weakSelf.view as? UIViewController,
                  let navigationController = viewController.navigationController else {return}
            weakSelf.completion?(models, false)
            SwiftPhotoGalleryEventManager.shared.didReceiveGallery(models, isCancelled: false)
            navigationController.dismiss(animated: true, completion: nil)
        })
    }
    
    func copyVideoToAppDir(videoAsset: AVURLAsset, destinationPath: URL, handler: ExportedURLCallback?) {
        
        do {
            var _:  CMTime!
            
            try deleteIfExists(path: destinationPath)
            
            let startTime = CMTime.zero
            let assetDurationSeconds = CMTimeGetSeconds(videoAsset.duration)
            var range: CMTimeRange!
            let stopTime = CMTimeMakeWithSeconds(assetDurationSeconds, preferredTimescale: 1)
            range = CMTimeRangeFromTimeToTime(start: startTime, end: stopTime)
            guard let exporter :AVAssetExportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality) else {
                handler?(nil)
                return
            }
            exporter.outputURL = destinationPath
            exporter.outputFileType = AVFileType.mp4
            exporter.timeRange = range
            exporter.exportAsynchronously { () -> Void in
                switch exporter.status {
                case  .failed:
                    print("failed import video: \(String(describing: exporter.error))")
                    handler?(nil)
                case .cancelled:
                    print("cancelled import video: \(String(describing: exporter.error))")
                    handler?(nil)
                default:
                    print("completed import video")
                    print(destinationPath)
                    handler?(destinationPath)
                    
                }
            }
            
        } catch let error {
            print(error)
        }
    }
    
    func deleteIfExists(path: URL) throws {
        if (FileManager.default.fileExists(atPath: path.path)) {
            try FileManager.default.removeItem(atPath: path.path)
        }
    }
}

