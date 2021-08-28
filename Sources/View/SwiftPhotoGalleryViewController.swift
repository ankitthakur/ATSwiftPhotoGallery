//
//  SwiftPhotoGalleryViewController.swift
//  SwiftPhotoGallery
//
//  Created by Ankit Thakur on 27/08/21.
//

import UIKit
import Photos

public class SwiftPhotoGalleryViewController: UIViewController {

    var presenter: PhotoGalleryViewToPresenterProtocol!
    var dataSource: PhotoGalleryDataSource!
    
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        presenter.viewDidLoad()
    }
    
}

extension SwiftPhotoGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.galleryAssets?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.cellIdentifer, for: indexPath) as? ImageCollectionViewCell,
              let asset = dataSource.galleryAssets?[indexPath.row] else {return UICollectionViewCell()}
        cell.loadAsset(asset: asset, isSelected: dataSource.isAssetSelected(asset), with: dataSource.galleryThemeModel)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/4 - 1
        return CGSize(width: width, height: width)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let asset = dataSource.galleryAssets?[indexPath.row] else {return}
        presenter.didSelectAsset(asset: asset)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: { [weak self] in
            guard let weakSelf = self,
                  let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell,
                  let asset = weakSelf.dataSource.galleryAssets?[indexPath.row] else {return}
            cell.loadAsset(asset: asset, isSelected: weakSelf.dataSource.isAssetSelected(asset), with: weakSelf.dataSource.galleryThemeModel)
        })
    }
}

extension SwiftPhotoGalleryViewController: PhotoGalleryPresenterToViewProtocol {
    
    func initializeView() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
    }
    
    func updateFetchedAssetsUI() {
        DispatchQueue.main.async {[weak self] in
            guard let weakSelf = self else {return}
            weakSelf.galleryCollectionView.reloadData()
            weakSelf.isEditing = true
        }
    }
    
    func showPermissionsPopup() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil,
                                          message: "To access gallery, please allow PhotoLibrary in Settings",
                                          preferredStyle: .alert)
            let notNowAction = UIAlertAction(title: "Not Now",
                                             style: .cancel,
                                             handler: nil)
            alert.addAction(notNowAction)
            let settingsAction = UIAlertAction(title: "Settings",
                                         style: .default){ void in
                                            guard let url = URL(string: UIApplication.openSettingsURLString),
                                                UIApplication.shared.canOpenURL(url) else {
                                                    return
                                            }
                                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            alert.addAction(settingsAction)
            alert.preferredAction = settingsAction
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showManagePermissions() {
        DispatchQueue.main.async {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelTapped))
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneTapped))
            let manageSettings = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(self.settingsTapped))
            self.navigationItem.rightBarButtonItems = [done, manageSettings]
        }
    }
    
    
    @objc func cancelTapped() {
        presenter.cancelTapped()
    }
    
    @objc func doneTapped() {
        presenter.doneTapped()
    }
    
    @objc func settingsTapped() {
        dataSource.reRequestPermissions()
    }
}
