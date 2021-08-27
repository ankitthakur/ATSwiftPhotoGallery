//
//  SwiftPhotoGalleryEventManager.swift
//  SwiftPhotoGallery
//
//  Created by Likemind on 28/08/21.
//

import Foundation

protocol SwiftPhotoGalleryObserver: AnyObject {
    func didReceiveGallery(_ gallery: [GalleryModel]?, isCancelled: Bool)
}

extension SwiftPhotoGalleryObserver {
    func didReceiveGallery(_ gallery: [GalleryModel]?, isCancelled: Bool){}
}


final class SwiftPhotoGalleryEventManager {
    static let shared = SwiftPhotoGalleryEventManager()
    var observers = NSMutableSet()
    
    func addObserver(_ observer: SwiftPhotoGalleryObserver) {
        self.observers.add(observer)
    }
    
    func removeObserver(_ observer: SwiftPhotoGalleryObserver) {
        self.observers.remove(observer)
    }
    
    func didReceiveGallery(_ gallery: [GalleryModel]?, isCancelled: Bool) {
        self.observers.forEach {
            if let observer = $0 as? SwiftPhotoGalleryObserver {
                observer.didReceiveGallery(gallery, isCancelled: isCancelled)
            }
        }
    }
}
