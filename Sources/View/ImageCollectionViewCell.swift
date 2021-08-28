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
    @IBOutlet weak var selectionImageView: UIImageView!
    @IBOutlet weak var icloudImageView: UIImageView!
    
    override func prepareForReuse() {
        galleryImageView.layer.cornerRadius = 2
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        selectionImageView.layer.cornerRadius = selectionImageView.bounds.size.width/2
        selectionImageView.layer.borderWidth = 2
        selectionImageView.layer.borderColor = UIColor.white.cgColor
    }
    
    func loadAsset(asset: PHAsset, isSelected selected: Bool, with galleryThemeModel: SwiftPhotoGalleryInputModel) {
        let bundle = Bundle(for: type(of: self))
        selectionImageView.image = selected ? UIImage(named: "checkmark.circle.fill", in: bundle, compatibleWith: nil) : UIImage(named: "checkmark.circle", in: bundle, compatibleWith: nil)
        selectionImageView.layer.borderColor = selected ? UIColor.white.cgColor : UIColor.clear.cgColor
        selectionImageView.backgroundColor = selected ? UIColor.white : UIColor.clear
        
        selectionImageView.tintColor = selected ? galleryThemeModel.selectionMediaColor : UIColor.lightGray
        let resourceArray = PHAssetResource.assetResources(for: asset)
        let isLocallyAvailable = resourceArray.first?.value(forKey: "locallyAvailable") as? Bool ?? false // If this returns NO, then the asset is in iCloud and not saved locally yet
        icloudImageView.isHidden = isLocallyAvailable
        icloudImageView.tintColor = .lightGray
        
        if isLocallyAvailable == false {
            selectionImageView.isHidden = true
        }
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil) {[weak self] (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
            guard let weakSelf = self else {return}
            weakSelf.galleryImageView.image = image
        }
    }
    
}
