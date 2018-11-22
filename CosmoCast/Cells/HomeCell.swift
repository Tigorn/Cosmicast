//
//  HomeCell.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 02/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class HomeCell: UICollectionViewCell {
    
    var image = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(_ podcast: Podcast) {
        
        self.image.frame.origin.x = 0
        self.image.frame.origin.y = 0
        self.image.frame.size.width = contentView.frame.size.width
        self.image.frame.size.height = contentView.frame.size.height
        self.image.backgroundColor = UIColor.clear
        
        image.layer.cornerRadius = 6
        contentView.addSubview(image)
    }
}
