//
// Created by Daniela Postigo on 11/23/20.
//

import Foundation
import UIKit
import Combine

class RandomViewController: UIViewController, UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning {
  private var bag: Set<AnyCancellable> = []

  // MARK: View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    let activityIndicator = UIActivityIndicatorView(frame: .zero)
    activityIndicator.startAnimating()
    self.view.embed(activityIndicator)

    API.request(.imageSearch(limit: 1), responseType: [Item].self)
       .receive(on: DispatchQueue.main)
       .sink(
         receiveCompletion: { result in
           switch result {
             case .finished: break
             case .failure(let error):
               Swift.print("error = \(error)")
           }
         },
         receiveValue: { [weak self] items in
           activityIndicator.stopAnimating()
           self?.set(item: items.first!)
         })
       .store(in: &self.bag)
  }

  func set(item: Item) {
    let vc = DetailViewController(item: item)
    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(
      systemItem: .close,
      primaryAction: UIAction { _ in vc.dismiss(animated: true) }
    )
    self.navigationController?.delegate = self
    self.navigationController?.setViewControllers([vc], animated: true)
  }

  // MARK: UINavigationControllerDelegate

  func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return self
  }

  // MARK: UIViewControllerAnimatedTransitioning

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 2.0
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let from = transitionContext.view(forKey: .from)!
    let to = transitionContext.view(forKey: .to)!

    let container = transitionContext.containerView
    let duration = self.transitionDuration(using: transitionContext)
    container.addSubview(from)
    UIView.transition(from: from, to: to, duration: duration) { completed in
      transitionContext.completeTransition(true)
    }
  }
}



