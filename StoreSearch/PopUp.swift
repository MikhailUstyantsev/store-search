//
//  PopUp.swift
//  StoreSearch
//
//  Created by Mikhail Ustyantsev on 31.08.2022.
//

import UIKit

class PopUP: UIView {
    
   let artworkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "imageViewPlaceholder"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let nameLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .left
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh + 1, for: .vertical)
        label.text = "1 credit"
        return label
    }()
    
    let artistNameLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .left
        label.text = "In-App purchase for one book credit"
        return label
    }()

    lazy var upperStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, artistNameLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = UIStackView.spacingUseSystem
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let typeLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .systemGray
        label.widthAnchor.constraint(equalToConstant: 50).isActive = true
        label.text = "Type:"
        return label
    }()
    
    let genreLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .systemGray
        label.widthAnchor.constraint(equalToConstant: 50).isActive = true
        label.text = "Genre:"
        return label
    }()
    
    lazy var leadingStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [typeLabel, genreLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = UIStackView.spacingUseSystem
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let kindValueLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = "Kind Value"
        return label
    }()
    
    let genreValueLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = "Genre Value"
        return label
    }()
    
    lazy var trailingStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [kindValueLabel, genreValueLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = UIStackView.spacingUseSystem
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var lowerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [leadingStack, trailingStack])
        stack.spacing = UIStackView.spacingUseSystem
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let purchaseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("$ 9.99", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.systemGreen.cgColor
        button.backgroundColor = .clear
        button.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        return button
    }()
        
    
    let container: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(named: "DetailBG")
        container.layer.cornerRadius = 15
        return container
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animateOUT)))
        
//        self.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        self.frame = UIScreen.main.bounds
        
        
        
        self.addSubview(container)
        container.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        container.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.85).isActive = true
        
        if traitCollection.verticalSizeClass == .compact {
           container.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8).isActive = true
            container.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.45).isActive = false
        } else {
            container.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.45).isActive = true
            container.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8).isActive = false
        }
        
        
        container.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.45).isActive = true
        
//        container.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: 60).isActive = true
    //        container.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: 60).isActive = true
        
        container.addSubview(artworkImageView)
        
        artworkImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        artworkImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 10).isActive = true
        artworkImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        artworkImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        container.addSubview(upperStack)
        upperStack.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.2).isActive = true
        upperStack.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.9).isActive = true
        upperStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10).isActive = true
        upperStack.topAnchor.constraint(equalTo: artworkImageView.bottomAnchor, constant: 8).isActive = true
        
        container.addSubview(lowerStack)
        lowerStack.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.2).isActive = true
        lowerStack.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.9).isActive = true
        lowerStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10).isActive = true
        lowerStack.topAnchor.constraint(equalTo: upperStack.bottomAnchor, constant: 8).isActive = true
        
        container.addSubview(purchaseButton)
        purchaseButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        purchaseButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        container.trailingAnchor.constraint(equalTo: purchaseButton.trailingAnchor, constant: 8).isActive = true
        container.bottomAnchor.constraint(equalTo: purchaseButton.bottomAnchor, constant: 12).isActive = true
        
        animateIN()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
//    MARK: - Helper methods
    @objc func animateOUT() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn) {
            self.container.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
            self.alpha = 0
        } completion: { (complete) in
            if complete {
                self.removeFromSuperview()
            }
        }
    }

    @objc func animateIN() {
        self.container.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
        self.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn) {
            self.container.transform = .identity
            self.alpha = 1
        } 
    }



}
