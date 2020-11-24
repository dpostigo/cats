//
//  ViewController.swift
//  Cats
//
//  Created by Daniela Postigo on 11/21/20.
//

import UIKit
import Combine
import Foundation

class ListTableViewController: UITableViewController {
  var items: [Item]

  private var page: Int = 0 {
    didSet { self.fetch() }
  }
  private var bag: Set<AnyCancellable> = []

  // MARK: Init

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  init(items: [Item] = []) {
    self.items = items
    super.init(nibName: nil, bundle: nil)
  }

  // MARK: View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Cats"
    self.tableView.backgroundView = UIView()
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
    self.tableView.register(ListTableViewCell.self, forCellReuseIdentifier: String(describing: ListTableViewCell.self))
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.update(state: .empty)
  }

  // MARK: Loading

  func fetch() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
      API.request(.imageSearch(limit: 30, page: self.page), responseType: [Item].self)
         .receive(on: DispatchQueue.main)
         .sink(
           receiveCompletion: { result in
             switch result {
               case .finished: break
               case .failure(let error): Swift.print("error = \(error)")
             }
           },
           receiveValue: { [weak self] items in
             self?.perform(action: .fetched(items))
           })
         .store(in: &self.bag)
    }
  }

  // MARK: UITableViewDelegate / UITableViewDatasource

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ListTableViewCell.self), for: indexPath)
    let item = self.items[indexPath.row]
    cell.textLabel!.text = item.id

    URLSession.shared
      .imageDownloadPublisher(item.url)
      .replaceError(with: nil)
      .map { $0?.resized(toLength: ListTableViewCell.imageHeight) }
      .assign(to: \.image, on: cell.imageView!)
      .store(in: &self.bag)
    return cell
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    self.items.count
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = self.items[indexPath.row]
    self.navigationController?.pushViewController(DetailViewController(item: item), animated: true)
  }

  // MARK: UIScrollView

  override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

    if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
      self.perform(action: self.items.isEmpty ? .loadEmpty : .loadMore)
    } else if scrollView.contentOffset.y < 0 && self.items.isEmpty {
      self.perform(action: .loadEmpty)
    }
  }

  // MARK: Private

  private func perform(action: TableAction) {
    switch action {
      case .loadEmpty:
        self.update(state: .emptyLoading)
        self.fetch()
      case .loadMore:
        self.update(state: .loadingMore)
        self.page += 1
      case .fetched(let items):
        self.items = self.items + items
        self.update(state: .none)
        self.tableView.reloadData()
    }
  }

  private func update(state: TableViewState) {
    self.tableView.showsVerticalScrollIndicator = state != .empty || state != .emptyLoading
    switch state {
      case .none:
        self.tableView.tableFooterView = nil

      case .empty:
        let footer = ListTableHeaderFooterView(frame: self.view.bounds)
        footer.button.addAction(UIAction(title: "Reload") { _ in
          self.perform(action: .loadEmpty)
        }, for: .touchUpInside)
        self.tableView.tableFooterView = footer

      case .emptyLoading:
        guard let footer = self.tableView.tableFooterView as? ListTableHeaderFooterView else { return }
        footer.textLabel!.text = "Loading..."
        footer.button.isHidden = true
        footer.activityIndicatorView.startAnimating()

      case .loadingMore:
        let activityIndicator = UIActivityIndicatorView(animating: true)
        activityIndicator.frame.size.height = self.view.bounds.size.height * 0.25
        self.tableView.tableFooterView = activityIndicator
    }
  }
}

fileprivate enum TableAction {
  case loadEmpty
  case loadMore
  case fetched([Item])
}

fileprivate enum TableViewState: String {
  case none
  case empty
  case emptyLoading
  case loadingMore
}