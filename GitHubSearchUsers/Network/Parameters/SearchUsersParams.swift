//
//  SearchUsersParams.swift
//  GitHubSearchUsers
//
//  Created by Mark Chen on 2020/2/4.
//  Copyright © 2020 Mark Chen. All rights reserved.
//

import Foundation
protocol Parameters {
    var json: [String:Any] { get }
}
struct SearchUsersParams: Parameters {
    let query: String
    let page: Int
    var json: [String : Any] {
        return [
            "q": query,
            "page": page
        ]
    }
}
