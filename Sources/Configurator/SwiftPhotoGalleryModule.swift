//
//  SwiftPhotoGalleryModule.swift
//  SwiftPhotoGallery
//
//  Created by Likemind on 27/08/21.
//

import Foundation

public class SwiftPhotoGalleryInputModel {
    var selectionLimit: Int = 3
    var selectionMediaColor: UIColor = UIColor.blue
    var selectionMediaBorderWidth: CGFloat = 4.0
}

public typealias GalleryModuleCompletionBlock = ([GalleryModel]?, Bool) -> Void

public class SwiftPhotoGalleryModule: NSObject {

    public override init() {
        super.init()
    }
    
    public var navigationController: UINavigationController?
    public var viewController: SwiftPhotoGalleryViewController?

    internal let dataProvider = PhotoGalleryDataProvider()

    public func build(inputModel: SwiftPhotoGalleryInputModel? = nil, withCompletionBlock completion: GalleryModuleCompletionBlock? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: type(of: self)))
        guard let navController = storyboard.instantiateInitialViewController() as? UINavigationController,
              let view = storyboard.instantiateViewController(withIdentifier: "SwiftPhotoGalleryViewController") as? SwiftPhotoGalleryViewController else {return}
        navigationController = navController
        viewController = view
        navigationController?.viewControllers = [view]
        let presenter = PhotoGalleryPresenter(view: view, withCompletionBlock: completion)

        view.presenter = presenter
        dataProvider.dataProviderDelegate = presenter
        view.dataSource = dataProvider
        presenter.dataProvider = dataProvider
    }

}
