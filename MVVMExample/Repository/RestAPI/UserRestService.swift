//
//  UserRestService.swift
//  MVVMExample
//
//  Created by Bui V Chanh on 05/08/2021.
//

import Foundation

struct UserPage: Decodable {
    let limit: Int
    let offset: Int
    let page: Int
    let total: Int
    let data: [UserInfo]
}

struct UserInfo: Decodable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let title: String
    let picture: String
}

class UserRestService {
    func fetchUsers(page: Int, limit: Int, completion: @escaping (UserPage?) -> ()) {
        var requestURL = URLRequest(url: URL(string: "https://dummyapi.io/data/api/user?page=\(page)&limit=\(limit)")!)
        requestURL.setValue("610b28290d572c4203a4cbac", forHTTPHeaderField: "app-id")

        URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let userPage = try jsonDecoder.decode(UserPage.self, from: data)
                    completion(userPage)
                } catch {
                    print(error)
                    completion(nil)
                }
            }

        }.resume()
    }
}
