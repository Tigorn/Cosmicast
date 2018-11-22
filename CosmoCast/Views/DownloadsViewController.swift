//
//  DownloadsViewController.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 01/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import StatusAlert
import OneSignal

class DownloadsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var missingText = UILabel()
    var missingView = UIImageView()
    var missingButton = UIButton()
    var tableView = UITableView()
    var isLoadedMiss = false
    
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
        self.title = "Playlist".localized
        
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
        self.tableView.register(DownloadTableViewCell.self, forCellReuseIdentifier: "cell")
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
        
        DiggerManager.shared.maxConcurrentTasksCount = 4
        DiggerManager.shared.allowsCellularAccess = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.removeTabbarItemsText()
        self.tableView.reloadData()
        
//        let z = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
//        print(z.absoluteString)
//        DiggerCache.ururur = z.absoluteString
        
        
        if StoreStruct.downloadEpisode.isEmpty {
            if self.isLoadedMiss == false {
                self.isLoadedMiss = true
            self.missingView.frame = CGRect(x: self.view.bounds.width/2 - 140, y: self.view.bounds.height/2 - 180, width: 280, height: 280)
            self.missingView.image = UIImage(named: "missing")?.maskWithColor(color: Colours.tabUnselected)
            self.missingView.backgroundColor = Colours.clear
            self.view.addSubview(self.missingView)
            
            self.missingText.frame = CGRect(x: self.view.bounds.width/2 - 140, y: (self.view.bounds.height/4)*3 - 15, width: 280, height: 50)
            self.missingText.text = "Episodes you download and add to your playlist will appear here".localized
            self.missingText.textColor = UIColor.gray.withAlphaComponent(0.55)
            self.missingText.font = UIFont.systemFont(ofSize: 13)
            self.missingText.numberOfLines = 0
            self.missingText.textAlignment = .center
            self.view.addSubview(self.missingText)
            
            self.missingButton.frame = CGRect(x: self.view.bounds.width/2 - 90, y: (self.view.bounds.height/4)*3 + 55, width: 180, height: 50)
            self.missingButton.setTitle("Discover Podcasts".localized, for: .normal)
            self.missingButton.setTitleColor(UIColor.white, for: .normal)
            self.missingButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
                self.missingButton.backgroundColor = Colours.tabSelected
                self.missingButton.layer.cornerRadius = 16
                if (UserDefaults.standard.object(forKey: "theme") == nil || UserDefaults.standard.object(forKey: "theme") as! Int == 0) {
                    self.missingButton.layer.shadowColor = Colours.tabSelected.cgColor
                } else {
                    self.missingButton.layer.shadowColor = UIColor.black.cgColor
                }
            self.missingButton.layer.cornerRadius = 16
            self.missingButton.addTarget(self, action: #selector(self.touchDiscover), for: .touchUpInside)
            self.missingButton.layer.shadowColor = Colours.tabSelected.cgColor
            self.missingButton.layer.shadowOffset = CGSize(width:0, height:9)
            self.missingButton.layer.shadowRadius = 16
            self.missingButton.layer.shadowOpacity = 0.6
            self.view.addSubview(self.missingButton)
            }
            self.missingView.alpha = 1
            self.missingText.alpha = 1
            self.missingButton.alpha = 1
            self.tableView.alpha = 0
        } else {
            self.missingView.alpha = 0
            self.missingText.alpha = 0
            self.missingButton.alpha = 0
            self.tableView.alpha = 1
        }
        
    }
    
    @objc func touchDiscover() {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "switchdisc"), object: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        StoreStruct.whichView = 2
        self.navigationController?.navigationBar.topItem?.title = "Playlist".localized
        self.navigationController?.navigationBar.tintColor = Colours.tabUnselected
        self.navigationController?.navigationBar.barTintColor = Colours.tabUnselected
        self.navigationController?.navigationItem.backBarButtonItem?.tintColor = Colours.tabUnselected
        
        if StoreStruct.playEpisode.isEmpty {} else {
        if StoreStruct.downloadEpisode.count > 1 && StoreStruct.currentPlaylist + 1 < StoreStruct.downloadEpisode.count {
            let shortcutItem1 = UIApplicationShortcutItem(type: "Dynamic02", localizedTitle: "Play Next".localized, localizedSubtitle: StoreStruct.downloadEpisode[StoreStruct.currentPlaylist + 1].title ?? "", icon: UIApplicationShortcutIcon(templateImageName: "listn"), userInfo: nil)
            if StoreStruct.isPlaying {
                let shortcutItem2 = UIApplicationShortcutItem(type: "Dynamic01", localizedTitle: "Pause".localized, localizedSubtitle: StoreStruct.playEpisode[0].title ?? "", icon: UIApplicationShortcutIcon(templateImageName: "pause"), userInfo: nil)
                UIApplication.shared.shortcutItems = [shortcutItem1,shortcutItem2]
            } else {
                let shortcutItem2 = UIApplicationShortcutItem(type: "Dynamic01", localizedTitle: "Play".localized, localizedSubtitle: StoreStruct.playEpisode[0].title ?? "", icon: UIApplicationShortcutIcon(templateImageName: "play"), userInfo: nil)
                UIApplication.shared.shortcutItems = [shortcutItem1,shortcutItem2]
            }
        } else {
            if StoreStruct.isPlaying {
                let shortcutItem2 = UIApplicationShortcutItem(type: "Dynamic01", localizedTitle: "Pause".localized, localizedSubtitle: StoreStruct.playEpisode[0].title ?? "", icon: UIApplicationShortcutIcon(templateImageName: "pause"), userInfo: nil)
                UIApplication.shared.shortcutItems = [shortcutItem2]
            } else {
                if StoreStruct.playEpisode.isEmpty {} else {
                    let shortcutItem2 = UIApplicationShortcutItem(type: "Dynamic01", localizedTitle: "Play".localized, localizedSubtitle: StoreStruct.playEpisode[0].title ?? "", icon: UIApplicationShortcutIcon(templateImageName: "play"), userInfo: nil)
                    UIApplication.shared.shortcutItems = [shortcutItem2]
                }
            }
        }
        }
        
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
        
        if (UserDefaults.standard.object(forKey: "theme") == nil || UserDefaults.standard.object(forKey: "theme") as! Int == 0) {
            self.missingButton.layer.shadowColor = Colours.tabSelected.cgColor
        } else {
            self.missingButton.layer.shadowColor = UIColor.black.cgColor
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
        
        self.missingView.image = UIImage(named: "missing")?.maskWithColor(color: Colours.tabUnselected)
        
        self.tableView.backgroundColor = Colours.white
        self.tableView.separatorColor = Colours.cellQuote
        self.tableView.reloadData()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : Colours.grayDark]
        self.removeTabbarItemsText()
    }
    
    
    
    func goToNextFromPrev() {
        let index = StoreStruct.searchIndex
        let controller = EpisodesViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StoreStruct.downloadEpisode.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DownloadTableViewCell
        
        cell.configure(StoreStruct.downloadEpisode[indexPath.row])
        
        let secureImageUrl = URL(string: StoreStruct.downloadPodcast[indexPath.row].artworkUrl600 ?? "")!
        cell.podcastImageView.image = UIImage(named: "logo")
        cell.podcastImageView.pin_updateWithProgress = true
        cell.podcastImageView.pin_setImage(from: secureImageUrl)
        cell.podcastImageView.layer.masksToBounds = true
        
        //cell.percentLabel.text = "\(StoreStruct.downloadProgress)%"
        
        cell.progress.isHidden = true
        cell.percentLabel.text = " "
        
        let url1 = StoreStruct.downloadEpisode[indexPath.row].streamUrl
        
        
        
        StoreStruct.downloadedStoreUrl = UserDefaults.standard.value(forKey: "downloadStoreURL") as? [String] ?? [""]
        if StoreStruct.downloadedStoreUrl.contains(url1) {} else {
        
        
        Digdownload(url1)
            .progress({ (progress) in
                let x = Int(progress.fractionCompleted * 100)
                print("\(x)%")
                cell.progress.progress = Float(progress.fractionCompleted)
                cell.percentLabel.text = "\(x)%"
                cell.progress.isHidden = false
                if x == 100 {
                    cell.percentLabel.text = "Downloaded".localized
                    cell.progress.isHidden = true
                }
            })
            .completion { (result) in
                
                switch result {
                case .success(let url):
                    print("pathToFile")
                    print(url)
                    cell.percentLabel.text = "Downloaded".localized
                    cell.progress.isHidden = true
                    
                    
                    StoreStruct.downloadedStoreUrl.append(url1)
                    UserDefaults.standard.set(StoreStruct.downloadedStoreUrl, forKey: "downloadStoreURL")
                    
                    var newName = "\(StoreStruct.downloadEpisode[indexPath.row].author)\(StoreStruct.downloadEpisode[indexPath.row].title)"
                    newName = newName.replacingOccurrences(of: " ", with: "")
                    StoreStruct.downloadedStore[newName] = url.absoluteString
                    UserDefaults.standard.set(StoreStruct.downloadedStore, forKey: "downloadStore")
                    
                    let playerID = OneSignal.getPermissionSubscriptionState()?.subscriptionStatus.userId
                    OneSignal.postNotification(["headings": ["en": "Episode Downloaded".localized], "contents": ["en": StoreStruct.downloadEpisode[indexPath.row].title], "include_player_ids": [playerID!]])
                    
                case .failure(let error):
                    print(error)
                    cell.percentLabel.text = "Downloaded".localized
                    cell.progress.isHidden = true
                }
        }
            
        }
        
        
        cell.trackNameLabel.textColor = Colours.black
        cell.artistNameLabel.textColor = Colours.black.withAlphaComponent(0.6)
        cell.dateLabel.textColor = Colours.black.withAlphaComponent(0.3)
        cell.backgroundColor = Colours.white
        let bgColorView = UIView()
        bgColorView.backgroundColor = Colours.cellQuote
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let rm = "Remove from Playlist".localized
        let se = "Share Episode".localized
        
        Alertift.actionSheet()
            .backgroundColor(Colours.grayDark2)
            .titleTextColor(UIColor.white)
            .messageTextColor(UIColor.white.withAlphaComponent(0.8))
            .messageTextAlignment(.left)
            .titleTextAlignment(.left)
            .action(.default("Play Episode".localized), image: UIImage(named: "play")) { (action, ind) in
                print(action, ind)
                StoreStruct.currentPlaylist = indexPath.row
                StoreStruct.isPlaying = false
                StoreStruct.isPlayingInitial = false
                StoreStruct.playEpisode = [StoreStruct.downloadEpisode[indexPath.row]]
                StoreStruct.playPodcast = [StoreStruct.downloadPodcast[indexPath.row]]
                StoreStruct.playArtist = StoreStruct.downloadPodcast[indexPath.row].artistName ?? ""
                StoreStruct.mainImage = StoreStruct.downloadPodcast[indexPath.row].artworkUrl600 ?? ""
                
                StoreStruct.playDrawerEpisode = StoreStruct.downloadEpisode
                StoreStruct.playDrawerPodcast = [StoreStruct.downloadPodcast[indexPath.row]]
                StoreStruct.playDrawerArtist = StoreStruct.downloadPodcast[indexPath.row].artistName ?? ""
                StoreStruct.mainDrawerImage = StoreStruct.downloadPodcast[indexPath.row].artworkUrl600 ?? ""
                NotificationCenter.default.post(name: Notification.Name(rawValue: "switch"), object: self)
            }
            .action(.default(" \(rm)"), image: UIImage(named: "cross")) { (action, ind) in
                print(action, ind)
                
                let statusAlert = StatusAlert()
                statusAlert.image = UIImage(named: "cross2")?.maskWithColor(color: UIColor.white)
                statusAlert.title = "Removed"
                statusAlert.message = StoreStruct.downloadEpisode[indexPath.row].title
                //statusAlert.canBePickedOrDismissed = isUserInteractionAllowed
                statusAlert.show()
                let impact = UIImpactFeedbackGenerator()
                impact.impactOccurred()
                
                DiggerManager.shared.stopTask(for: StoreStruct.downloadEpisode[indexPath.row].streamUrl)
                StoreStruct.downloadEpisode.remove(at: indexPath.row)
                StoreStruct.downloadPodcast.remove(at: indexPath.row)
                if StoreStruct.downloadEpisode.isEmpty {
                    self.missingView.alpha = 1
                    self.missingText.alpha = 1
                    self.missingButton.alpha = 1
                    self.tableView.alpha = 0
                } else {
                    self.missingView.alpha = 0
                    self.missingText.alpha = 0
                    self.missingButton.alpha = 0
                    self.tableView.alpha = 1
                }
                self.tableView.reloadData()
            }/*
            .action(.default("Add to Playlist"), image: UIImage(named: "list")) { (action, ind) in
                print(action, ind)
                
            }*/
            .action(.default(" \(se)"), image: UIImage(named: "up")) { (action, ind) in
                print(action, ind)
                let myWebsite = NSURL(string: StoreStruct.downloadEpisode[indexPath.row].streamUrl)
                //let myWebsite = StoreStruct.downloadEpisode[indexPath.row].streamUrl
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

