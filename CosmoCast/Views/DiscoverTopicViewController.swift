//
//  DiscoverTopicViewController.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 13/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import StatusAlert
import SafariServices
import NVActivityIndicatorView

class DiscoverTopicViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SFSafariViewControllerDelegate, UIViewControllerPreviewingDelegate {
    
    var collectionView: UICollectionView!
    var colcol = 3
    var ai = NVActivityIndicatorView(frame: CGRect(x:0,y:0,width:0,height:0), type: .circleStrokeSpin, color: Colours.tabSelected)
    var isPeeking = false
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.collectionView.indexPathForItem(at: location) else { return nil }
        guard let cell = self.collectionView.cellForItem(at: indexPath) else { return nil }
        
        StoreStruct.tappedFeedURL = StoreStruct.discoverTopicPodcasts[indexPath.item].feedUrl ?? ""
        StoreStruct.sendPodcast = [StoreStruct.discoverTopicPodcasts[indexPath.item]]
        let detailVC = EpisodesViewController()
        detailVC.isPeeking = true
        previewingContext.sourceRect = cell.frame
        return detailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    func removeTabbarItemsText() {
        if let items = tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
                item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0);
            }
        }
    }
    
    @objc func columnLoad() {
        let layout = ColumnFlowLayout(
            cellsPerRow: StoreStruct.columns,
            minimumInteritemSpacing: 5,
            minimumLineSpacing: 5,
            sectionInset: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        )
        self.collectionView.collectionViewLayout = layout
        self.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ai.frame = CGRect(x: self.view.bounds.width/2 - 20, y: self.view.bounds.height/2, width: 40, height: 40)
        self.ai.startAnimating()
        DispatchQueue.main.async {
            self.view.addSubview(self.ai)
        }
        StoreStruct.discoverTopicPodcasts = []
        FetchContent.shared.fetchGenrePodcasts(searchText: StoreStruct.discoverSearchText, country: StoreStruct.country) { podcasts in
            StoreStruct.discoverTopicPodcasts = podcasts
            DispatchQueue.main.async {
                self.ai.alpha = 0
                self.ai.removeFromSuperview()
            }
            self.collectionView.reloadData()
        }
        
        self.title = StoreStruct.discoverTopicText
        NotificationCenter.default.addObserver(self, selector: #selector(self.columnLoad), name: NSNotification.Name(rawValue: "column"), object: nil)
        
        if UserDefaults.standard.object(forKey: "gridCol") == nil {
            colcol = 3
        } else {
            colcol = UserDefaults.standard.object(forKey: "gridCol") as! Int
        }
        
        var tabHeight = Int(UITabBarController().tabBar.frame.size.height) + Int(34)
        var offset = 88
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688:
                offset = 88
            case 2436:
                offset = 88
            default:
                offset = 64
                tabHeight = Int(UITabBarController().tabBar.frame.size.height)
            }
        }
        
        let wid = self.view.bounds.width
        let he = self.view.bounds.height
        
        let layout = ColumnFlowLayout(
            cellsPerRow: colcol,
            minimumInteritemSpacing: 5,
            minimumLineSpacing: 5,
            sectionInset: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        )
        if self.isPeeking == true {
            offset = 5
        }
        self.collectionView = UICollectionView(frame: CGRect(x: 0, y: offset, width: Int(wid), height: Int(he) - offset - tabHeight), collectionViewLayout: layout)
        self.collectionView.backgroundColor = Colours.white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(DiscoverCell.self, forCellWithReuseIdentifier: "Cell")
        self.view.addSubview(self.collectionView)
        
        if (traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: self.collectionView)
        }
        
        self.loadLoadLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.removeTabbarItemsText()
        self.collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        StoreStruct.whichView = 1
        self.navigationController?.navigationBar.topItem?.title = StoreStruct.discoverTopicText
        self.navigationController?.navigationBar.tintColor = Colours.tabUnselected
        self.navigationController?.navigationBar.barTintColor = Colours.tabUnselected
        self.navigationController?.navigationItem.backBarButtonItem?.tintColor = Colours.tabUnselected
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let x = StoreStruct.columns
        let y = self.view.bounds.width
        let z = CGFloat(y)/CGFloat(x)
        return CGSize(width: z - 7.5, height: z - 7.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StoreStruct.discoverTopicPodcasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DiscoverCell
        if StoreStruct.discoverTopicPodcasts.isEmpty {} else {
            cell.configure()
            let z = StoreStruct.discoverTopicPodcasts[indexPath.item].artworkUrl600 ?? ""
            let secureImageUrl = URL(string: z)!
            cell.image.image = UIImage(named: "logo")
            cell.image.pin_updateWithProgress = true
            cell.image.pin_setImage(from: secureImageUrl)
            cell.image.layer.masksToBounds = true
        }
        
        
        cell.image.frame.size.width = cell.frame.size.width
        cell.image.frame.size.height = cell.frame.size.height
        cell.backgroundColor = Colours.clear
        let longHold = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        longHold.minimumPressDuration = 0.4
        cell.tag = indexPath.item
        cell.addGestureRecognizer(longHold)
        return cell
    }
    
    @objc func longPressed(gesture: UILongPressGestureRecognizer) {
        let index = gesture.view?.tag ?? 0
        var bookText = "Subscribe to Podcast".localized
        
        let s1: Bool = (StoreStruct.bookmarkedPodcast as [Podcast]).contains(where: { ($0 as Podcast).feedUrl as! String == (StoreStruct.discoverTopicPodcasts[index] as Podcast).feedUrl as! String })
        
        if s1 {
            bookText = "Remove from Subscriptions".localized
        }
        let zz = "episodes by".localized
        let se = "Share Podcast".localized
        let theMessage = "\(StoreStruct.discoverTopicPodcasts[index].trackCount ?? 0) \(zz) \(StoreStruct.discoverTopicPodcasts[index].artistName ?? "")"
        Alertift.actionSheet(title: StoreStruct.discoverTopicPodcasts[index].trackName ?? "", message: theMessage)
            .backgroundColor(Colours.grayDark2)
            .titleTextColor(UIColor.white)
            .messageTextColor(UIColor.white.withAlphaComponent(0.8))
            .messageTextAlignment(.left)
            .titleTextAlignment(.left)
            .action(.default(bookText), image: UIImage(named: "bookmark")) { (action, ind) in
                print(action, ind)
                
                if s1 {
                    let statusAlert = StatusAlert()
                    statusAlert.image = UIImage(named: "star")?.maskWithColor(color: UIColor.white)
                    statusAlert.title = "Unsubscribed"
                    statusAlert.message = StoreStruct.discoverTopicPodcasts[index].trackName ?? ""
                    //statusAlert.canBePickedOrDismissed = isUserInteractionAllowed
                    statusAlert.show()
                    let impact = UIImpactFeedbackGenerator()
                    impact.impactOccurred()
                    
                    StoreStruct.bookmarkedPodcast = StoreStruct.bookmarkedPodcast.filter { ($0 as Podcast).feedUrl as! String != (StoreStruct.discoverTopicPodcasts[index] as Podcast).feedUrl as! String }
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
                } else {
                    let statusAlert = StatusAlert()
                    statusAlert.image = UIImage(named: "star")?.maskWithColor(color: UIColor.white)
                    statusAlert.title = "Subscribed"
                    statusAlert.message = StoreStruct.discoverTopicPodcasts[index].trackName ?? ""
                    //statusAlert.canBePickedOrDismissed = isUserInteractionAllowed
                    statusAlert.show()
                    let impact = UIImpactFeedbackGenerator()
                    impact.impactOccurred()
                    
                    StoreStruct.bookmarkedPodcast.append(StoreStruct.discoverTopicPodcasts[index])
                    StoreStruct.bookmarkedPodcast = StoreStruct.bookmarkedPodcast.removeDuplicates()
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
                }
            }
            .action(.default("More by the Author".localized), image: UIImage(named: "more")) { (action, ind) in
                print(action, ind)
                let artist: String = StoreStruct.discoverTopicPodcasts[index].artistName ?? ""
                let dict:[String: String] = ["artist": artist]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "searchOpen"), object: self, userInfo: dict)
            }
            .action(.default(" \(se)"), image: UIImage(named: "up")) { (action, ind) in
                print(action, ind)
                if let myWebsite = NSURL(string: StoreStruct.discoverTopicPodcasts[index].feedUrl ?? "") {
                //if let myWebsite = StoreStruct.discoverTopicPodcasts[index].feedUrl {
                    let objectsToShare = [myWebsite]
                    let vc = VisualActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    vc.previewNumberOfLines = 5
                    vc.previewFont = UIFont.systemFont(ofSize: 14)
                    self.present(vc, animated: true, completion: nil)
                }
            }
            .action(.cancel("Dismiss".localized))
            .finally { action, index in
                if action.style == .cancel {
                    return
                }
            }
            .show(on: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
        
        StoreStruct.tappedFeedURL = StoreStruct.discoverTopicPodcasts[indexPath.item].feedUrl ?? ""
        StoreStruct.sendPodcast = [StoreStruct.discoverTopicPodcasts[indexPath.item]]
        let controller = EpisodesViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
    func loadLoadLoad() {
        if (UserDefaults.standard.object(forKey: "theme") == nil || UserDefaults.standard.object(forKey: "theme") as! Int == 0) {
            Colours.white = UIColor.white
            Colours.grayDark = UIColor(red: 40/250, green: 40/250, blue: 40/250, alpha: 1.0)
            Colours.cellNorm = Colours.white
            Colours.cellQuote = UIColor(red: 243/255.0, green: 242/255.0, blue: 246/255.0, alpha: 1.0)
            Colours.cellSelected = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            Colours.tabUnselected = UIColor(red: 225/255.0, green: 225/255.0, blue: 225/255.0, alpha: 1.0)
            Colours.blackUsual = UIColor(red: 40/255.0, green: 40/255.0, blue: 40/255.0, alpha: 1.0)
            Colours.cellOwn = UIColor(red: 243/255.0, green: 242/255.0, blue: 246/255.0, alpha: 1.0)
            Colours.cellAlternative = UIColor(red: 243/255.0, green: 242/255.0, blue: 246/255.0, alpha: 1.0)
        } else if (UserDefaults.standard.object(forKey: "theme") != nil && UserDefaults.standard.object(forKey: "theme") as! Int == 1) {
            Colours.white = UIColor(red: 53/255.0, green: 53/255.0, blue: 64/255.0, alpha: 1.0)
            Colours.grayDark = UIColor(red: 250/250, green: 250/250, blue: 250/250, alpha: 1.0)
            Colours.cellNorm = Colours.white
            Colours.cellQuote = UIColor(red: 33/255.0, green: 33/255.0, blue: 43/255.0, alpha: 1.0)
            Colours.cellSelected = UIColor(red: 34/255.0, green: 34/255.0, blue: 44/255.0, alpha: 1.0)
            Colours.tabUnselected = UIColor(red: 80/255.0, green: 80/255.0, blue: 90/255.0, alpha: 1.0)
            Colours.blackUsual = UIColor(red: 70/255.0, green: 70/255.0, blue: 80/255.0, alpha: 1.0)
            Colours.cellOwn = UIColor(red: 55/255.0, green: 55/255.0, blue: 65/255.0, alpha: 1.0)
            Colours.cellAlternative = UIColor(red: 20/255.0, green: 20/255.0, blue: 30/255.0, alpha: 1.0)
        } else {
            Colours.white = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
            Colours.grayDark = UIColor(red: 250/250, green: 250/250, blue: 250/250, alpha: 1.0)
            Colours.cellNorm = Colours.white
            Colours.cellQuote = UIColor(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 1.0)
            Colours.cellSelected = UIColor(red: 34/255.0, green: 34/255.0, blue: 44/255.0, alpha: 1.0)
            Colours.tabUnselected = UIColor(red: 70/255.0, green: 70/255.0, blue: 80/255.0, alpha: 1.0)
            Colours.blackUsual = UIColor(red: 70/255.0, green: 70/255.0, blue: 80/255.0, alpha: 1.0)
            Colours.cellOwn = UIColor(red: 10/255.0, green: 10/255.0, blue: 20/255.0, alpha: 1.0)
            Colours.cellAlternative = UIColor(red: 20/255.0, green: 20/255.0, blue: 30/255.0, alpha: 1.0)
        }
        
        self.view.backgroundColor = Colours.white
        
        if (UserDefaults.standard.object(forKey: "systemText") == nil) || (UserDefaults.standard.object(forKey: "systemText") as! Int == 0) {
            if (UserDefaults.standard.object(forKey: "fontSize") == nil) {
                Colours.fontSize0 = 14
                Colours.fontSize2 = 10
                Colours.fontSize1 = 14
                Colours.fontSize3 = 10
            } else if (UserDefaults.standard.object(forKey: "fontSize") as! Int == 0) {
                Colours.fontSize0 = 12
                Colours.fontSize2 = 8
                Colours.fontSize1 = 12
                Colours.fontSize3 = 8
            } else if (UserDefaults.standard.object(forKey: "fontSize") != nil && UserDefaults.standard.object(forKey: "fontSize") as! Int == 1) {
                Colours.fontSize0 = 13
                Colours.fontSize2 = 9
                Colours.fontSize1 = 13
                Colours.fontSize3 = 9
            } else if (UserDefaults.standard.object(forKey: "fontSize") != nil && UserDefaults.standard.object(forKey: "fontSize") as! Int == 2) {
                Colours.fontSize0 = 14
                Colours.fontSize2 = 10
                Colours.fontSize1 = 14
                Colours.fontSize3 = 10
            } else if (UserDefaults.standard.object(forKey: "fontSize") != nil && UserDefaults.standard.object(forKey: "fontSize") as! Int == 3) {
                Colours.fontSize0 = 15
                Colours.fontSize2 = 11
                Colours.fontSize1 = 15
                Colours.fontSize3 = 11
            } else if (UserDefaults.standard.object(forKey: "fontSize") != nil && UserDefaults.standard.object(forKey: "fontSize") as! Int == 4) {
                Colours.fontSize0 = 16
                Colours.fontSize2 = 12
                Colours.fontSize1 = 16
                Colours.fontSize3 = 12
            } else if (UserDefaults.standard.object(forKey: "fontSize") != nil && UserDefaults.standard.object(forKey: "fontSize") as! Int == 5) {
                Colours.fontSize0 = 17
                Colours.fontSize2 = 13
                Colours.fontSize1 = 17
                Colours.fontSize3 = 13
            } else {
                Colours.fontSize0 = 18
                Colours.fontSize2 = 14
                Colours.fontSize1 = 18
                Colours.fontSize3 = 14
            }
        } else {
            Colours.fontSize1 = CGFloat(UIFont.systemFontSize)
            Colours.fontSize3 = CGFloat(UIFont.systemFontSize)
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : Colours.grayDark]
        self.collectionView.backgroundColor = Colours.white
        self.removeTabbarItemsText()
    }
    
    
    
    
    func goToNextFromPrev() {
        let index = StoreStruct.searchIndex
        let controller = EpisodesViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
