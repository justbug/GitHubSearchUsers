//
//  URL+QueryParamater.swift
//  GitHubSearchUsers
//
//  Created by Mark Chen on 2020/2/5.
//  Copyright © 2020 Mark Chen. All rights reserved.
//

import Foundation
extension URL {
    func queryParamater(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
