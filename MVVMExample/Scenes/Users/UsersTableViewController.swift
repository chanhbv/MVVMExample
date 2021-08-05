//
//  HabitsTableViewController.swift
//  MVVMExample
//
//  Created by Bui V Chanh on 05/08/2021.
//

import UIKit

class UsersTableViewController: UITableViewController {
    // MARK: - Vars&Lets

    let cellReuseIdentifier = "userCell"
    lazy var viewModel = UsersViewModel()
    var dataSource: UITableViewDiffableDataSource<Section, UserItem>!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        configureNavigationBar()
        configureDataSource()
        configureBinding()
        viewModel.fetchDataFromAPI()
    }

    private func configureBinding() {
        viewModel.binding = { [unowned self] in
            var snapshot = dataSource.snapshot()
            snapshot.itemIdentifiers(inSection: .main).forEach {
                if !viewModel.listOfUser.contains($0) {
                    snapshot.deleteItems([$0])
                }
            }
            snapshot.appendItems(viewModel.listOfUser.filter { !snapshot.itemIdentifiers(inSection: .main).contains($0) }, toSection: .main)

            snapshot.reloadSections([.main])
            DispatchQueue.main.async {
                dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
        viewModel.bindingSelected = { [unowned self] userItem in
            var snapshot = dataSource.snapshot()
            if snapshot.itemIdentifiers(inSection: .main).contains(userItem) {
                snapshot.deleteItems([userItem])
                snapshot.appendItems([userItem], toSection: .selected)

            } else if snapshot.itemIdentifiers(inSection: .selected).contains(userItem) {
                snapshot.deleteItems([userItem])
                snapshot.appendItems([userItem], toSection: .main)
            }
            snapshot.reloadItems([userItem])
            DispatchQueue.main.async {
                dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
    }

    private func configureNavigationBar() {
        title = "List Of User"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.checkmark"), style: .plain, target: self, action: #selector(save))
        navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "minus.circle"), style: .plain, target: self, action: #selector(clear)),
                                             UIBarButtonItem(image: UIImage(systemName: "plus.circle"), style: .plain, target: self, action: #selector(loadMore))]
    }

    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { [unowned self] tableView, indexPath, userItem in
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "\(userItem.title.uppercased()). \(userItem.fullName)"
            content.textProperties.font = .boldSystemFont(ofSize: 16)
            content.secondaryText = userItem.account
            content.image = UIImage(systemName: viewModel.listOfSelectedUser.contains(userItem) ? "circle.fill" : "circle")

            cell.contentConfiguration = content
            return cell
        })

        var snapshot = NSDiffableDataSourceSnapshot<Section, UserItem>()
        snapshot.appendSections([.selected, .main])
        snapshot.appendItems(viewModel.listOfSelectedUser, toSection: .selected)
        snapshot.appendItems(viewModel.listOfUser, toSection: .main)
        DispatchQueue.main.async { [unowned self] in
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let userItem = dataSource.itemIdentifier(for: indexPath) {
            viewModel.select(userItem)
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        header?.textLabel?.text = Section(rawValue: section)?.title
        return header
    }
}

extension UsersTableViewController {
    @objc func loadMore(_ sender: UIBarButtonItem) {
        viewModel.fetchDataFromAPI()
    }

    @objc func clear(_ sender: UIBarButtonItem) {
        viewModel.clearData()
    }

    @objc func save(_ sender: UIBarButtonItem) {
        viewModel.save()
    }
}
