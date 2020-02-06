//
//  LinkerHeader.swift
//  GitHubSearchUsers
//
//  Created by Mark Chen on 2020/2/5.
//  Copyright © 2020 Mark Chen. All rights reserved.
//

import Foundation

struct UserLinkHeader {
  let url: URL
  let query: String
    var page: Int
  let lastPage: Int?
}
