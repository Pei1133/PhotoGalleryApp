//
//  PhotoViewModel.swift
//  ImgurAPI
//
//  Created by Pei Huang on 2022/8/6.
//

import UIKit
import Combine

protocol PhotoViewModelDelegate: AnyObject {
    func photosSearched()
}

class PhotoViewModel {
    private var photos = [Gallery]()
    private var currentPage = 0
    private var cancellables: Set<AnyCancellable> = []
    weak var delegate: PhotoViewModelDelegate?
        
    lazy var imgurAPI: ImgurAPI = {
        return ImgurAPI()
    }()
    
    init() {
        searchGallery()
    }
    
    var photoCount: Int {
        return photos.count
    }
    
    var photoSize: CGSize {
        let fullScreenSize = UIScreen.main.bounds.size
        let lengh: CGFloat = floor(CGFloat(fullScreenSize.width)/3) - 1
        let itemSize = CGSize(width: lengh, height: lengh)
        return itemSize
    }
    
    var minInteritemSpacing: CGFloat {
        return 1
    }
    
    var minLineSpacing: CGFloat {
        var spacing: CGFloat = CGFloat.zero
        return spacing
    }
    func getPhoto(at index: Int) -> Gallery? {
        guard photos.count > index else { return nil }
        return photos[index]
    }
    
    func searchGallery() {
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
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { (data, response) -> UIImage? in return UIImage(data: data) }
            .catch { error in return Just(nil) }
            .print("Image loading \(url):")
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
