//
//  HeaderTableViewCell.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 02/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import PINRemoteImage

class HeaderTableViewCell: UITableViewCell {
    
    var podcastImageView = UIImageView()
    var trackNameLabel = UILabel()
    var artistNameLabel = UILabel()
    var episodes = UILabel()
    var moreButton = MNGExpandedTouchAreaButton()
    var emptyView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        podcastImageView.backgroundColor = UIColor.white
        
        podcastImageView.translatesAutoresizingMaskIntoConstraints = false
        trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        episodes.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        
        podcastImageView.layer.cornerRadius = 8
        
        trackNameLabel.numberOfLines = 0
        artistNameLabel.numberOfLines = 0
        episodes.numberOfLines = 0
        
        trackNameLabel.textColor = Colours.black
        artistNameLabel.textColor = Colours.black.withAlphaComponent(0.6)
        episodes.textColor = Colours.black
        
        trackNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        artistNameLabel.font = UIFont.systemFont(ofSize: 12)
        episodes.font = UIFont.boldSystemFont(ofSize: 12)
        
        moreButton.layer.cornerRadius = 15
        moreButton.backgroundColor = Colours.clear
        moreButton.setImage(UIImage(named: "more")?.maskWithColor(color: UIColor.gray), for: .normal)
        moreButton.addTarget(self, action: #selector(self.touchMore), for: .touchUpInside)
        
        emptyView.backgroundColor = Colours.clear
        emptyView.layer.cornerRadius = 5
        
        contentView.addSubview(podcastImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(episodes)
        contentView.addSubview(moreButton)
        contentView.addSubview(emptyView)
        
        let viewsDict = [
            "image" : podcastImageView,
            "name" : trackNameLabel,
            "artist" : artistNameLabel,
            "episodes" : episodes,
            "moreButton" : moreButton,
            "emptyView" : emptyView,
            ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[emptyView(20)]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(100)]-13-[name]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(100)]-13-[artist]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(100)]-13-[episodes]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(100)]-13-[moreButton(30)]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[emptyView(20)]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[image(100)]-(>=20)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[name]-5-[artist]-5-[episodes]-5-[moreButton(30)]-(>=20)-|", options: [], metrics: nil, views: viewsDict))
    }
    
    @objc func touchMore(button: UIButton) {
        print("touched more")
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "more"), object: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ podcast: Podcast) {
        if podcast.contentAdvisoryRating == "Explicit" || podcast.contentAdvisoryRating == "yes" {
            self.trackNameLabel.text = "🅴 \(podcast.trackName ?? "")"
        } else {
            self.trackNameLabel.text = podcast.trackName
        }
        artistNameLabel.text = podcast.artistName
        let genre = podcast.primaryGenreName ?? ""
        let epi = "episodes".localized
        if genre == "" {
            episodes.text = "\(podcast.trackCount ?? 0) \(epi)"
        } else {
            episodes.text = "\(genre) • \(podcast.trackCount ?? 0) \(epi)"
        }
        
        guard let secureImageUrl = URL(string: podcast.artworkUrl600 ?? "") else { return }
        podcastImageView.image = UIImage(named: "logo")
        podcastImageView.pin_updateWithProgress = true
        podcastImageView.pin_setImage(from: secureImageUrl)
        podcastImageView.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.emptyView.backgroundColor = Colours.clear
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.emptyView.backgroundColor = Colours.clear
        }
    }
    
}

