//
// Created by Daniela Postigo on 11/23/20.
//

import Foundation
import UIKit

class ListTableHeaderFooterView: UITableViewHeaderFooterView {
  var activityIndicatorView = UIActivityIndicatorView()
  private(set) var button: UIButton = UIButton(type: .roundedRect)
  private var _textLabel: UILabel = UILabel().then {
    $0.text = "There's nothing here."
    $0.textAlignment = .center
  }

  override var textLabel: UILabel? { self._textLabel }

  // MARK: Init

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)

    self.button.setTitle("Reload", for: .normal)

    let stack = UIStackView(
      axis: .vertical,
      spacing: UIStackView.spacingUseSystem,
      distribution: .fillProportionally,
      views: [self.textLabel!, self.button, self.activityIndicatorView ]
    )
    stack.translatesAutoresizingMaskIntoConstraints = false
    self.contentView.addSubview(stack)

    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
      stack.centerYAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.centerYAnchor),
    ])
  }
}
