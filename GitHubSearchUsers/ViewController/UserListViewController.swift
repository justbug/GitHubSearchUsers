//
//  ViewController.swift
//  GitHubSearchUsers
//
//  Created by Mark Chen on 2020/2/4.
//  Copyright © 2020 Mark Chen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Moya

class UserListViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: UIScreen.main.bounds.width, height: 56)
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()
    
    private let viewModel: UserListViewModel
    private let bag: DisposeBag
    
    init(viewModel: UserListViewModel) {
        self.viewModel = viewModel
        self.bag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSearchBar()
        bind()
    }

    private func setupView() {
        self.view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.register(UserListCell.self)
        collectionView.register(LoadingView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
        collectionView.rx.setDelegate(self).disposed(by: bag)
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func bind() {
        searchController.searchBar.rx.text
            .orEmpty
            .throttle(1.0, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.searchText)
            .disposed(by: bag)
        
        viewModel.outputs.hasError
            .drive(onNext: { [unowned self] errorMessage in
                self.searchController.isActive = false
                self.showAlert(errorMessage)
            })
            .disposed(by: bag)

        bindCollectionView()
    }
    
    private func bindCollectionView() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String,User>>.init(configureCell: { (_, collectionView, indexPath, user) -> UICollectionViewCell in
            let cell: UserListCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(user: user)
            return cell
        }, configureSupplementaryView: { (_, collectionView, kind, indexPath) -> UICollectionReusableView in
            if kind == UICollectionView.elementKindSectionFooter {
                let view: LoadingView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
                return view
            }
            return UICollectionReusableView()
        })
        
        viewModel.outputs.users
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
    
    private func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
extension UserListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if viewModel.outputs.usersCount > 0 && !viewModel.outputs.isLastPage {
            return .init(width: UIScreen.main.bounds.width, height: 40)
        }
            return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.outputs.usersCount - 3 && !viewModel.outputs.isLastPage {
            viewModel.loadMoreUser()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let loadingView = view as? LoadingView, elementKind == UICollectionView.elementKindSectionFooter {
            loadingView.avatarImageView.startAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if let loadingView = view as? LoadingView, elementKind == UICollectionView.elementKindSectionFooter {
            loadingView.avatarImageView.stopAnimating()
        }
    }
}
