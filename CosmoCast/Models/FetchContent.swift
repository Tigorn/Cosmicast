//
//  FetchContent.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 01/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class FetchContent {
    
    static let shared = FetchContent()
    
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()) {
        guard let url = URL(string: feedUrl) else { return }
        DispatchQueue.global(qos: .background).async {
            print("001")
            print(url)
            let parser = FeedParser(URL: url)
            parser?.parseAsync(result: { (result) in
                print("002")
                
                if let err = result.error {
                    print("Failed to parse XML feed:", err)
                    return
                }
                
                guard let feed = result.rssFeed else { return }
                
                print("003")
                let episodes = feed.toEpisodes()
                completionHandler(episodes)
            })
        }
    }
    
    func fetchCopiedEpisodes(completionHandler: @escaping ([Episode]) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let feed = StoreStruct.rssFeed
            let episodes = feed!.toEpisodes()
            completionHandler(episodes)
        }
    }
    
    func fetchPodcasts(searchText: String, completionHandler: @escaping ([Podcast]) -> ()) {
        let parameters = ["term": searchText, "media": "podcast"]
        Alamofire
            .request(EndPoints.iTunesSearchURL , method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .responseData { (dataResponse) in
                
                if let err = dataResponse.error {
                    print("iTunes search failed", err)
                    return
                }
                
                guard let data = dataResponse.data else { return }
                do {
                    let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                    completionHandler(searchResult.results)
                    
                } catch let decodeErr {
                    print("Failed to decode:", decodeErr)
                }
        }
    }
    
    // Genre
    //https://itunes.apple.com/search?term=podcast&genreId=1303&limit=200
    func fetchGenrePodcasts(searchText: String, country: String, completionHandler: @escaping ([Podcast]) -> ()) {
        let parameters = ["term": "podcast", "genreId": searchText, "limit": "200", "country": country]
        Alamofire
            .request(EndPoints.iTunesSearchURL , method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .responseData { (dataResponse) in
                
                if let err = dataResponse.error {
                    print("iTunes search failed", err)
                    return
                }
                
                guard let data = dataResponse.data else { return }
                do {
                    let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                    completionHandler(searchResult.results)
                    
                } catch let decodeErr {
                    print("Failed to decode:", decodeErr)
                }
        }
    }
    
    func lookupPodcasts(searchText: String, completionHandler: @escaping ([Podcast]) -> ()) {
        let parameters = ["id": searchText, "entity": "podcast"]
        Alamofire
            .request(EndPoints.iTunesLookupURL , method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .responseData { (dataResponse) in
                
                if let err = dataResponse.error {
                    print("iTunes lookup failed", err)
                    return
                }
                
                guard let data = dataResponse.data else { return }
                do {
                    let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                    completionHandler(searchResult.results)
                    
                } catch let decodeErr {
                    print("Failed to decode:", decodeErr)
                }
        }
    }
    
    func fetchTopPodcasts(completionHandler: @escaping (AnyDecodable) -> ()) {
        Alamofire
            .request(EndPoints.topURL , method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .responseData { (dataResponse) in
                
                if let err = dataResponse.error {
                    print("Fetch top podcasts failed", err)
                    return
                }
                
                guard let data = dataResponse.data else { return }
                do {
                    //let searchResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    //completionHandler(searchResult!)
                    
                    let searchResult = try JSONDecoder().decode(AnyDecodable.self, from: data)
                    completionHandler(searchResult)
                    
                } catch let decodeErr {
                    print("Failed to decode:", decodeErr)
                }
        }
    }
}
