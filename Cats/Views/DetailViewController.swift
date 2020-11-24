//
// Created by Daniela Postigo on 11/21/20.
//

import Foundation
import UIKit
import Combine

class DetailViewController: UIViewController, UIScrollViewDelegate {
  var item: Item

  let imageViewController = ImageViewController()
  private var cancellables: Set<AnyCancellable> = []

  var image: UIImage? {
    get { self.imageViewController.image }
    set { self.imageViewController.image = newValue }
  }

  init(item: Item) {
    self.item = item
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = self.item.id
    self.addChild(self.imageViewController)
    self.view.embed(self.imageViewController.view)
    self.imageViewController.didMove(toParent: self)
    self.fetch()
  }

  func fetch() {
    URLSession.shared
      .downloadTaskPublisher(for: self.item.url)
      .map { UIImage(contentsOfFile: $0.url.path) }
      .replaceError(with: UIImage())
      .receive(on: DispatchQueue.main)
      .sink { [weak self] image in
        self?.image = image
      }
      .store(in: &self.cancellables)
  }
}

