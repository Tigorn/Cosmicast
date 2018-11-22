//
//  DiscoverTableViewCell.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 13/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import PINRemoteImage

class DiscoverTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    var stype: [Podcast] = []
    var stext = "26"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let layout = ColumnFlowLayout(
            cellsPerRow: 4,
            minimumInteritemSpacing: 6,
            minimumLineSpacing: 6,
            sectionInset: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        )
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(UIScreen.main.bounds.width)/4), collectionViewLayout: layout)
        collectionView.backgroundColor = Colours.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(DiscoverCell.self, forCellWithReuseIdentifier: "Cell")
        
        contentView.addSubview(collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ type: Int) {
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StoreStruct.discoverPodcasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DiscoverCell
        
        if StoreStruct.discoverPodcasts.isEmpty {} else {
            cell.configure()
            let z = StoreStruct.discoverPodcasts[indexPath.item].artworkUrl600 ?? ""
            let secureImageUrl = URL(string: z)!
            cell.image.pin_clearImages()
            cell.image.pin_setPlaceholder(with: UIImage(named: "logo"))
            cell.image.pin_updateWithProgress = true
            cell.image.pin_setImage(from: secureImageUrl)
            cell.layer.cornerRadius = 6
            cell.image.layer.cornerRadius = 6
            cell.image.layer.masksToBounds = true
            
            cell.image.frame.size.width = cell.frame.size.width
            cell.image.frame.size.height = cell.frame.size.height
        }
        
        cell.backgroundColor = Colours.clear
        
        let longHold = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        longHold.minimumPressDuration = 0.4
        cell.tag = indexPath.item
        cell.addGestureRecognizer(longHold)
        
        return cell
    }
    
    @objc func longPressed(gesture: UILongPressGestureRecognizer) {
        let dict:[String: Int] = ["artist": gesture.view?.tag ?? 0]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "longhh"), object: self, userInfo: dict)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
        
        StoreStruct.tappedFeedURL = StoreStruct.discoverPodcasts[indexPath.row].feedUrl ?? ""
        StoreStruct.sendPodcast = [StoreStruct.discoverPodcasts[indexPath.row]]
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "nextfrom"), object: self)
    }
    
}

