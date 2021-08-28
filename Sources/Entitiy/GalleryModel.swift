//
//  GalleryModel.swift
//  SwiftPhotoGallery
//
//  Created by Ankit Thakur on 27/08/21.
//

import Foundation
import Photos

public class GalleryModel {
    public var localIdentifier: String = NSUUID().uuidString
    public var thumbnailImage: UIImage?
    public var originalImage: UIImage?
    public var editedImage: UIImage?
    public var originalVideoFilePath: URL?
    public var originalImageFilePath: URL?
    public var thumbnailImageFilePath: URL?
    public var assetType: PHAssetMediaType = .unknown
    public var duration: TimeInterval = 0
}
