//
//  ErrorResponse.swift
//  GitHubSearchUsers
//
//  Created by Mark Chen on 2020/2/5.
//  Copyright © 2020 Mark Chen. All rights reserved.
//

import Foundation
enum GitHubError: Error {
    case defaultError(String)
}
extension GitHubError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .defaultError(let message):
            return message
        }
    }
}
struct GitHubErrorResponse: Decodable {
  let message: String
}
