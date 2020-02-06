//
//  Moya+Response.swift
//  GitHubSearchUsers
//
//  Created by Mark Chen on 2020/2/5.
//  Copyright © 2020 Mark Chen. All rights reserved.
//

import Moya
import RxSwift
extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    public func filterGitHubSuccessful() -> Single<ElementType> {
        return flatMap { response in
            guard (200...299).contains(response.statusCode) else {
                do {
                    let gitHubResponse = try response.map(GitHubErrorResponse.self)
                    throw GitHubError.defaultError(gitHubResponse.message)
                } catch {
                    throw error
                }
            }
            
            
            return .just(response)
        }
    }
}
