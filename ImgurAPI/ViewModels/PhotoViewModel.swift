//
//  PhotoViewModel.swift
//  ImgurAPI
//
//  Created by Pei Huang on 2022/8/6.
//

import UIKit
import Combine

enum CollectionViewStyle: String, CaseIterable {
    case grid
    case list
    
    static let allStyleName: [String] = CollectionViewStyle.allCases.map { $0.rawValue }
}

protocol PhotoViewModelDelegate: AnyObject {
    func photosSearched()
}

class PhotoViewModel {
    private var photos = [Gallery]()
    private var currentPage = 0
    private let maxPage = 5
    private(set) var style: CollectionViewStyle = .grid
    private var cancellables: Set<AnyCancellable> = []
    weak var delegate: PhotoViewModelDelegate?
        
    lazy var imgurAPI: ImgurAPI = {
        return ImgurAPI()
    }()
    
    lazy var imageLoader: ImageLoader = {
        return ImageLoader()
    }()
    
    init() {
        searchGallery()
    }
    
    var photoCount: Int {
        return photos.count
    }
    
    var photoSize: CGSize {
        var itemSize: CGSize = CGSize.zero
        let fullScreenSize = UIScreen.main.bounds.size
        switch style {
        case .list:
            let lengh: CGFloat = fullScreenSize.width - (40.0 * 2)
            itemSize = CGSize(width: lengh, height: lengh)
        case .grid:
            let lengh: CGFloat = floor(CGFloat(fullScreenSize.width)/3) - 1
            itemSize = CGSize(width: lengh, height: lengh)
        }
        return itemSize
    }
    
    var minInteritemSpacing: CGFloat {
        return 1
    }
    
    var minLineSpacing: CGFloat {
        var spacing: CGFloat = CGFloat.zero
        switch style {
        case .list:
            spacing = 40
        case .grid:
            spacing = 1
        }
        return spacing
    }
    
    func changeCollectionViewStyle(index: Int) {
        let styleName = CollectionViewStyle.allStyleName[index]
        style = CollectionViewStyle.init(rawValue: styleName) ?? .grid
    }
    
    func getPhoto(at index: Int) -> Gallery? {
        guard photos.count > index else { return nil }
        return photos[index]
    }
    
    func searchGallery() {
        currentPage += 1
        if currentPage > maxPage {
            return
        }
        
        imgurAPI.searchGallery(query: "cats", page: currentPage)
            .receive(on: RunLoop.main)
            .sink { error in
                print("completed")
            } receiveValue: { [weak self] galleries in
                guard let self = self else { return }
                guard let galleries = galleries else { return }
                
                self.photos.append(contentsOf: galleries)
                self.delegate?.photosSearched()
                
                let totalImages = galleries.reduce(0, { $0 + ($1.imagesCount ?? 0) })
                print("---currentPage: \(self.currentPage)")
                print("galleries: \(String(describing: galleries.count)), total image count:\(String(describing: totalImages))")
            }.store(in: &self.cancellables)
    }
    
    func searchMore(index: Int) {
        if index > (self.photoCount - 2) {
            self.searchGallery()
        }
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) -> UUID? {
        let token = imageLoader.loadImage(from: url) { result in
            switch result {
            case .success(let image):
                completion(image)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
        return token
    }
    
    func cancelLoadImage(_ token: UUID?) {
        if let token = token {
            imageLoader.cancel(token)
        }
    }
}
