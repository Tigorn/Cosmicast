//
//  DownloadTableViewCell.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 06/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import PINRemoteImage

class EpisodeTableViewCell: UITableViewCell {
    
    var trackNameLabel = UILabel()
    var artistNameLabel = UILabel()
    var dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        trackNameLabel.numberOfLines = 0
        artistNameLabel.numberOfLines = 0
        
        trackNameLabel.textColor = Colours.black
        artistNameLabel.textColor = Colours.black.withAlphaComponent(0.6)
        dateLabel.textColor = Colours.black.withAlphaComponent(0.3)
        
        trackNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        artistNameLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(dateLabel)
        
        let viewsDict = [
            "name" : trackNameLabel,
            "artist" : artistNameLabel,
            "date" : dateLabel,
            ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[date]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[name]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[artist]-|", options: [], metrics: nil, views: viewsDict))
        //contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[image(32)]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[date]-1-[name]-4-[artist]-12-|", options: [], metrics: nil, views: viewsDict))
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
        
    }
    
}
