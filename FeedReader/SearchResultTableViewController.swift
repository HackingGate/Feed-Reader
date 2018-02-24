//
//  SearchResultTableViewController.swift
//  FeedReader
//
//  Created by ERU on 2018/02/24.
//  Copyright © 2018年 Hacking Gate. All rights reserved.
//

import UIKit

class SearchResultTableViewController: UITableViewController {
    
    var delegate: ManageDelegate!
    var searchResults = [[String: Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultsCell", for: indexPath)

        let item = searchResults[indexPath.row]
        if let title = item["title"] as? String {
            cell.textLabel?.text = title
        }
        if let description = item["description"] as? String {
            cell.detailTextLabel?.text = description
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = searchResults[indexPath.row]
        if let title = item["title"] as? String, let feedId = item["feedId"] as? String {
            if feedId.hasPrefix("feed/") {
                let validateFeedURL = feedId.replacingOccurrences(of: "feed/", with: "")
                delegate.insertNewObject(title, validateFeedURL)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }

}

extension SearchResultTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        findFeeds(query: searchText) { responseObject, error in
            guard let responseObject = responseObject, error == nil else {
                print(error ?? "Unknown error")
                return
            }
            
            if responseObject.keys.contains("results") {
                self.searchResults = responseObject["results"] as! Array
                print(self.searchResults)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
