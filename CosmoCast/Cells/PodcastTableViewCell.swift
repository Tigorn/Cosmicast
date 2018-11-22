//
//  PodcastTableViewCell.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 01/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import PINRemoteImage

class PodcastTableViewCell: UITableViewCell {
    
    var podcastImageView = UIImageView()
    var trackNameLabel = UILabel()
    var artistNameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        podcastImageView.backgroundColor = UIColor.white
        
        podcastImageView.translatesAutoresizingMaskIntoConstraints = false
        trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        podcastImageView.layer.cornerRadius = 6
        
        trackNameLabel.numberOfLines = 0
        artistNameLabel.numberOfLines = 0
        
        trackNameLabel.textColor = UIColor.white
        artistNameLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        
        trackNameLabel.font = UIFont.systemFont(ofSize: 16)
        artistNameLabel.font = UIFont.systemFont(ofSize: 12)
        
        contentView.addSubview(podcastImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        
        let viewsDict = [
            "image" : podcastImageView,
            "name" : trackNameLabel,
            "artist" : artistNameLabel,
            ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(45)]-13-[name]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(45)]-13-[artist]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[image(45)]-(>=8)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[name]-1-[artist]-(>=8)-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ podcast: Podcast) {
        trackNameLabel.text = podcast.trackName
        artistNameLabel.text = podcast.artistName
        
        guard let secureImageUrl = URL(string: podcast.artworkUrl600 ?? "") else { return }
        podcastImageView.image = UIImage(named: "logo")
        podcastImageView.pin_updateWithProgress = true
        podcastImageView.pin_setImage(from: secureImageUrl)
        podcastImageView.layer.masksToBounds = true
    }
    
}
