//
//  UserListViewModel.swift
//  GitHubSearchUsers
//
//  Created by Mark Chen on 2020/2/4.
//  Copyright © 2020 Mark Chen. All rights reserved.
//

import RxSwift
import RxCocoa
import Moya
import RxDataSources
import RxOptional

protocol UserListViewModelInput {
    var searchText: PublishRelay<String> { get }
    var service: GitHubService { get set }
}

protocol UserListViewModelOutput {
    var users: Driver<[SectionModel<String, User>]> { get }
    var hasError: Driver<String> { get }
    var isLoading: Bool { get set}
    var usersCount: Int { get }
    var isLastPage: Bool { get }
}

protocol UserListViewModelType {
    var inputs: UserListViewModelInput { get }
    var outputs: UserListViewModelOutput { get }
}

class UserListViewModel: UserListViewModelInput, UserListViewModelOutput {
    
    
    // MARK: Inputs
    var searchText = PublishRelay<String>()
    var service: GitHubService
    
    // MARK: Outputs
    var users: Driver<[SectionModel<String, User>]> {
        return _users.map({ [SectionModel<String,User>(model: "UserSectionModel", items: $0)] }).asDriver(onErrorJustReturn: [])
    }
    
    var hasError: Driver<String> {
        return error
            .map { $0.localizedDescription }
            .asDriver(onErrorJustReturn: "No Error description")
    }
    
    var isLoading: Bool = false
    
    var usersCount: Int {
        return _users.value.count
    }
    var isLastPage: Bool {
        return _isLastPage.value
    }
    
    private let _users = BehaviorRelay<[User]>(value: [])
    private let error = PublishSubject<Error>()
    private let _isLastPage = BehaviorRelay<Bool>(value: false)
    private let bag = DisposeBag()
    
    init(service: GitHubService) {
        self.service = service
        
        searchText
            .filter({ !$0.isEmpty })
            .flatMap({ service.searchUser(query: $0, page: 1)})
            .catchError({ [unowned self] (error)in
                self.error.onNext(error)
                return .just(self._users.value)
            }).subscribe(onNext: { (users) in
               self._users.accept(users)
            }).disposed(by: bag)
        
        service.linkHeader
            .map({ (linkHeader) in
                guard let linkHeader = linkHeader, let lastPage = linkHeader.lastPage else {
                    return true
                }
                return linkHeader.page == lastPage
            })
            .bind(to: _isLastPage)
            .disposed(by: bag)
        
    }
    
    func loadMoreUser() {
        self.service.loadMore().subscribe(onSuccess: { (new) in
            var current_user = self._users.value
            current_user.append(contentsOf: new)
            self._users.accept(current_user)
        }) { (error) in
            self.error.onNext(error)
        }.disposed(by: bag)
    }
}

extension UserListViewModel: UserListViewModelType {
    var inputs: UserListViewModelInput { return self }
    var outputs: UserListViewModelOutput { return self }
}
