//
//  SwiftPhotoGalleryModule.swift
//  SwiftPhotoGallery
//
//  Created by Likemind on 27/08/21.
//

import Foundation

public class SwiftPhotoGalleryInputModel {
    public var selectionLimit: Int = 10
    public var selectionMediaColor: UIColor = UIColor.systemBlue
    public init() {
        selectionLimit = 30
        selectionMediaColor = UIColor.systemBlue
    }
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
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: SwiftPhotoGalleryModule.self))
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
