//
//  TopicTableViewCell.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 13/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import PINRemoteImage

class TopicTableViewCell: UITableViewCell {
    
    var trackNameLabel = UILabel()
    var iconImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        trackNameLabel.numberOfLines = 0
        trackNameLabel.textColor = Colours.black
        trackNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(trackNameLabel)
        
        let viewsDict = [
            "image" : iconImageView,
            "name" : trackNameLabel,
            ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(20)]-15-[name]-|", options: [], metrics: nil, views: viewsDict))
        //contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[name]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[image(20)]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[name]-15-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ episode: Episode) {
        
    }
    
}
