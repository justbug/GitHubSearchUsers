//
//  GitHubService.swift
//  GitHubSearchUsers
//
//  Created by Mark Chen on 2020/2/4.
//  Copyright © 2020 Mark Chen. All rights reserved.
//

import Moya
import RxSwift
import RxCocoa

struct GitHubService {
    let provider: MoyaProvider<GitHubAPI>
    let linkHeader = BehaviorRelay<UserLinkHeader?>(value: nil)
    
    init(provider: MoyaProvider<GitHubAPI> = MoyaProvider<GitHubAPI>(plugins: [NetworkLoggerPlugin.init(verbose: true, responseDataFormatter: LogHelper.JSONResponseDataFormatter)])) {
        self.provider = provider
    }
    
    func searchUser(query: String, page: Int) -> Single<[User]> {
        return provider.rx.request(.searchUsers(SearchUsersParams(query: query, page: page)))
            .filterGitHubSuccessful()
            .flatMap({ response in
                guard let link = response.response?.findLink(relation: "next"), let url = URL(string: link.uri), let query = url.queryParamater("q"), let page = url.queryParamater("page") else {
                    self.linkHeader.accept(nil)
                    return .just(response)
                }
                guard let lastLink = response.response?.findLink(relation: "last"), let lastUrl = URL(string: lastLink.uri), let lastPage = lastUrl.queryParamater("page") else {
                    self.linkHeader.accept(UserLinkHeader(url: url, query: query, page: Int(page) ?? 1, lastPage: nil))
                    return .just(response)
                }
                self.linkHeader.accept(UserLinkHeader(url: url, query: query, page: Int(page) ?? 1, lastPage: Int(lastPage)))
                return .just(response)
            })
            .map([User].self, atKeyPath: CodingKeys.items.rawValue, using: JSONDecoder(), failsOnEmptyData: false)
    }
    
    func loadMore() -> Single<[User]> {
        guard let linkHeader = self.linkHeader.value else {
            return .just([])
        }
        
        return provider.rx.request(.searchUsers(SearchUsersParams(query: linkHeader.query, page: linkHeader.page)))
            .filterGitHubSuccessful()
            .flatMap({ response in
                guard let link = response.response?.findLink(relation: "next"), let url = URL(string: link.uri), let query = url.queryParamater("q"), let page = url.queryParamater("page") else {
                    self.linkHeader.accept(nil)
                    return .just(response)
                }
                guard let linkHeader = self.linkHeader.value else {
                    self.linkHeader.accept(UserLinkHeader(url: url, query: query, page: Int(page) ?? 1, lastPage: nil))
                    return .just(response)
                }
                
                self.linkHeader.accept(UserLinkHeader(url: url, query: query, page: Int(page) ?? 1, lastPage: linkHeader.lastPage))
                return .just(response)
            })
            .map([User].self, atKeyPath: CodingKeys.items.rawValue, using: JSONDecoder(), failsOnEmptyData: false)
        
    }
}
