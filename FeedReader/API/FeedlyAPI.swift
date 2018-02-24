//
//  FeedlyAPI.swift
//  FeedReader
//
//  Created by ERU on 2018/02/24.
//  Copyright © 2018年 Hacking Gate. All rights reserved.
//

import Foundation

let baseURLString = "https://cloud.feedly.com/v3/"

// Search API
// https://developer.feedly.com/v3/search/

func findFeeds(query: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
    let urlString = baseURLString + "search/feeds"
    sendRequest(urlString, parameters: ["query": query, "count": "20"]) { (responseObject, error) in
        completion(responseObject, error)
    }
}

// GET Request
private func sendRequest(_ url: String, parameters: [String: String], completion: @escaping ([String: Any]?, Error?) -> Void) {
    var components = URLComponents(string: url)!
    components.queryItems = parameters.map { (key, value) in
        URLQueryItem(name: key, value: value)
    }
    components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
    let request = URLRequest(url: components.url!)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data,                            // is there data
            let response = response as? HTTPURLResponse,  // is there HTTP response
            (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
            error == nil else {                           // was there no error, otherwise ...
                completion(nil, error)
                return
        }
        
        let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        completion(responseObject, nil)
    }
    task.resume()
}
