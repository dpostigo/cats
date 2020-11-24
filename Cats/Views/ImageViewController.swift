//
// Created by Daniela Postigo on 11/22/20.
//

import Foundation
import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
  var imageView: UIImageView = UIImageView(frame: .zero)

  var image: UIImage? {
    get { self.imageView.image }
    set {
      self.imageView.image = newValue
      guard self.viewIfLoaded?.window != nil else { return }
      self.view.layoutIfNeeded()
      self.updateZoomScale()
    }
  }
  var scrollView: UIScrollView { self.view.subviews.first as! UIScrollView }

  // MARK: Init

  convenience init(image: UIImage) {
    self.init(nibName: nil, bundle: nil)
    self.image = image
  }

  // MARK: View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .white

    let scrollView = UIScrollView(frame: .zero)
//    scrollView.backgroundColor = .black
    scrollView.delegate = self
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    // scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(scrollView)
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
    ])

    self.imageView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(self.imageView)
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
      imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
      imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
    ])

    let doubleTap = UITapGestureRecognizer(
      target: self,
      action: #selector(doubleTapped(_:))
    ).then { $0.numberOfTapsRequired = 2; $0.numberOfTouchesRequired = 1 }
    scrollView.addGestureRecognizer(doubleTap)

    let singleTap = UITapGestureRecognizer(
      target: self,
      action: #selector(singleTapped(_:))
    ).then { $0.numberOfTapsRequired = 1; $0.numberOfTouchesRequired = 1 }

    scrollView.addGestureRecognizer(singleTap)


    singleTap.require(toFail: doubleTap)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.view.layoutIfNeeded()
    self.updateZoomScale()
  }

  func updateZoomScale() {
    guard let imageSize = self.image?.size else { return }
    let size = self.view.bounds.size
    let minScale = min(size.width / imageSize.width, size.height / imageSize.height)
    let maxScale = max((size.width + 1.0) / imageSize.width, (size.height + 1.0) / imageSize.height)

    self.scrollView.minimumZoomScale = minScale
    scrollView.maximumZoomScale = maxScale

    self.scrollView.zoomScale = minScale
  }

  // MARK: Double tap

  @objc func singleTapped(_ recognizer: UITapGestureRecognizer) {
    UIView.animate(withDuration: 0.4) {
      if let navigationController = self.navigationController {
        navigationController.isNavigationBarHidden = !navigationController.isNavigationBarHidden
      }
      self.view.backgroundColor = self.view.backgroundColor == .white ? .black : .white
    }
  }

  @objc func doubleTapped(_ recognizer: UITapGestureRecognizer) {
    let point = recognizer.location(in: self.view)
    let scale = self.scrollView.zoomScale == self.scrollView.minimumZoomScale ? self.scrollView.maximumZoomScale : self.scrollView.minimumZoomScale
    let size = self.scrollView.bounds.size / scale

    let rect = CGRect(
      x: point.x - (size.width * 0.5),
      y: point.y - (size.height * 0.5),
      width: size.width,
      height: size.height
    )
    self.scrollView.zoom(to: rect, animated: true)
  }

  // MARK: UIScrollViewDelegate
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    scrollView.subviews.first!
  }

  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    scrollView.contentInset.top = max(0, (scrollView.bounds.size.height - scrollView.contentSize.height) / 2)
    scrollView.contentInset.left = max(0, (scrollView.bounds.size.width - scrollView.contentSize.width) / 2)
  }
}

extension CGSize {
  static func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
    CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
  }
}

enum CustomGesture {
  case singleTap(UITapGestureRecognizer)
  case panEnded(UIPanGestureRecognizer)
  case doubleTap(UITapGestureRecognizer)
}
