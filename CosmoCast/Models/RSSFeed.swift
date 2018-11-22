//
//  RSSFeed.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 01/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import FeedKit

extension RSSFeed {
    
    func toEpisodes() -> [Episode] {
        let imageUrl = iTunes?.iTunesImage?.attributes?.href
        
        var episodes: [Episode] = []
        items?.forEach({ (feedItem) in
            var episode = Episode(feedItem: feedItem)
            
            if episode.imageUrl == nil {
                episode.imageUrl = imageUrl
            }
            
            episodes.append(episode)
        })
        return episodes
    }
    
}

enum EndPoints {
    static let iTunesSearchURL = "https://itunes.apple.com/search"
    static let iTunesLookupURL = "https://itunes.apple.com/lookup"
    static let topURL = "https://rss.itunes.apple.com/api/v1/us/podcasts/top-podcasts/all/100/explicit.json"
}
