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
    
    var feed: RSSFeed?
    var feedURLString: String = "http://images.apple.com/main/rss/hotnews/hotnews.rss"

    func configureView() {
        // Update the user interface for the detail item.
        
        let feedURL = URL(string: feedURLString)!
        let parser = FeedParser(URL: feedURL) // or FeedParser(data: data)
        parser?.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            // Do your thing, then back to the Main thread
            self.feed = result.rssFeed
            
            DispatchQueue.main.async {
                // ..and update the UI
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Event? {
        didSet {
            feedURLString = (detailItem?.feedURLString)!
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
        switch section {
        case 0: return self.feed?.items?.count ?? 0
        default: fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedItem", for: indexPath)
        
        let item = feed?.items![indexPath.row]
        let label101 = cell.viewWithTag(101) as! UILabel
        label101.text = item?.title
        
        return cell
    }
    
}

// MARK: - Table View Delegate

extension DetailViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = feed?.items![indexPath.row]

        if let itemURL = URL(string: (item?.link)!) {
            
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


