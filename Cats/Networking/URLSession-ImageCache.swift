//
// Created by Daniela Postigo on 11/23/20.
//

import Foundation
import UIKit
import Combine

let imageCache = NSCache<AnyObject, UIImage>()

extension URLSession {

  public func imageDownloadPublisher(_ url: URL) -> AnyPublisher<UIImage?, URLError> {
    if let image = imageCache.object(forKey: url as NSURL) {
      return Just(image)
        .setFailureType(to: URLError.self)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    return self.downloadTaskPublisher(for: url)
               .map { UIImage(contentsOfFile: $0.url.path) }
               .receive(on: DispatchQueue.main)
               .handleEvents(receiveOutput: { image in
                 guard let image = image else { return }
                 imageCache.setObject(image, forKey: url as NSURL)
               })
               .eraseToAnyPublisher()
  }
}