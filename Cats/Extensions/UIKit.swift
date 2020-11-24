//
// Created by Daniela Postigo on 11/22/20.
//

import Foundation
import UIKit

extension UIView {
  func embed(_ subview: UIView) {
    subview.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(subview)

    NSLayoutConstraint.activate([
      subview.topAnchor.constraint(equalTo: self.topAnchor),
      subview.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      subview.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      subview.trailingAnchor.constraint(equalTo: self.trailingAnchor)
    ])
  }

  func embedLayoutGuide(_ child: UIView, layoutGuide: UILayoutGuide? = nil) {
    let guide = layoutGuide ?? self.layoutMarginsGuide
    child.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(child)

    NSLayoutConstraint.activate([
      child.topAnchor.constraint(equalTo: guide.topAnchor),
      child.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
      child.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
      child.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
    ])
  }
}

extension UIStackView {
  convenience init(
    frame: CGRect = .zero,
    axis: NSLayoutConstraint.Axis = .horizontal,
    spacing: CGFloat = 0,
    alignment: UIStackView.Alignment = .fill,
    distribution: UIStackView.Distribution = .fill,
    views: [UIView] = []) {
    self.init(frame: frame)
    self.axis = axis
    self.spacing = spacing
    self.alignment = alignment
    self.distribution = distribution
    self.addArrangedSubviews(views)
  }

  func addArrangedSubviews(_ views: [UIView]) { views.forEach { self.addArrangedSubview($0) } }
}

extension UITableViewHeaderFooterView {
  convenience init(contentView: UIView) {
    self.init(frame: .zero)
    self.contentView.embed(contentView)
    self.frame.size = self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
  }
}

extension UIActivityIndicatorView {
  convenience init(
    style: UIActivityIndicatorView.Style = .medium,
    animating: Bool = false,
    frame: CGRect? = nil
  ) {
    self.init(style: style)
    self.frame = frame ?? self.frame
    if animating { self.startAnimating() }
  }
}

extension UIImage {

  func resized(toLength aLength: CGFloat = 100) -> UIImage? {
    let multiplier = aLength / min(self.size.width, self.size.height)

    let scaled = CGSize(
      width: self.size.width * multiplier,
      height: self.size.height * multiplier
    )
    let length = min(scaled.width, scaled.height)
    let cropped = CGSize(width: length, height: length)

    let rect = CGRect(origin: .zero, size: scaled)
      .offsetBy(
        dx: cropped.width - scaled.width,
        dy: cropped.height - scaled.height
      )

    let renderer = UIGraphicsImageRenderer(size: cropped)
    return renderer.image { context in
      self.draw(in: rect)
    }
  }

  func squared() -> UIImage? {
    let length = min(self.size.width, self.size.height)
    let cropped = CGSize(width: length, height: length)

    let rect = CGRect(origin: .zero, size: self.size)
      .offsetBy(
        dx: length - self.size.width,
        dy: length - self.size.height
      )

    let renderer = UIGraphicsImageRenderer(size: cropped)
    return renderer.image { context in
      self.draw(in: rect)
    }
  }
}

