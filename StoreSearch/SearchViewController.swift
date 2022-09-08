//
//  ViewController.swift
//  StoreSearch
//
//  Created by Mikhail Ustyantsev on 27.08.2022.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var landscapeVC: LandscapeViewController?
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "App name, artist, song, album, e-book"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.barTintColor = UIColor(named: "SearchBar")
        return searchBar
    }()
    
    private let search = Search()
    
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
        }
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        setupView()
        
        var cellNib = UINib(nibName: "SearchResultCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        searchBar.becomeFirstResponder()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        @unknown default:
            break
        }
    }
    
    private func setupView() {
//        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        viewRespectsSystemMinimumLayoutMargins = false
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0.0, leading: 8.0, bottom: 0.0, trailing: 8.0)
        
        view.addSubview(searchBar)
        view.addSubview(segmentedControl)
        
        let margins = view.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            
            segmentedControl.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            margins.trailingAnchor.constraint(equalTo: segmentedControl.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8)
        ])
    }

//    MARK: - Segmented Control
    
    let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["All", "Music", "Software", "E-books"])
        segmentedControl.addTarget(self, action: #selector(searchSegmentDidChange(_:)), for: .valueChanged)
        segmentedControl.backgroundColor = .systemGray5
        segmentedControl.selectedSegmentTintColor = .lightGray
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    @objc func searchSegmentDidChange(_ sender: UISegmentedControl) {
        performSearch()
    }
}

//MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      performSearch()
    }

    func performSearch() {
        search.performSearch(for: searchBar.text!, category: segmentedControl.selectedSegmentIndex) {
            success in
            if !success {
                self.showNetworkError()
            }
            self.tableView.reloadData()
        }
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
               

    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}




// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if search.isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else
        if search.searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = search.searchResults[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if search.isLoading {
            return 1
        } else if !search.hasSearched {
            return 0
        } else if search.searchResults.count == 0 {
        return 1
        } else {
            return search.searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinatinVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
        destinatinVC.modalPresentationStyle = .overFullScreen
        destinatinVC.searchResult = search.searchResults[indexPath.row]
        self.present(destinatinVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        This method makes sure that you can only select rows when you have actual search results.
        if search.searchResults.count == 0 || search.isLoading {
            return nil
          } else {
            return indexPath
          }
    }
    
//    MARK: - Networking
   
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store." + " Please try again", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
//    MARK: - Helper Methods
   
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        
        guard landscapeVC == nil else { return }
        
        landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeVC {
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            view.addSubview(controller.view)
//            Tell the SearchViewController that the LandscapeViewController is now managing that part of the screen, using addChild(). If you forget this step, then the new view controller may not always work correctly
            addChild(controller)
//            Tell the new view controller that it now has a parent view controller with didMove(toParent:)
            coordinator.animate { _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
            } completion: { _ in
                controller.didMove(toParent: self)
            }
        }
        if self.presentedViewController != nil {
            self.dismiss(animated: true, completion: nil)
        }
      }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            controller.willMove(toParent: nil)
            
            coordinator.animate { _ in
                controller.view.alpha = 0
            } completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParent()
                self.landscapeVC = nil
            }
          }
        }
    
}
