//
//  PhotoCollectionViewController.swift
//  ImgurAPI
//
//  Created by Pei Huang on 2022/8/7.
//

import UIKit
import Combine

private let reuseIdentifier = "Cell"

class PhotoCollectionViewController: UICollectionViewController {

    let vm = PhotoViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        vm.delegate = self
    }

    func setupCollectionView() {
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.backgroundColor = UIColor.black
    }

    // MARK: -UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.photoCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? GridCell {
            if let photo = vm.getPhoto(at: indexPath.row),
               let first = photo.getFirstImageLink(),
               let url = URL(string: first) {
                vm.loadImage(from: url)
                    .assign(to: \.image, on: cell.imageView)
                    .store(in: &self.cancellables)
            }
            return cell
        }
        return UICollectionViewCell()
    }
    }
}

// MARK: -UICollectionViewDelegateFlowLayout
extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        vm.photoSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        vm.minLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        vm.minInteritemSpacing
    }

}

extension PhotoCollectionViewController: PhotoViewModelDelegate {
    func photosSearched() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}
