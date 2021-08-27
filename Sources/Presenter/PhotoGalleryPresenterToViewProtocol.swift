//
//  PhotoGalleryPresenterToViewProtocol.swift
//  SwiftPhotoGallery
//
//  Created by Ankit Thakur on 27/08/21.
//

import Foundation

protocol PhotoGalleryPresenterToViewProtocol: AnyObject {
    
    func updateFetchedAssetsUI()
    func initializeView()
}
