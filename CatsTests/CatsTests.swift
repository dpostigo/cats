//
//  CatsTests.swift
//  CatsTests
//
//  Created by Daniela Postigo on 11/21/20.
//

import XCTest
import Combine
@testable import Cats

class CatsTests: XCTestCase {

  override func setUpWithError() throws {
    //      self.
  }

  override func tearDownWithError() throws {
  }

  func testExample() throws {
    let e = self.expectation(description: "testExample")
    let thing = API.request(.imageSearch(), responseType: [Item].self)
                   .receive(on: DispatchQueue.main)
                   .sink(
                     receiveCompletion: { result in
                       switch result {
                         case .finished: break
                         case .failure(let error):
                           Swift.print("error = \(error)")
                       }
                       e.fulfill()
                     },
                     receiveValue: { images in
                       Swift.print("images = \(images)")
                     })
    self.waitForExpectations(timeout: 5000)
  }
}
