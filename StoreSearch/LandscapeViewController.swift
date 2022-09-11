//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Mikhail Ustyantsev on 02.09.2022.
//

import UIKit

class LandscapeViewController: UIViewController {

    var search: Search!
    
    private var firstTime = true
//    This array will keep track of all the active URLSessionDownloadTask objects
    private var downloads = [URLSessionDownloadTask]()
    
    let scrollView: UIScrollView = {
       let scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.addSubview(UIView)
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = .systemGray4
        pageControl.currentPageIndicatorTintColor = .systemGray
//        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.addTarget(self, action: #selector(pageChanged(_:)), for: .touchUpInside)
        return pageControl
    }()
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let safeFrame = view.safeAreaLayoutGuide.layoutFrame

        scrollView.frame = safeFrame
        pageControl.frame = CGRect(x: safeFrame.origin.x, y: safeFrame.size.height - pageControl.frame.size.height, width: safeFrame.size.width, height: pageControl.frame.size.height)

        if firstTime {
            firstTime = false
            
            switch search.state {
            case .notSearchedYet, .loading, .noResults:
                break
            case .results(let list):
            tileButtons(list)
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        scrollView.delegate = self
        setupView()
//        setupConstraints()
        pageControl.numberOfPages = 0
    }
    
    private func setupView() {
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        
    }
    
    private func setupConstraints() {
    
        let frameGuide = scrollView.frameLayoutGuide
        let contentGuide = scrollView.contentLayoutGuide

//        let margins = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            frameGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            frameGuide.topAnchor.constraint(equalTo: view.topAnchor),
            frameGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageControl.topAnchor.constraint(equalTo: frameGuide.bottomAnchor),
            
            pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
//            frameGuide.widthAnchor.constraint(equalTo: contentGuide.widthAnchor),
//          contentGuide.heightAnchor.constraint(equalToConstant: 1000)
        ])
        
    }
    

//    MARK: - Private Methods
    
    private func tileButtons(_ searchResults: [SearchResult]) {
        let itemWidth: CGFloat = 94
        let itemHeight: CGFloat = 88
        var columnsPerPage = 0
        var rowsPerPage = 0
        var marginX: CGFloat = 0
        var marginY: CGFloat = 0
        let viewWidth = scrollView.bounds.size.width
        let viewHeight = scrollView.bounds.size.height
        
        columnsPerPage = Int(viewWidth / itemWidth)
        rowsPerPage = Int(viewHeight / itemHeight)
        
        marginX = (viewWidth - (CGFloat(columnsPerPage) * itemWidth)) * 0.5
        marginY = (viewHeight - (CGFloat(rowsPerPage) * itemHeight)) * 0.5
        
//        Button size
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth) / 2
        let paddingVert = (itemHeight - buttonHeight) / 2
        
//        Add the buttons
        var row = 0
        var column = 0
        var x = marginX
        for (index, result) in searchResults.enumerated() {
            
            let button = UIButton(type: .custom)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
//            button.setTitle("\(index)", for: .normal)
            
            downLoadImage(for: result, andPlaceOn: button)
            
            button.frame = CGRect(x: x + paddingHorz, y: marginY + CGFloat(row) * itemHeight + paddingVert, width: buttonWidth, height: buttonHeight)
            
            scrollView.addSubview(button)
            
            row += 1
            if row == rowsPerPage {
                row = 0; x += itemWidth; column += 1
                if column == columnsPerPage {
                    column = 0; x += marginX * 2
                }
            }
        }
//        Set scroll view content size
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        scrollView.contentSize = CGSize(width: CGFloat(numPages) * viewWidth, height: scrollView.bounds.size.height)
        
        print("Number of pages: \(numPages)")
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
    }
    
//    You also need to know when the user taps on the Page Control so you can update the scroll view
    
   @objc private func pageChanged(_ sender: UIPageControl) {
        scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
    }
    
    private func downLoadImage(for searchResult: SearchResult, andPlaceOn button: UIButton) {
        if let url = URL(string: searchResult.imageSmall) {
            let task = URLSession.shared.downloadTask(with: url) {
              [weak button] url, _, error in
              if error == nil, let url = url,
    let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
        DispatchQueue.main.async {
          if let button = button {
//              button.imageView?.contentMode = .scaleAspectFill
              button.setImage(image.resized(withBounds: CGSize(width: 60, height: 60)), for: .normal)
             }
           }
         }
       }
       task.resume()
       downloads.append(task)
      }
    }
    
    deinit {
        print("deinit \(self)")
        for task in downloads{
            task.cancel()
        }
    }
    

}


//Connect the scroll view and page control

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2) / width)
        pageControl.currentPage = page
    }
}
