//
// Created by Daniela Postigo on 11/21/20.
//

import Foundation
import UIKit

protocol Thenable { }

extension Thenable {
  @discardableResult func then(_ block: (Self) -> Void) -> Self {
    block(self)
    return self
  }
}

extension NSObject: Thenable {}
