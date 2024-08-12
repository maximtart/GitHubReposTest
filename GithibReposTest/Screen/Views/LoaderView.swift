//
//  LoaderView.swift
//  GithibReposTest
//
//  Created by Maxim on 12.08.2024.
//

import UIKit

final class LoaderView: UIView {
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffectV = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurEffectV.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectV
        
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let actInd = UIActivityIndicatorView(style: .large)
        actInd.translatesAutoresizingMaskIntoConstraints = false
        actInd.color = UIColor.white
        return actInd
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
        self.isHidden = false
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
        self.isHidden = true
    }
}

private extension LoaderView {
    func setupViews() {
        addSubview(blurEffectView)
        addSubview(activityIndicator)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: self.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
