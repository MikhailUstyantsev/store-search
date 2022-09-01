//
//  ViewController.swift
//  StoreSearch
//
//  Created by Mikhail Ustyantsev on 27.08.2022.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "App name, artist, song, album, e-book"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.barTintColor = UIColor(named: "SearchBar")
        return searchBar
    }()
    
    var hasSearched = false
    var isLoading = false
    var searchResults = [SearchResult]()
    
    var dataTask: URLSessionDataTask?
    
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
        if !searchBar.text!.isEmpty {
        searchBar.resignFirstResponder()
        dataTask?.cancel()
        isLoading = true
        tableView.reloadData()
            
        hasSearched = true
        searchResults = []
        
            let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
            
            let session = URLSession.shared
            
            dataTask = session.dataTask(with: url) { data, response, error in
                if let error = error as NSError?, error.code == -999 {
                    return
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let data = data {
                        self.searchResults = self.parse(data: data)
                        self.searchResults.sort(by: <)
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        return
                    }
                } else {
                    print("Failure! \(response!)")
                }
                DispatchQueue.main.async {
                  self.hasSearched = false
                  self.isLoading = false
                  self.tableView.reloadData()
                  self.showNetworkError()
                }
            }
            dataTask?.resume()
        }
    }
               

    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}




// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
        let searchResult = searchResults[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
        return 1
        } else {
        return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinatinVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
        destinatinVC.modalPresentationStyle = .overFullScreen
        destinatinVC.searchResult = searchResults[indexPath.row]
        self.present(destinatinVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        This method makes sure that you can only select rows when you have actual search results.
        if searchResults.count == 0 || isLoading {
            return nil
          } else {
            return indexPath
          }
    }
    
//    MARK: - Networking
   
    
    
    func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store." + " Please try again", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
//    MARK: - Helper Methods
    func iTunesURL(searchText: String, category: Int) -> URL {
        
        let kind: String
        switch category {
        case 1: kind = "musicTrack"
        case 2: kind = "software"
        case 3: kind = "ebook"
        default: kind = ""
        }
        
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = "https://itunes.apple.com/search?" + "term=\(encodedText)&limit=50&entity=\(kind)"
        let url = URL(string: urlString)
        return url!
    }
    
    
    
    
}
