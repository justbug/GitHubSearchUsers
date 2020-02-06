//
//  GitHubAPI.swift
//  GitHubSearchUsers
//
//  Created by Mark Chen on 2020/2/4.
//  Copyright © 2020 Mark Chen. All rights reserved.
//
import Moya
protocol DecodableResponseTargetType: TargetType {
  associatedtype ResponseType: Decodable
}

enum GitHubAPI {
    case searchUsers(SearchUsersParams)
}

extension GitHubAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    var path: String {
        return "/search/users"
    }
    
    var method: Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .searchUsers(let params):
            return .requestParameters(parameters: params.json, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
