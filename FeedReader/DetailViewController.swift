//
//  DetailViewController.swift
//  FeedReader
//
//  Created by Eru on H29/10/15.
//  Copyright © 平成29年 Hacking Gate. All rights reserved.
//

import UIKit
import SafariServices
import FeedKit

class DetailViewController: UITableViewController {
    
    var result: Result?

    func configureView() {
        // Update the user interface for the detail item.
        
        guard let feedURLString = detailItem?.feedURLString else { return }
        guard let feedURL = URL(string: feedURLString) else { return }
        let parser = FeedParser(URL: feedURL) // or FeedParser(data: data)
        parser?.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            // Do your thing, then back to the Main thread
            self.result = result
            DispatchQueue.main.async {
                // ..and update the UI
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Event? {
        didSet {
            title = detailItem?.feedTitle
            // Update the view.
            configureView()
        }
    }

}

// MARK: - Table View Data Source

extension DetailViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let items = result?.rssFeed?.items {
                // RSS
                return items.count
            } else if let entries = result?.atomFeed?.entries {
                // Atom
                return entries.count
            } else if let items = result?.jsonFeed?.items {
                // JSON
                return items.count
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedItem", for: indexPath)
        
        if let items = result?.rssFeed?.items {
            // RSS
            let item = items[indexPath.row]
            cell.textLabel?.text = item.title
        } else if let entries = result?.atomFeed?.entries {
            // Atom
            let entry = entries[indexPath.row]
            cell.textLabel?.text = entry.title
        } else if let items = result?.jsonFeed?.items {
            // JSON
            let item = items[indexPath.row]
            cell.textLabel?.text = item.title
        }
        
        return cell
    }
    
}

// MARK: - Table View Delegate

extension DetailViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var urlString: String?
        if let items = result?.rssFeed?.items {
            // RSS
            urlString = items[indexPath.row].link
        } else if let entries = result?.atomFeed?.entries {
            // Atom
            urlString = entries[indexPath.row].links?.first?.attributes?.href
        } else if let items = result?.jsonFeed?.items {
            // JSON
            urlString = items[indexPath.row].url
        }
        
        if let urlString = urlString, let itemURL = URL(string: urlString) {
            
            let configuration = SFSafariViewController.Configuration.init()
            configuration.entersReaderIfAvailable = true
            let safariViewController = SFSafariViewController.init(url: itemURL, configuration: configuration)
            
            self.present(safariViewController, animated: true, completion: {
                
            })
        }
    }
    
}

extension DetailViewController {
    func reusableCell() -> UITableViewCell {
        let reuseIdentifier = "FeedItem"
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) { return cell }
        let cell = UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}


