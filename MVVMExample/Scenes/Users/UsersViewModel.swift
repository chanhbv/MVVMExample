//
//  HabitsViewModel.swift
//  MVVMExample
//
//  Created by Bui V Chanh on 05/08/2021.
//

import Foundation
import UIKit

enum Section: Int, CaseIterable {
    case selected, main

    var title: String {
        switch self {
            case .main: return "FROM API"
            case .selected: return "SELECTED"
        }
    }
}

struct UserItem: Hashable {
    let id: String
    let account: String
    let fullName: String
    let title: String
    let picture: String
    init(userInfo: UserInfo) {
        id = userInfo.id
        account = userInfo.email
        fullName = "\(userInfo.firstName) \(userInfo.lastName)"
        title = userInfo.title
        picture = userInfo.picture
    }

    static func == (lhs: UserItem, rhs: UserItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class UsersViewModel {
    struct State {
        var page = 0
        let limit = 5
    }

    var listOfUser: [UserItem]! {
        didSet {
            binding?()
        }
    }

    var listOfSelectedUser: [UserItem]!

    typealias BindingViewModelToView = () -> ()
    typealias BindingSelectedViewModelToView = (UserItem) -> ()

    var binding: BindingViewModelToView?
    var bindingSelected: BindingSelectedViewModelToView?

    var userREST: UserRestService
    var state: State

    init() {
        listOfUser = []
        listOfSelectedUser = []
        userREST = UserRestService()
        state = State()
    }

    func fetchDataFromAPI() {
        state.page += 1
        userREST.fetchUsers(page: state.page, limit: state.limit) { [unowned self] results in
            if let results = results {
                self.listOfUser.append(contentsOf:
                    results.data.map { UserItem(userInfo: $0) }.filter { !self.listOfSelectedUser.contains($0) }
                )
            }
        }
    }

    func clearData() {
        listOfUser = []
        if state.page >= 9 {
            state = State()
        }
    }

    func select(_ userItem: UserItem) {
        if listOfSelectedUser.contains(userItem) {
            listOfSelectedUser.removeAll { $0.id == userItem.id }
            listOfUser.append(userItem)
        } else {
            listOfSelectedUser.append(userItem)
            listOfUser.removeAll { $0.id == userItem.id }
        }
        bindingSelected?(userItem)
    }

    func save() {
        // TODO:
    }
}
