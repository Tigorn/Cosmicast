//
//  DiscoverViewController.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 01/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import StatusAlert
import SafariServices

class DiscoverViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate, UIViewControllerPreviewingDelegate {
    
    var tableView = UITableView()
    var collectionView: UICollectionView!
    var colcol = 3
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRow(at: location) else { return nil }
        //guard let indexPath = self.tableView.indexPathForRow(at: self.view.convert(location, to: tableView)) else { return nil }
        guard let cell = self.tableView.cellForRow(at: indexPath) else { return nil }
        if indexPath.section == 2 {
            StoreStruct.discoverSearchText = topicIDs[indexPath.row]
            StoreStruct.discoverTopicText = self.topics[indexPath.row]
            let detailVC = DiscoverTopicViewController()
            detailVC.isPeeking = true
            previewingContext.sourceRect = cell.frame
            return detailVC
        } else {
            return nil
        }
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
            minimumInteritemSpacing: 0,
            minimumLineSpacing: 0,
            sectionInset: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        )
        self.collectionView.collectionViewLayout = layout
        self.collectionView.reloadData()
    }
    
    @objc func longhh(notification: NSNotification) {
        if let artist = notification.userInfo?["artist"] as? Int {
            self.longPressed(num: artist)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Discover".localized
        NotificationCenter.default.addObserver(self, selector: #selector(self.nextFrom), name: NSNotification.Name(rawValue: "nextfrom"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.columnLoad), name: NSNotification.Name(rawValue: "column"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.longhh), name: NSNotification.Name(rawValue: "longhh"), object: nil)
        
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
            minimumInteritemSpacing: 0,
            minimumLineSpacing: 0,
            sectionInset: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        )
        self.collectionView = UICollectionView(frame: CGRect(x: 0, y: offset, width: Int(wid), height: Int(he) - offset - tabHeight), collectionViewLayout: layout)
        self.collectionView.backgroundColor = Colours.white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(DiscoverCell.self, forCellWithReuseIdentifier: "Cell")
        //self.view.addSubview(self.collectionView)
        
        self.tableView.register(DiscoverTableViewCell.self, forCellReuseIdentifier: "cellp")
        self.tableView.register(NetworkTableViewCell.self, forCellReuseIdentifier: "celln")
        self.tableView.register(TopicTableViewCell.self, forCellReuseIdentifier: "celld")
        self.tableView.register(TopicTableViewCell.self, forCellReuseIdentifier: "cellg")
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
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 25))
        customView.backgroundColor = Colours.white
        self.tableView.tableFooterView = customView
        
        if (traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: self.tableView)
        }
        
        self.loadLoadLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.removeTabbarItemsText()
        self.collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        StoreStruct.whichView = 1
        self.navigationController?.navigationBar.topItem?.title = "Discover".localized
        self.navigationController?.navigationBar.tintColor = Colours.tabUnselected
        self.navigationController?.navigationBar.barTintColor = Colours.tabUnselected
        self.navigationController?.navigationItem.backBarButtonItem?.tintColor = Colours.tabUnselected
        
        
        /*
         // MOVE THIS TO EPISODES - PASS IN ID FROM DISCOVER TAB ITEM BEING PICKED
         FetchContent.shared.lookupPodcasts(searchText: "260190086") { podcasts in
         FetchContent.shared.fetchEpisodes(feedUrl: podcasts[0].feedUrl ?? "") { episodes in
         print("lookupepisode:")
         print(episodes)
         }
         }*/
        
        
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
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StoreStruct.discoverPodcasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DiscoverCell
        if StoreStruct.discoverPodcasts.isEmpty {} else {
            cell.configure()
        }
        
        let z = StoreStruct.discoverPodcasts[indexPath.item].artworkUrl600 ?? ""
        let secureImageUrl = URL(string: z)!
        cell.image.pin_setPlaceholder(with: UIImage(named: "logo"))
        //cell.image.image = UIImage(named: "logo")
        //cell.image.pin_updateWithProgress = true
        cell.image.pin_setImage(from: secureImageUrl)
        cell.image.layer.masksToBounds = true
        
        cell.image.frame.size.width = cell.frame.size.width
        cell.image.frame.size.height = cell.frame.size.height
        cell.backgroundColor = Colours.clear
        /*let longHold = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        longHold.minimumPressDuration = 0.4
        cell.tag = indexPath.item
        cell.addGestureRecognizer(longHold)*/
        return cell
    }
    
    func longPressed(num: Int) {
        let index = num
        var bookText = "Subscribe to Podcast".localized
        
        let s1: Bool = (StoreStruct.bookmarkedPodcast as [Podcast]).contains(where: { ($0 as Podcast).feedUrl as! String == (StoreStruct.discoverPodcasts[index] as Podcast).feedUrl as! String })
        
        if s1 {
            bookText = "Remove from Subscriptions".localized
        }
        let zz = "episodes by".localized
        let se = "Share Podcast".localized
        let theMessage = "\(StoreStruct.discoverPodcasts[index].trackCount ?? 0) \(zz) \(StoreStruct.discoverPodcasts[index].artistName ?? "")"
        Alertift.actionSheet(title: StoreStruct.discoverPodcasts[index].trackName ?? "", message: theMessage)
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
                    statusAlert.message = StoreStruct.discoverPodcasts[index].trackName ?? ""
                    //statusAlert.canBePickedOrDismissed = isUserInteractionAllowed
                    statusAlert.show()
                    let impact = UIImpactFeedbackGenerator()
                    impact.impactOccurred()
                    
                    StoreStruct.bookmarkedPodcast = StoreStruct.bookmarkedPodcast.filter { ($0 as Podcast).feedUrl as! String != (StoreStruct.discoverPodcasts[index] as Podcast).feedUrl as! String }
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
                } else {
                    let statusAlert = StatusAlert()
                    statusAlert.image = UIImage(named: "star")?.maskWithColor(color: UIColor.white)
                    statusAlert.title = "Subscribed"
                    statusAlert.message = StoreStruct.discoverPodcasts[index].trackName ?? ""
                    //statusAlert.canBePickedOrDismissed = isUserInteractionAllowed
                    statusAlert.show()
                    let impact = UIImpactFeedbackGenerator()
                    impact.impactOccurred()
                    
                    StoreStruct.bookmarkedPodcast.append(StoreStruct.discoverPodcasts[index])
                    StoreStruct.bookmarkedPodcast = StoreStruct.bookmarkedPodcast.removeDuplicates()
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
                }
            }
            .action(.default("More by the Author".localized), image: UIImage(named: "more")) { (action, ind) in
                print(action, ind)
                let artist: String = StoreStruct.discoverPodcasts[index].artistName ?? ""
                let dict:[String: String] = ["artist": artist]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "searchOpen"), object: self, userInfo: dict)
            }
            .action(.default(" \(se)"), image: UIImage(named: "up")) { (action, ind) in
                print(action, ind)
                if let myWebsite = NSURL(string: StoreStruct.discoverPodcasts[index].feedUrl ?? "") {
                //if let myWebsite = StoreStruct.discoverPodcasts[index].feedUrl {
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
        
        StoreStruct.tappedFeedURL = StoreStruct.discoverPodcasts[indexPath.item].feedUrl ?? ""
        StoreStruct.sendPodcast = [StoreStruct.discoverPodcasts[indexPath.item]]
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
        self.tableView.backgroundColor = Colours.white
        self.tableView.separatorColor = Colours.cellQuote
        
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
        customView.backgroundColor = Colours.white
        self.tableView.tableFooterView = customView
        
        self.tableView.reloadData()
        self.removeTabbarItemsText()
    }
    
    
    @objc func nextFrom() {
        self.goToNextFromPrev()
    }
    
    func goToNextFromPrev() {
        let index = StoreStruct.searchIndex
        let controller = EpisodesViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60)
        let title = UILabel()
        title.frame = CGRect(x: 15, y: 20, width: self.view.bounds.width, height: 40)
        if section == 0 {
            title.text = "TOP PODCASTS".localized
        } else if section == 1 {
            title.text = "CURATED NETWORKS".localized
        } else if section == 2 {
            title.text = "TOPICS".localized
        } else if section == 3 {
            title.text = "REGION".localized
        } else {
            title.text = "OTHER".localized
        }
        title.textColor = UIColor.gray
        title.font = UIFont.boldSystemFont(ofSize: 12)
        vw.addSubview(title)
        vw.backgroundColor = Colours.white
        
        return vw
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return 16
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return CGFloat((self.view.bounds.width)/4)
        } else if indexPath.section == 1 {
            return CGFloat((self.view.bounds.width)/4)
        } else {
            return UITableView.automaticDimension
        }
    }
    
    var topics = ["Arts".localized, "Business".localized, "Comedy".localized, "Education".localized, "Games & Hobbies".localized, "Government & Organisations".localized, "Health".localized, "Kids & Family".localized, "Music".localized, "News & Politics".localized, "Religion & Spirituality".localized, "Science & Medicine".localized, "Society & Culture".localized, "Sports & Recreation".localized, "Technology".localized, "TV & Film".localized]
    var topicIDs = ["1301", "1321", "1303", "1304", "1323", "1325", "1307", "1305", "1310", "1311", "1314", "1315", "1324", "1316", "1318", "1309"]
    var topicIcons = ["art", "business", "comedy", "edu", "game", "govern", "health", "kids", "music", "news", "pray", "science", "society", "ball", "tech", "tv"]
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellp", for: indexPath) as! DiscoverTableViewCell
            
            cell.backgroundColor = Colours.white
            let bgColorView = UIView()
            bgColorView.backgroundColor = Colours.white
            cell.selectedBackgroundView = bgColorView
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "celln", for: indexPath) as! NetworkTableViewCell
            
            cell.backgroundColor = Colours.white
            let bgColorView = UIView()
            bgColorView.backgroundColor = Colours.white
            cell.selectedBackgroundView = bgColorView
            
            return cell
            
        } else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "celld", for: indexPath) as! TopicTableViewCell
            
            cell.trackNameLabel.text = topics[indexPath.row]
            cell.trackNameLabel.textColor = Colours.black
            
            //let secureImageUrl = URL(string: StoreStruct.downloadPodcast[indexPath.row].artworkUrl600 ?? "")!
            cell.iconImageView.image = UIImage(named: self.topicIcons[indexPath.row])?.maskWithColor(color: Colours.tabUnselected)
            cell.iconImageView.layer.masksToBounds = true
            
            cell.backgroundColor = Colours.white
            let bgColorView = UIView()
            bgColorView.backgroundColor = Colours.cellQuote
            cell.selectedBackgroundView = bgColorView
            
            return cell
            
        } else if indexPath.section == 3 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellg", for: indexPath) as! TopicTableViewCell
            
            cell.trackNameLabel.text = StoreStruct.countryFull
            cell.trackNameLabel.textColor = Colours.black
            
            cell.iconImageView.image = UIImage(named: "flag")?.maskWithColor(color: Colours.tabUnselected)
            cell.iconImageView.layer.masksToBounds = true
            
            cell.backgroundColor = Colours.white
            let bgColorView = UIView()
            bgColorView.backgroundColor = Colours.cellQuote
            cell.selectedBackgroundView = bgColorView
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellg", for: indexPath) as! TopicTableViewCell
            
            cell.trackNameLabel.text = "Export Subscribed Podcasts".localized
            cell.trackNameLabel.textColor = Colours.black
            
            cell.iconImageView.image = UIImage(named: "up2")?.maskWithColor(color: Colours.tabUnselected)
            cell.iconImageView.layer.masksToBounds = true
            
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
        if indexPath.section == 0 || indexPath.section == 1 {
            
        } else if indexPath.section == 2 {
            StoreStruct.discoverSearchText = topicIDs[indexPath.row]
            StoreStruct.discoverTopicText = self.topics[indexPath.row]
            let controller = DiscoverTopicViewController()
            self.navigationController?.pushViewController(controller, animated: true)
            
        }  else if indexPath.section == 3 {
            Alertift.actionSheet()
                .backgroundColor(Colours.grayDark2)
                .titleTextColor(UIColor.white)
                .messageTextColor(UIColor.white.withAlphaComponent(0.8))
                .messageTextAlignment(.left)
                .titleTextAlignment(.left)
                .action(.default("All".localized)) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = ""
                    StoreStruct.countryFull = "All".localized
                    self.updateTop()
                }
                .action(.default("Local".localized)) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = Locale.current.regionCode ?? ""
                    StoreStruct.countryFull = "Local".localized
                    self.updateTop()
                }
                .action(.default("Australia")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "AU"
                    StoreStruct.countryFull = "Australia"
                    self.updateTop()
                }
                .action(.default("Belgium")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "BE"
                    StoreStruct.countryFull = "Belgium"
                    self.updateTop()
                }
                .action(.default("Brazil")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "BR"
                    StoreStruct.countryFull = "Brazil"
                    self.updateTop()
                }
                .action(.default("Canada")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "CA"
                    StoreStruct.countryFull = "Canada"
                    self.updateTop()
                }
                .action(.default("China")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "CN"
                    StoreStruct.countryFull = "China"
                    self.updateTop()
                }
                .action(.default("Denmark")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "DK"
                    StoreStruct.countryFull = "Denmark"
                    self.updateTop()
                }
                .action(.default("France")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "FR"
                    StoreStruct.countryFull = "France"
                    self.updateTop()
                }
                .action(.default("Germany")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "DE"
                    StoreStruct.countryFull = "Germany"
                    self.updateTop()
                }
                .action(.default("Ireland")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "IE"
                    StoreStruct.countryFull = "Ireland"
                    self.updateTop()
                }
                .action(.default("Italy")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "IT"
                    StoreStruct.countryFull = "Italy"
                    self.updateTop()
                }
                .action(.default("Japan")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "JP"
                    StoreStruct.countryFull = "Japan"
                    self.updateTop()
                }
                .action(.default("Netherlands")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "NL"
                    StoreStruct.countryFull = "Netherlands"
                    self.updateTop()
                }
                .action(.default("Norway")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "NO"
                    StoreStruct.countryFull = "Norway"
                    self.updateTop()
                }
                .action(.default("Poland")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "PL"
                    StoreStruct.countryFull = "Poland"
                    self.updateTop()
                }
                .action(.default("Russia")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "RU"
                    StoreStruct.countryFull = "Russia"
                    self.updateTop()
                }
                .action(.default("South Korea")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "KR"
                    StoreStruct.countryFull = "South Korea"
                    self.updateTop()
                }
                .action(.default("Spain")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "ES"
                    StoreStruct.countryFull = "Spain"
                    self.updateTop()
                }
                .action(.default("Sweden")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "SE"
                    StoreStruct.countryFull = "Sweden"
                    self.updateTop()
                }
                .action(.default("Switzerland")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "CH"
                    StoreStruct.countryFull = "Switzerland"
                    self.updateTop()
                }
                .action(.default("United Kingdom")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "UK"
                    StoreStruct.countryFull = "United Kingdom"
                    self.updateTop()
                }
                .action(.default("United States")) { (action, ind) in
                    print(action, ind)
                    StoreStruct.country = "US"
                    StoreStruct.countryFull = "United States"
                    self.updateTop()
                }
                .action(.cancel("Dismiss".localized))
                .finally { action, index in
                    if action.style == .cancel {
                        return
                    }
                }
                .show(on: self)
            
        } else {
        let fileName = "podcasts.opml"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        var opmlText = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<opml version=\"1.0\">\n<head>\n<title>Cosmicast Podcast Feeds</title>\n</head>\n<body>\n<outline text=\"feeds\">\n"
        for x in StoreStruct.bookmarkedPodcast {
            let newLine = "<outline type=\"rss\" text=\"\(x.trackName ?? "")\" xmlUrl=\"\(x.feedUrl ?? "")\" />\n"
            opmlText.append(contentsOf: newLine)
        }
        let newLine = "</outline>\n</body>\n</opml>\n"
        opmlText.append(contentsOf: newLine)
        
        do {
            try opmlText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        
        let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
        self.present(vc, animated: true, completion: nil)
        }
    }
    
    func updateTop() {
        StoreStruct.discoverPodcasts = []
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellp", for: IndexPath(row: 0, section: 0)) as! DiscoverTableViewCell
        cell.configure(0)
        self.tableView.reloadData()
        FetchContent.shared.fetchGenrePodcasts(searchText: "26", country: StoreStruct.country) { podcasts in
            StoreStruct.discoverPodcasts = podcasts
            cell.configure(0)
            self.tableView.reloadData()
        }
    }
}
