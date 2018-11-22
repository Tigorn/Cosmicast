//
//  EpisodeTableViewCell.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 02/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import PINRemoteImage
import OneSignal

class DownloadTableViewCell: UITableViewCell {
    
    var podcastImageView = UIImageView()
    var trackNameLabel = UILabel()
    var artistNameLabel = UILabel()
    var dateLabel = UILabel()
    var percentLabel = UILabel()
    var progress = UIProgressView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        podcastImageView.translatesAutoresizingMaskIntoConstraints = false
        trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        progress.translatesAutoresizingMaskIntoConstraints = false
        
        podcastImageView.layer.cornerRadius = 5
        
        trackNameLabel.numberOfLines = 0
        artistNameLabel.numberOfLines = 0
        
        trackNameLabel.textColor = Colours.black
        artistNameLabel.textColor = Colours.black.withAlphaComponent(0.6)
        dateLabel.textColor = Colours.black.withAlphaComponent(0.3)
        percentLabel.textColor = Colours.tabSelected
        
        trackNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        artistNameLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        percentLabel.font = UIFont.boldSystemFont(ofSize: 12)
        
        progress.trackTintColor = UIColor.gray.withAlphaComponent(0.35)
        //progress.isHidden = true
        
        contentView.addSubview(podcastImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(percentLabel)
        contentView.addSubview(progress)
        
        let viewsDict = [
            "image" : podcastImageView,
            "name" : trackNameLabel,
            "artist" : artistNameLabel,
            "date" : dateLabel,
            "percent" : percentLabel,
            "progress" : progress,
            ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(45)]-12-[date]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(45)]-12-[name]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(45)]-12-[artist]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(45)]-12-[percent]-12-[progress]-20-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[image(45)]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[date]-1-[name]-1-[artist]-4-[percent]-8-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[date]-1-[name]-1-[artist]-10-[progress]-(>=8)-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ episode: Episode) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: episode.pubDate)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "dd-MMM-yyyy"
        let myStringafd = formatter.string(from: yourDate!)
        
        dateLabel.text = myStringafd
        trackNameLabel.text = episode.title
        var sanitise = episode.description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).trimmingCharacters(in: .whitespacesAndNewlines)
        sanitise = sanitise.replacingOccurrences(of: "&#8217;", with: "'")
        sanitise = sanitise.replacingOccurrences(of: "&#8230;", with: "...")
        sanitise = sanitise.replacingOccurrences(of: "&nbsp;", with: " ")
        sanitise = sanitise.replacingOccurrences(of: "&lt;", with: "<")
        sanitise = sanitise.replacingOccurrences(of: "&gt;", with: ">")
        artistNameLabel.text = sanitise
        
        podcastImageView.image = UIImage(named: "logo")
        podcastImageView.layer.masksToBounds = true
        
        /*
        progress.isHidden = true
        percentLabel.text = "Downloaded"
        
        let url = episode.streamUrl
        Digdownload(url)
            .progress({ (progress) in
                let x = Int(progress.fractionCompleted * 100)
                print("\(x)%")
                self.progress.progress = Float(progress.fractionCompleted)
                self.percentLabel.text = "\(x)%"
                self.progress.isHidden = false
                if x == 100 {
                    self.percentLabel.text = "Downloaded"
                    self.progress.isHidden = true
                }
            })
            .completion { (result) in
                
                switch result {
                case .success(let url):
                    print("pathToFile")
                    print(url)
                    self.percentLabel.text = "Downloaded"
                    self.progress.isHidden = true
                    
                    var newName = "\(episode.author)\(episode.title)"
                    newName = newName.replacingOccurrences(of: " ", with: "")
                    StoreStruct.downloadedStore[newName] = url.absoluteString
                    UserDefaults.standard.set(StoreStruct.downloadedStore, forKey: "downloadStore")
                    
                    let playerID = OneSignal.getPermissionSubscriptionState()?.subscriptionStatus.userId
                    OneSignal.postNotification(["headings": ["en": "Episode Downloaded"], "contents": ["en": episode.title], "include_player_ids": [playerID!]])
                    
                case .failure(let error):
                    print(error)
                    self.percentLabel.text = "Downloaded"
                    self.progress.isHidden = true
                }
        }
        */

        
    }
    
}

