//
//  CustomUISlider.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 05/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class CustomUISlider : UISlider {
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 20))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
//    override func awakeFromNib() {
//        self.setThumbImage(UIImage(named: "customThumb"), for: .normal)
//        super.awakeFromNib()
//    }
}
