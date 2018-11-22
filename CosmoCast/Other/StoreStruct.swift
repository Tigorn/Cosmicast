//
//  StoreStruct.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 02/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import FeedKit

struct StoreStruct {
    static var whichView = 0
    static var searchIndex = 0
    static var tappedFeedURL = ""
    static var columns = 3
    static var isPlaying = false
    static var isPlayingInitial = false
    static var country: String = Locale.current.regionCode ?? ""
    static var countryFull: String = "Local".localized
    
    static var leftSkip = 15
    static var rightSkip = 15
    static var playbackSpeed: Float = 1
    static var seconds: Float = 0
    static var currentSeconds: Float = 0
    static var upperLab: String = "00:00:00"
    
    static var downloadProgress = 0
    static var downloadedStore : [String: String] = [:]
    static var downloadedStoreUrl : [String] = []
    static var vboost = false
    
    static var fromSearchB = false
    static var rssFeed: RSSFeed!
    static var fromCopy = false
    static var currentPlaylist = 0
    static var endOfEp = false
    
    static var allResults: [Any] = []
    static var networks = ["NPR", "Gimlet", "Vox", "WNYC Studios and The New Yorker", "The New York Times", "BBC World Service", "ABC News", "TED", "ESPN", "Forbes on PodcastOne", "Relay FM", "CNET.com", "Crooked Media", "Goodstuff.FM", "Comedy Central", "The Wall Street Journal", "Wondery", "IGN", "KCRW", "HowStuffWorks", "PodcastOne / Carolla Digital", "QuickAndDirtyTips.com", "5by5", "American Public Media", "Scientific American", "theguardian.com", "BBC Radio 4", "TWiT", "Vanity Fair", "Marvel.com", "Loud Speakers Network", "The Incomparable", "Monocle", "SModcast Network", "Night Vale Presents", "Barstool Sports", "The Economist", "Slate"]
    static var networkImages = ["npr", "gimlet", "vox", "wnyc", "newyork", "bbcworld", "abc", "ted", "espn", "forbes", "relayfm", "cnet", "crooked", "goodstuff", "comcentral", "wsj", "wondery", "ign", "kcrw", "hsw", "podcastone", "qdt", "5by5", "apm", "sciam", "guardian", "bbc4", "twit", "vanity", "marvel", "lsn", "incomparable", "monocle", "smodcast", "vale", "barstool", "econ", "slate"]
    
    static var discoverPodcasts : [Podcast] = []
    static var discoverTopicPodcasts : [Podcast] = []
    static var discoverTopicText: String = "Arts".localized
    static var discoverSearchText: String = "26"
    
    static var sendPodcast : [Podcast] = []
    static var downloadEpisode : [Episode] = []
    static var downloadPodcast : [Podcast] = []
    static var bookmarkedPodcast : [Podcast] = []
    
    static var playEpisode : [Episode] = []
    static var playPodcast : [Podcast] = []
    static var playArtist: String = ""
    static var mainImage = "logo"
    
    static var playDrawerEpisode : [Episode] = []
    static var playDrawerPodcast : [Podcast] = []
    static var playDrawerArtist: String = ""
    static var mainDrawerImage = "logo"
}
