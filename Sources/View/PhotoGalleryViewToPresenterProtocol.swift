//
//  PhotoGalleryViewToPresenterProtocol.swift
//  SwiftPhotoGallery
//
//  Created by Likemind on 27/08/21.
//

import Foundation
import Photos

protocol PhotoGalleryViewToPresenterProtocol {
    func viewDidLoad()
    func didSelectAsset(asset: PHAsset)
    func cancelTapped()
    func doneTapped()
}
