//
//  User.swift
//  GitHubSearchUsers
//
//  Created by Mark Chen on 2020/2/4.
//  Copyright © 2020 Mark Chen. All rights reserved.
//

import Foundation

enum CodingKeys: String {
    case items = "items"
}

struct User: Decodable {
  let login: String
  let avatar_url: String
}
