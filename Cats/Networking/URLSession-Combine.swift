//
// Created by Daniela Postigo on 11/21/20.
//

import Foundation
import Combine

// Credit: https://theswiftdev.com/how-to-download-files-with-urlsession-using-combine-publishers-and-subscribers/
extension URLSession {
  public func downloadTaskPublisher(for url: URL) -> URLSession.DownloadTaskPublisher {
    self.downloadTaskPublisher(for: .init(url: url))
  }

  public func downloadTaskPublisher(for request: URLRequest) -> URLSession.DownloadTaskPublisher {
    URLSession.DownloadTaskPublisher(request: request, session: self)
  }

  public struct DownloadTaskPublisher: Publisher {
    public typealias Output = (url: URL, response: URLResponse)
    public typealias Failure = URLError

    public let request: URLRequest
    public let session: URLSession

    public init(request: URLRequest, session: URLSession) {
      self.request = request
      self.session = session
    }

    public func receive<S>(subscriber: S) where S: Subscriber,
    DownloadTaskPublisher.Failure == S.Failure,
    DownloadTaskPublisher.Output == S.Input {
      let subscription = DownloadTaskSubscription(subscriber: subscriber, session: self.session, request: self.request)
      subscriber.receive(subscription: subscription)
    }
  }

  final class DownloadTaskSubscription<SubscriberType: Subscriber>: Subscription where
  SubscriberType.Input == (url: URL, response: URLResponse),
  SubscriberType.Failure == URLError {
    private var subscriber: SubscriberType?
    private weak var session: URLSession!
    private var request: URLRequest!
    private var task: URLSessionDownloadTask!

    init(subscriber: SubscriberType, session: URLSession, request: URLRequest) {
      self.subscriber = subscriber
      self.session = session
      self.request = request
    }

    func request(_ demand: Subscribers.Demand) {
      guard demand > 0 else { return }
      self.task = self.session.downloadTask(with: request) { [weak self] url, response, error in
        if let error = error as? URLError {
          self?.subscriber?.receive(completion: .failure(error))
          return
        }
        guard let response = response else {
          self?.subscriber?.receive(completion: .failure(URLError(.badServerResponse)))
          return
        }
        guard let url = url else {
          self?.subscriber?.receive(completion: .failure(URLError(.badURL)))
          return
        }
        do {
          let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
          let fileUrl = cacheDir.appendingPathComponent((UUID().uuidString))
          try FileManager.default.moveItem(atPath: url.path, toPath: fileUrl.path)
          _ = self?.subscriber?.receive((url: fileUrl, response: response))
          self?.subscriber?.receive(completion: .finished)
        } catch {
          self?.subscriber?.receive(completion: .failure(URLError(.cannotCreateFile)))
        }
      }
      self.task.resume()
    }

    func cancel() {
      self.task.cancel()
    }
  }
}
