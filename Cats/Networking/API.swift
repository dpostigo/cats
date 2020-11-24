//
//  API.swift
//  Cats
//
//  Created by Daniela Postigo on 11/21/20.
//

import Foundation
import Combine

enum API {
  static let key = "99aa33e5-5c2a-4dd8-80be-600e8c885e45"
  static func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type = T.self, decoder: JSONDecoder = .init()) -> AnyPublisher<T, Error> {
    URLSession.shared
      .dataTaskPublisher(for: endpoint.urlRequest!)
      .map(\.data)
      .decode(type: T.self, decoder: decoder)
      .eraseToAnyPublisher()
  }
}

enum ImageSearchOptions {
  case limit(Int)
  case size(String)
  case order(String)
}
enum Endpoint {
  case imageSearch(limit: Int = 10, page: Int = 0, size: String? = nil, order: String? = nil)

  var path: String {
    switch self {
      case .imageSearch: return "images/search"
    }
  }

  var queryItems: [URLQueryItem]? {
    switch self {
      case let .imageSearch(limit, page, size, order):
        return ([
          "limit": limit,
          "page": page,
          "size": size,
          "order": order
        ] as [String: Any?])
          .compactMapValues { $0 }
          .map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
    }
  }
  var components: URLComponents {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.thecatapi.com"
    components.path = "/v1/" + self.path
    components.queryItems = self.queryItems
    return components
  }

  var urlRequest: URLRequest? {
    guard let url = self.components.url else { return nil }
    return URLRequest(url: url)
  }
}


