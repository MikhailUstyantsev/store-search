//
//  Temporary file.swift
//  StoreSearch
//
//  Created by Mikhail Ustyantsev on 08.09.2022.
//

import Foundation


//func performSearch() {
//    if !searchBar.text!.isEmpty {
//    searchBar.resignFirstResponder()
//    dataTask?.cancel()
//    isLoading = true
//    tableView.reloadData()
//        
//    hasSearched = true
//    searchResults = []
//    
//        let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
//        
//        let session = URLSession.shared
//        
//        dataTask = session.dataTask(with: url) { data, response, error in
//            if let error = error as NSError?, error.code == -999 {
//                return
//            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                if let data = data {
//                    self.searchResults = self.parse(data: data)
//                    self.searchResults.sort(by: <)
//                    DispatchQueue.main.async {
//                        self.isLoading = false
//                        self.tableView.reloadData()
//                    }
//                    return
//                }
//            } else {
//                print("Failure! \(response!)")
//            }
//            DispatchQueue.main.async {
//              self.hasSearched = false
//              self.isLoading = false
//              self.tableView.reloadData()
//              self.showNetworkError()
//            }
//        }
//        dataTask?.resume()
//    }
//}
