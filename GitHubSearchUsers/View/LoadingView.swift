//
//  LoadingView.swift
//  GitHubSearchUsers
//
//  Created by Mark Chen on 2020/2/5.
//  Copyright © 2020 Mark Chen. All rights reserved.
//

import UIKit

class LoadingView: UICollectionReusableView {
    lazy var avatarImageView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.addSubview(avatarImageView)
        avatarImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        avatarImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

}
extension LoadingView: Reusable {}
