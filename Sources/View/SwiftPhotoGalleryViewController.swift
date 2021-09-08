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
    lazy var indicatorView = PhotoGalleryIndicatorView()
    
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
        let resourceArray = PHAssetResource.assetResources(for: asset)
        let isLocallyAvailable = resourceArray.first?.value(forKey: "locallyAvailable") as? Bool ?? false // If this returns NO, then the asset is in iCloud and not saved locally yet
        
        if isLocallyAvailable == false {
            let alert = UIAlertController(title: nil,
                                          message: "This media is not downloaded from cloud, so cann't be selected.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                             style: .cancel,
                                             handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
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
        indicatorView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicatorView)
        
        indicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        indicatorView.widthAnchor.constraint(equalTo: indicatorView.heightAnchor, constant: 0).isActive = true
        indicatorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
//        indicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive  = true
        indicatorView.strokeColor = UIColor.systemBlue
        indicatorView.lineWidth = 4.0
        indicatorView.numSegments = 12
        indicatorView.startAnimating()
        self.view.bringSubviewToFront(indicatorView)
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(300)) {[weak self] in
            guard let weakSelf = self else {return}
            weakSelf.presenter.doneTapped()
        }
    }
    
    @objc func settingsTapped() {
        dataSource.reRequestPermissions()
    }
}
