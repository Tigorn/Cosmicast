//
//  Podcast.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 01/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation

class Podcast: NSObject, Encodable, Decodable, NSCoding, NSItemProviderWriting {
    
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
    var primaryGenreName: String?
    var contentAdvisoryRating: String?
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(trackName ?? "", forKey: "trackNameKey")
        aCoder.encode(artistName ?? "", forKey: "artistNameKey")
        aCoder.encode(artworkUrl600 ?? "", forKey: "artworkKey")
        aCoder.encode(feedUrl ?? "", forKey: "feedKey")
        aCoder.encode(primaryGenreName ?? "", forKey: "primaryGenreName")
        aCoder.encode(contentAdvisoryRating ?? "", forKey: "contentAdvisoryRating")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.trackName = aDecoder.decodeObject(forKey: "trackNameKey") as? String
        self.artistName = aDecoder.decodeObject(forKey: "artistNameKey") as? String
        self.artworkUrl600 = aDecoder.decodeObject(forKey: "artworkKey") as? String
        self.feedUrl = aDecoder.decodeObject(forKey: "feedKey") as? String
        self.primaryGenreName = aDecoder.decodeObject(forKey: "primaryGenreName") as? String
        self.contentAdvisoryRating = aDecoder.decodeObject(forKey: "contentAdvisoryRating") as? String
    }
    
    init(track: String?, artist: String?, artwork: String?, count: Int?, feedURL: String?, genre: String?, rating: String?) {
        trackName = track
        artistName = artist
        artworkUrl600 = artwork
        trackCount = count
        feedUrl = feedURL
        primaryGenreName = genre
        contentAdvisoryRating = rating
    }
    
    public static var writableTypeIdentifiersForItemProvider: [String] {
        return [] // something here
    }
    
    public func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Swift.Void) -> Progress? {
        return nil // something here
    }
}

struct SearchResults: Decodable {
    let resultCount: Int
    let results: [Podcast]
}
