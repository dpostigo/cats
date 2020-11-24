//
// Created by Daniela Postigo on 11/23/20.
//

import Foundation
import UIKit

class ListTableViewCell: UITableViewCell {
  static let imageHeight: CGFloat = 44
  private let _textLabel = UILabel(frame: .zero)
  private let _imageView = UIImageView(frame: .zero)

  override var imageView: UIImageView? { self._imageView }
  override var textLabel: UILabel? { self._textLabel }

  // MARK: Init

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(style: CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.imageView!.clipsToBounds = true
    self.imageView!.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    self.imageView!.layer.cornerRadius = 4.0
    self.imageView!.translatesAutoresizingMaskIntoConstraints = false

    self.textLabel!.translatesAutoresizingMaskIntoConstraints = false

    let stack = UIStackView(frame: self.contentView.bounds, axis: .horizontal, views: [self.textLabel!, self.imageView!])
    stack.translatesAutoresizingMaskIntoConstraints = false
    self.contentView.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
      stack.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor).then { $0.priority = .defaultHigh },
      stack.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
      self.imageView!.widthAnchor.constraint(equalTo: self.imageView!.heightAnchor),
      self.imageView!.heightAnchor.constraint(equalToConstant: Self.imageHeight),
    ])
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    self.imageView!.image = nil
  }
}
