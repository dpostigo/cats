//
// Created by Daniela Postigo on 11/21/20.
//

import Foundation

struct Item: Identifiable, Codable {
  let id: String
  let url: URL
  let width: Float
  let height: Float
}
