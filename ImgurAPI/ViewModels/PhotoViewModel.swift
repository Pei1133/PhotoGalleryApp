//
//  PhotoViewModel.swift
//  ImgurAPI
//
//  Created by Pei Huang on 2022/8/6.
//

import UIKit
import Combine

class PhotoViewModel {
    private var photos = [Gallery]()
    
    lazy var imgurAPI: ImgurAPI = {
        return ImgurAPI()
    }()
    
    init() {
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
}
