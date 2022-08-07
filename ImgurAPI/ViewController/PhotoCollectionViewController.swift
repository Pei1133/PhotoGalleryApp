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
            cell.tag = indexPath.row
            if let photo = vm.getPhoto(at: indexPath.row),
               let first = photo.getFirstImageLink(),
               let url = URL(string: first) {
                let token = vm.loadImage(from: url) { image in
                    DispatchQueue.main.async {
                        if cell.tag == indexPath.row {
                            cell.imageView.image = image
                            cell.layoutSubviews()
                        }
                    }
                }
                
                cell.onReuse = {
                    if let token = token {
                        self.vm.cancelLoadImage(token)
                    }
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }

    // MARK: -UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        vm.searchMore(index: indexPath.item)
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
