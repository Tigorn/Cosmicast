//
//  DiscoverCell.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 10/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class DiscoverCell: UICollectionViewCell {
    
    var image = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Set the cell's imageView's image to nil
        self.image.image = nil
    }
    
    public func configure() {
        
        self.image.frame.origin.x = 0
        self.image.frame.origin.y = 0
        self.image.frame.size.width = contentView.frame.size.width
        self.image.frame.size.height = contentView.frame.size.height
        self.image.backgroundColor = UIColor.clear
        self.image.layer.cornerRadius = 6
        contentView.addSubview(image)
    }
}
