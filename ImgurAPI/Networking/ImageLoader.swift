//
//  ImageLoader.swift
//  ImgurAPI
//
//  Created by Pei Huang on 2022/8/7.
//

import UIKit

class ImageLoader {
    private let imageCache = NSCache<NSURL, UIImage>()
    private var runningRequest = [UUID: URLSessionDataTask]()
    
    func loadImage(from url: URL, completion: @escaping(Result<UIImage, Error>) -> Void) -> UUID? {
        if let image = imageCache.object(forKey: url as NSURL) {
            completion(.success(image))
            return nil
        }
        
        let uuid = UUID()
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer { self.runningRequest.removeValue(forKey: uuid) }
            
            if let data = data,
               let image = UIImage(data: data) {
                self.imageCache.setObject(image, forKey: url as NSURL)
                completion(.success(image))
                return
            }
            
            guard let error = error else { return }
            guard (error as NSError).code == NSURLErrorCancelled else {
                completion(.failure(error))
                return
            }
        }
        
        task.resume()
        
        runningRequest[uuid] = task
        return uuid
    }
    
    func cancel(_ uuid: UUID) {
        runningRequest[uuid]?.cancel()
        runningRequest.removeValue(forKey: uuid)
    }
}
