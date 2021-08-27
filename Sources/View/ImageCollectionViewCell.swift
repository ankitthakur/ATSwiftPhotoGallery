//
//  ImageCollectionViewCell.swift
//  SwiftPhotoGallery
//
//  Created by Likemind on 27/08/21.
//

import UIKit
import Photos

class ImageCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifer = "ImageCollectionViewCell"
    @IBOutlet weak var galleryImageView: UIImageView!
    
    override func prepareForReuse() {
        galleryImageView.layer.cornerRadius = 2
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    func loadAsset(asset: PHAsset, isSelected selected: Bool, with galleryThemeModel: SwiftPhotoGalleryInputModel) {
        self.layer.borderColor = selected ? galleryThemeModel.selectionMediaColor.cgColor : UIColor.black.cgColor
        self.layer.borderWidth = selected ? galleryThemeModel.selectionMediaBorderWidth : 1
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil) {[weak self] (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
            guard let weakSelf = self else {return}
            weakSelf.galleryImageView.image = image
        }
    }
    
}
