//
//  EpisodesViewController.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 02/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import StatusAlert
import NVActivityIndicatorView
import OneSignal
import SafariServices
import Disk

class EpisodesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, OSSubscriptionObserver, SFSafariViewControllerDelegate {
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        print("SubscriptionStateChange: \n\(stateChanges)")
    }
    
    var tableView = UITableView()
    var episodes: [Episode] = []
    var ai = NVActivityIndicatorView(frame: CGRect(x:0,y:0,width:0,height:0), type: .circleStrokeSpin, color: Colours.tabSelected)
    var isPeeking = false
    /*
    override var previewActionItems: [UIPreviewActionItem] {
        var bookText = "Subscribe to Podcast".localized
        if StoreStruct.bookmarkedPodcast.contains(StoreStruct.bookmarkedPodcast[index]) {
            bookText = "Remove from Subscriptions".localized
        }
        let action1 = UIPreviewAction(title: "Action One",
                                      style: .default,
                                      handler: { previewAction, viewController in
                                        print("Action One Selected")
        })
        
        let action2 = UIPreviewAction(title: "Action Two",
                                      style: .default,
                                      handler: { previewAction, viewController in
                                        print("Action Two Selected")
        })
        
        return [action1, action2]
    }
    */
    func removeTabbarItemsText() {
        if let items = tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
                item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0);
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadLoadLoad()
        self.title = "Episodes".localized
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadLoadLoad2), name: NSNotification.Name(rawValue: "load"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.nextfrom), name: NSNotification.Name(rawValue: "nextfrom"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.moreTouch), name: NSNotification.Name(rawValue: "more"), object: nil)
        
        self.ai.frame = CGRect(x: self.view.bounds.width/2 - 20, y: self.view.bounds.height/2, width: 40, height: 40)
        
        var tabHeight = Int(UITabBarController().tabBar.frame.size.height) + Int(34)
        var offset = 88
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                offset = 88
            default:
                offset = 64
                tabHeight = Int(UITabBarController().tabBar.frame.size.height)
            }
        }
        
        if self.isPeeking == true {
            offset = 0
        }
        
        let wid = self.view.bounds.width
        let he = self.view.bounds.height
        self.tableView.register(HeaderTableViewCell.self, forCellReuseIdentifier: "cellp")
        self.tableView.register(EpisodeTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.frame = CGRect(x: 0, y: offset, width: Int(wid), height: Int(he) - offset - tabHeight)
        self.tableView.alpha = 1
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .singleLine
        self.tableView.backgroundColor = Colours.white
        self.tableView.separatorColor = Colours.cellQuote
        self.tableView.layer.masksToBounds = true
        self.tableView.estimatedRowHeight = 89
        self.tableView.rowHeight = UITableView.automaticDimension
        self.view.addSubview(self.tableView)
        self.fetchAll()
    }
    
    func fetchAll() {
        if StoreStruct.fromCopy == true {
            FetchContent.shared.fetchCopiedEpisodes() { episodes in
                self.episodes = episodes
                DispatchQueue.main.async {
                    
                    DispatchQueue.main.async {
                        self.ai.alpha = 0
                        self.ai.removeFromSuperview()
                    }
                    self.tableView.reloadData()
                }
            }
            StoreStruct.fromCopy = false
        } else {
        FetchContent.shared.fetchEpisodes(feedUrl: StoreStruct.tappedFeedURL) { episodes in
            self.episodes = episodes
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self.ai.alpha = 0
                    self.ai.removeFromSuperview()
                }
                self.tableView.reloadData()
            }
        }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.removeTabbarItemsText()
        self.ai.startAnimating()
        //self.ai.center = self.view.center
        DispatchQueue.main.async {
            self.view.addSubview(self.ai)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        StoreStruct.whichView = 4
        self.navigationController?.navigationBar.topItem?.title = "Episodes".localized
        self.navigationController?.navigationBar.tintColor = Colours.tabUnselected
        self.navigationController?.navigationBar.barTintColor = Colours.tabUnselected
        self.navigationController?.navigationItem.backBarButtonItem?.tintColor = Colours.tabUnselected
        
        
        do {
            let x = StoreStruct.bookmarkedPodcast
            try Disk.save(x, to: .documents, as: "bookmarked.json")
        } catch {
            print("error")
        }
    }
    
    @objc func loadLoadLoad2() {
        self.loadLoadLoad()
        self.removeTabbarItemsText()
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
            Colours.black = UIColor.black
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
            Colours.black = UIColor.white
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
            Colours.black = UIColor.white
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
        
        self.tableView.backgroundColor = Colours.white
        self.tableView.separatorColor = Colours.cellQuote
        self.tableView.reloadData()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : Colours.grayDark]
    }
    
    @objc func nextfrom() {
        self.goToNextFromPrev()
    }
    
    func goToNextFromPrev() {
        let index = StoreStruct.searchIndex
        let controller = EpisodesViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.episodes.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellp", for: indexPath) as! HeaderTableViewCell
            
            cell.configure(StoreStruct.sendPodcast[0])
            
            cell.trackNameLabel.textColor = Colours.black
            cell.artistNameLabel.textColor = Colours.black.withAlphaComponent(0.6)
            cell.episodes.textColor = Colours.black
            
//            if StoreStruct.sendPodcast[0].contentAdvisoryRating == "Explicit" || StoreStruct.sendPodcast[0].contentAdvisoryRating == "yes" {
//                let redE = UIButton()
//                redE.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
//                redE.setTitle("E", for: .normal)
//                redE.setTitleColor(UIColor.white, for: .normal)
//                redE.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
//                redE.backgroundColor = Colours.red
//                redE.layer.cornerRadius = 5
//                cell.emptyView.addSubview(redE)
//            }
            
            //cell.isUserInteractionEnabled = false
            cell.backgroundColor = Colours.white
            let bgColorView = UIView()
            bgColorView.backgroundColor = Colours.white
            cell.selectedBackgroundView = bgColorView
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EpisodeTableViewCell
            
            cell.configure(episodes[indexPath.row])
            
            cell.trackNameLabel.textColor = Colours.black
            cell.artistNameLabel.textColor = Colours.black.withAlphaComponent(0.6)
            cell.dateLabel.textColor = Colours.black.withAlphaComponent(0.3)
            cell.backgroundColor = Colours.white
            let bgColorView = UIView()
            bgColorView.backgroundColor = Colours.cellQuote
            cell.selectedBackgroundView = bgColorView
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            
        } else {
            Alertift.actionSheet()
                .backgroundColor(Colours.grayDark2)
                .titleTextColor(UIColor.white)
                .messageTextColor(UIColor.white.withAlphaComponent(0.8))
                .messageTextAlignment(.left)
                .titleTextAlignment(.left)
                .action(.default("Play Episode".localized), image: UIImage(named: "play")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.isPlaying = false
                    StoreStruct.isPlayingInitial = false
                    StoreStruct.playEpisode = [self.episodes[indexPath.item]]
                    StoreStruct.playPodcast = [StoreStruct.sendPodcast[0]]
                    StoreStruct.playArtist = StoreStruct.sendPodcast[0].artistName ?? ""
                    StoreStruct.mainImage = StoreStruct.sendPodcast[0].artworkUrl600 ?? ""
                    
                    StoreStruct.playDrawerEpisode = self.episodes
                    StoreStruct.playDrawerPodcast = [StoreStruct.sendPodcast[0]]
                    StoreStruct.playDrawerArtist = StoreStruct.sendPodcast[0].artistName ?? ""
                    StoreStruct.mainDrawerImage = StoreStruct.sendPodcast[0].artworkUrl600 ?? ""
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "switch"), object: self)
                }
                .action(.default("Download and Add to Playlist".localized), image: UIImage(named: "addp")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.downloadEpisode.append(self.episodes[indexPath.item])
                    StoreStruct.downloadPodcast.append(StoreStruct.sendPodcast[0])
                    //StoreStruct.downloadEpisode.insert(self.episodes[indexPath.item], at: 0)
                    //StoreStruct.downloadPodcast.insert(StoreStruct.sendPodcast[0], at: 0)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "switchd"), object: self)
                    
                    OneSignal.promptForPushNotifications(userResponse: { accepted in
                        print("User accepted notifications: \(accepted)")
                    })
                    OneSignal.add(self as OSSubscriptionObserver)
                    
                    let statusAlert = StatusAlert()
                    statusAlert.image = UIImage(named: "down2")?.maskWithColor(color: UIColor.white)
                    statusAlert.title = "Downloading"
                    statusAlert.message = self.episodes[indexPath.item].title
                    //statusAlert.canBePickedOrDismissed = isUserInteractionAllowed
                    statusAlert.show()
                    let impact = UIImpactFeedbackGenerator()
                    impact.impactOccurred()
                }
                .action(.default("Episode Website".localized), image: UIImage(named: "w")) { (action, ind) in
                    print(action, ind)
                    let safariView = SFSafariViewController(url: URL(string: self.episodes[indexPath.item].streamUrl)!)
                    safariView.preferredBarTintColor = Colours.white
                    self.present(safariView, animated: true, completion: nil)
                }/*
                .action(.default("Add to Playlist"), image: UIImage(named: "list")) { (action, ind) in
                    print(action, ind)
                    
                }*/
                .action(.default("Share Episode".localized), image: UIImage(named: "up")) { (action, ind) in
                    print(action, ind)
                    let myWebsite = NSURL(string: self.episodes[indexPath.row].streamUrl)
                    //let myWebsite = self.episodes[indexPath.row].streamUrl
                    let objectsToShare = [myWebsite]
                    let vc = VisualActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    vc.previewNumberOfLines = 5
                    vc.previewFont = UIFont.systemFont(ofSize: 14)
                    self.present(vc, animated: true, completion: nil)
                }
                .action(.cancel("Dismiss".localized))
                .finally { action, index in
                    if action.style == .cancel {
                        return
                    }
                }
                .show(on: self)
        }
    }
    
    @objc func moreTouch() {
        
        var bookText = "Subscribe to Podcast".localized
        if StoreStruct.bookmarkedPodcast.contains(StoreStruct.sendPodcast[0]) {
            bookText = "Remove from Subscriptions".localized
        }
        
        let zz = "episodes by".localized
        let theMessage = "\(StoreStruct.sendPodcast[0].trackCount ?? 0) \(zz) \(StoreStruct.sendPodcast[0].artistName ?? "")"
        Alertift.actionSheet(title: StoreStruct.sendPodcast[0].trackName ?? "", message: theMessage)
            .backgroundColor(Colours.grayDark2)
            .titleTextColor(UIColor.white)
            .messageTextColor(UIColor.white.withAlphaComponent(0.8))
            .messageTextAlignment(.left)
            .titleTextAlignment(.left)
            .action(.default(bookText), image: UIImage(named: "bookmark")) { (action, ind) in
                print(action, ind)
                
                if StoreStruct.bookmarkedPodcast.contains(StoreStruct.sendPodcast[0]) {
                    
                    let statusAlert = StatusAlert()
                    statusAlert.image = UIImage(named: "star")?.maskWithColor(color: UIColor.white)
                    statusAlert.title = "Unsubscribed"
                    statusAlert.message = StoreStruct.sendPodcast[0].trackName ?? ""
                    //statusAlert.canBePickedOrDismissed = isUserInteractionAllowed
                    statusAlert.show()
                    let impact = UIImpactFeedbackGenerator()
                    impact.impactOccurred()
                    
                    StoreStruct.bookmarkedPodcast = StoreStruct.bookmarkedPodcast.filter { $0 != StoreStruct.sendPodcast[0] }
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
                } else {
                    let statusAlert = StatusAlert()
                    statusAlert.image = UIImage(named: "star")?.maskWithColor(color: UIColor.white)
                    statusAlert.title = "Subscribed"
                    statusAlert.message = StoreStruct.sendPodcast[0].trackName ?? ""
                    //statusAlert.canBePickedOrDismissed = isUserInteractionAllowed
                    statusAlert.show()
                    let impact = UIImpactFeedbackGenerator()
                    impact.impactOccurred()
                    
                    StoreStruct.bookmarkedPodcast.append(StoreStruct.sendPodcast[0])
                    StoreStruct.bookmarkedPodcast = StoreStruct.bookmarkedPodcast.removeDuplicates()
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
                }
            }
            .action(.default("More by the Author".localized), image: UIImage(named: "more")) { (action, ind) in
                print(action, ind)
                let artist: String = StoreStruct.sendPodcast[0].artistName ?? ""
                let dict:[String: String] = ["artist": artist]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "searchOpen"), object: self, userInfo: dict)
            }
            .action(.default(" Share Podcast".localized), image: UIImage(named: "up")) { (action, ind) in
                print(action, ind)
                if let myWebsite = NSURL(string: StoreStruct.sendPodcast[0].feedUrl ?? "") {
                //if let myWebsite = StoreStruct.sendPodcast[0].feedUrl {
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
}

