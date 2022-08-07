//
//  ViewController.swift
//  ImgurAPI
//
//  Created by Steven Chen on 2022/4/28.
//

import UIKit
import Combine

class ViewController: UIViewController {

    lazy var imgurAPI: ImgurAPI = {
        return ImgurAPI()
    }()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        return imageView
    }()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imgurAPI.searchGallery(query: "cats", page: 1)
            .receive(on: RunLoop.main)
            .sink { error in
                print("completed")
            } receiveValue: { [weak self] galleries in
                guard let self = self else { return }
                guard let first = galleries?.first?.getFirstImageLink(),
                        let url = URL(string: first) else {
                    return
                }
                let totalImages = galleries?.reduce(0, { $0 + ($1.imagesCount ?? 0) })
                print("galleries: \(String(describing: galleries?.count)), total image count:\(String(describing: totalImages))")
                self.loadImage(from: url).assign(to: \.image, on: self.imageView).store(in: &self.cancellables)
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
