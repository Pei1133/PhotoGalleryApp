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

    lazy var sizeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: CollectionViewStyle.allStyleName)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(changeCollectionViewStyle), for: .valueChanged)
        segmentedControl.selectedSegmentTintColor = UIColor(red: 70, green: 70, blue: 70, alpha: 0.4)
        segmentedControl.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        return segmentedControl
    }()
    
    @objc func changeCollectionViewStyle() {
        vm.changeCollectionViewStyle(index: sizeSegmentedControl.selectedSegmentIndex)
         
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
        }, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        vm.delegate = self
    }

    func setupView() {
        setupCollectionView()
        self.view.addSubview(sizeSegmentedControl)
        setupConstraints()
    }
    
    func setupCollectionView() {
        self.collectionView!.backgroundColor = UIColor.black
        self.collectionView!.register(GridCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    func setupConstraints() {
        NSLayoutConstraint.activate([
            sizeSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            sizeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            sizeSegmentedControl.heightAnchor.constraint(equalToConstant: 30),
            sizeSegmentedControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])
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
