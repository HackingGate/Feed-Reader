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
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            // Do your thing, then back to the Main thread
            self.result = result
            DispatchQueue.main.async {
                // ..and update the UI
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the detail view's `navigationItem`.
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        
        refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        
        // Check for force touch feature, and add force touch/previewing capability.
        if traitCollection.forceTouchCapability == .available {
            /*
             Register for `UIViewControllerPreviewingDelegate` to enable
             "Peek" and "Pop".
             (see: MasterViewController+UIViewControllerPreviewing.swift)
             
             The view controller will be automatically unregistered when it is
             deallocated.
             */
            registerForPreviewing(with: self, sourceView: view)
        }
    }
    
    @objc func refresh(sender:AnyObject) {
        configureView()
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
        guard let itemURL = getFeedItemURL(indexPath: indexPath) else { return }
        
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = true
        let safariViewController = SFSafariViewController(url: itemURL, configuration: configuration)
        
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    func getFeedItemURL(indexPath: IndexPath) -> URL? {
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
        
        guard let urlStringUnrap = urlString,
            let itemURL = URL(string: urlStringUnrap) else { return nil }
        
        return itemURL
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

extension DetailViewController: UIViewControllerPreviewingDelegate {
    // MARK: UIViewControllerPreviewingDelegate
    
    /// Create a previewing view controller to be shown at "Peek".
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Obtain the index path and the cell that was pressed.
        guard let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        guard let itemURL = getFeedItemURL(indexPath: indexPath) else { return nil }
        
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = true
        let safariViewController = SFSafariViewController(url: itemURL, configuration: configuration)
        
        // Set the source rect to the cell frame, so surrounding elements are blurred.
        previewingContext.sourceRect = cell.frame
        
        return safariViewController
    }
    
    /// Present the view controller for the "Pop" action.
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        // Reuse the "Peek" view controller for presentation.
        present(viewControllerToCommit, animated: true, completion: nil)
    }
}
