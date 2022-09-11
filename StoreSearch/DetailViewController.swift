//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Mikhail Ustyantsev on 31.08.2022.
//

import UIKit

class DetailViewController: UIViewController {
    
    var searchResult: SearchResult!
    var downloadTask: URLSessionDownloadTask?
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      transitioningDelegate = self
    }
    
    enum AnimationStyle {
        case slide
        case fade
    }
    
    var dismissStyle = AnimationStyle.fade
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if self.searchResult != nil {
            self.updateUI()
            }
        }
        
        let gestureRecognizer = UITapGestureRecognizer(
          target: self,
          action: #selector(closeVC(_:)))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        view.backgroundColor = UIColor.clear
        let dimmingView = GradientView(frame: CGRect.zero)
        dimmingView.frame = view.bounds
        view.insertSubview(dimmingView, at: 0)
    }
    
    func updateUI() {
        let popUp = PopUP()
        popUp.nameLabel.text = searchResult.name
          if searchResult.artist.isEmpty {
              popUp.artistNameLabel.text = "Unknown"
          } else {
              popUp.artistNameLabel.text = searchResult.artist
          }
        popUp.kindValueLabel.text = searchResult.type
        popUp.genreValueLabel.text = searchResult.genre
        // Show price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        let priceText: String
            if searchResult.price == 0 {
              priceText = "Free"
            } else if let text = formatter.string(
                      from: searchResult.price as NSNumber) {
              priceText = text
            } else {
              priceText = ""
            }
        popUp.purchaseButton.setTitle(priceText, for: .normal)
        popUp.purchaseButton.addTarget(self, action: #selector(openInStore(_:)), for: .touchUpInside)
        
        // Get image
        if let largeURL = URL(string: searchResult.imageLarge) {
            downloadTask = popUp.artworkImageView.loadImage(url: largeURL)
        }
        
//        let traitCollection = UITraitCollection()
//        
//        if traitCollection.verticalSizeClass == .compact {
//            popUp.container.heightAnchor.constraint(equalTo: popUp.heightAnchor, multiplier: 0.9).isActive = true
//            popUp.heightAnchor.constraint(equalTo: popUp.heightAnchor, multiplier: 0.45).isActive = false
//       } else {
//           popUp.container.heightAnchor.constraint(equalTo: popUp.heightAnchor, multiplier: 0.45).isActive = true
//           popUp.container.heightAnchor.constraint(equalTo: popUp.heightAnchor, multiplier: 0.9).isActive = false
//       }
        
        self.view.addSubview(popUp)
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "ArtistName")
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            view.trailingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 8)
        ])
    }

    private let closeButton: UIButton = {
        let button = UIButton(type: .close)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeVC(_:)), for: .touchUpInside)
        return button
}()

    deinit {
      print("deinit \(self)")
      downloadTask?.cancel()
    }
    
    
//    MARK: - Actions
    
    @objc func closeVC(_ sender: UIButton) {
        dismissStyle = .slide
        dismiss(animated: true)
    }
    
    @objc func openInStore(_ sender: UIButton) {
      if let url = URL(string: searchResult.storeURL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    }
    
}

extension DetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldReceive touch: UITouch
  ) -> Bool {
      return (touch.view === self.view)
  }
}



extension DetailViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissStyle {
        case .slide: return SlideOutAnimationController()
        case .fade: return FadeOutAnimationController()
            }
        }
    
}
