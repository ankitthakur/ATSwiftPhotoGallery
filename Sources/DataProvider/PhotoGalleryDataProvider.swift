//
//  PhotoGalleryDataProvider.swift
//  SwiftPhotoGallery
//
//  Created by Ankit Thakur on 27/08/21.
//

import Foundation
import Photos

protocol PhotoGalleryDataProviderDelegate {
    func showPermissionsPopup()
    func showManagePermissions()
    func providerDidFetchedAssets()
}

protocol PhotoGalleryDataSource {
    var galleryAssets: PHFetchResult<PHAsset>? {get}
    var selectedAssets: [PHAsset] {get}
    var galleryThemeModel: SwiftPhotoGalleryInputModel {get}
    func isAssetSelected(_ asset: PHAsset) -> Bool
    func reRequestPermissions()
}

class PhotoGalleryDataProvider {
    
    var dataProviderDelegate: PhotoGalleryDataProviderDelegate?
    
    internal var assets: PHFetchResult<PHAsset>?
    var _selectedAssets: [PHAsset] = []
    var galleryInputModel: SwiftPhotoGalleryInputModel = SwiftPhotoGalleryInputModel()
    
    var photosAndVideosFetchOption: PHFetchOptions = {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        return fetchOptions
    }()
    
    fileprivate func requestAuthorization() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                guard newStatus == PHAuthorizationStatus.authorized else {
                    self.dataProviderDelegate?.showPermissionsPopup()
                    return
                }
                self.reloadAssets()
            }
        } else {
            // Fallback on earlier versions
            PHPhotoLibrary.requestAuthorization { (newStatus) in
                guard newStatus == PHAuthorizationStatus.authorized else {
                    self.dataProviderDelegate?.showPermissionsPopup()
                    return
                }
                self.reloadAssets()
            }
        }
        
    }
    
    
    func load() {
        
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            if status == .limited {
                // limited
                print("limited")
                self.dataProviderDelegate?.showManagePermissions()
                reloadAssets()
            } else if status == .authorized {
                print("authorized")
                reloadAssets()
            } else {
                print("none")
                requestAuthorization()
            }
        } else {
            // Fallback on earlier versions
            if PHPhotoLibrary.authorizationStatus() == .authorized {
                reloadAssets()
            } else {
                requestAuthorization()
            }
        }
        
        
        
    }
    
    func updateSelectedAsset(_ asset: PHAsset) {
        if let selectedIndex = _selectedAssets.firstIndex(where: {$0.localIdentifier == asset.localIdentifier}) {
            _selectedAssets.remove(at: selectedIndex)
        } else if _selectedAssets.count < galleryInputModel.selectionLimit {
            _selectedAssets.append(asset)
        }
//        dataProviderDelegate?.providerDidFetchedAssets()
    }
    
    
    func reloadAssets() {
        assets = nil
        assets = PHAsset.fetchAssets(with: photosAndVideosFetchOption)
        dataProviderDelegate?.providerDidFetchedAssets()
    }
    
}

extension PhotoGalleryDataProvider: PhotoGalleryDataSource {
    var galleryAssets: PHFetchResult<PHAsset>? {
        return assets
    }
    
    var selectedAssets: [PHAsset] {
        return _selectedAssets
    }
    
    var galleryThemeModel: SwiftPhotoGalleryInputModel {
        return galleryInputModel
    }
    
    func isAssetSelected(_ asset: PHAsset) -> Bool {
        guard _selectedAssets.firstIndex(where: {$0.localIdentifier == asset.localIdentifier}) != nil else {return false}
        return true
    }
    
    func reRequestPermissions() {
        self.requestAuthorization()
    }
}
