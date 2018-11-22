//
//  PodcastsViewController.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 01/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import StatusAlert
import SafariServices
import Disk

class PodcastsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SFSafariViewControllerDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UIViewControllerPreviewingDelegate {
    
    var missingText = UILabel()
    var missingView = UIImageView()
    var missingButton = UIButton()
    var collectionView: UICollectionView!
    var colcol = 3
    let volumeBar = VolumeBar.shared
    var isLoadedMiss = false
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.collectionView.indexPathForItem(at: location) else { return nil }
        guard let cell = self.collectionView.cellForItem(at: indexPath) else { return nil }
        
        StoreStruct.searchIndex = indexPath.item
        StoreStruct.tappedFeedURL = StoreStruct.bookmarkedPodcast[indexPath.item].feedUrl ?? ""
        StoreStruct.sendPodcast = [StoreStruct.bookmarkedPodcast[indexPath.item]]
        let detailVC = EpisodesViewController()
        detailVC.isPeeking = true
        previewingContext.sourceRect = cell.frame
        return detailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = StoreStruct.bookmarkedPodcast[indexPath.row]
        let itemProvider = NSItemProvider(object: item)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    /*func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let item = StoreStruct.bookmarkedPodcast[indexPath.row]
        let itemProvider = NSItemProvider(object: item)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }*/
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if session.localDragSession != nil {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of collection view.
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        switch coordinator.proposal.operation {
        case .move:
            //Add the code to reorder items
            self.reorderItems(coordinator: coordinator, destinationIndexPath:destinationIndexPath, collectionView: collectionView)
            break
        default:
            return
        }
    }
    
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView)
    {
        let items = coordinator.items
        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath
        {
            var dIndexPath = destinationIndexPath
            if dIndexPath.row >= collectionView.numberOfItems(inSection: 0) {
                dIndexPath.row = collectionView.numberOfItems(inSection: 0) - 1
            }
            
            print("source---")
            print(sourceIndexPath)
            print("destination---")
            print(dIndexPath)
            
            collectionView.performBatchUpdates({
                StoreStruct.bookmarkedPodcast.remove(at: sourceIndexPath.row)
                collectionView.deleteItems(at: [sourceIndexPath])
                StoreStruct.bookmarkedPodcast.insert(item.dragItem.localObject as! Podcast, at: dIndexPath.row)
                collectionView.insertItems(at: [dIndexPath])
                //collectionView.reloadData()
            })
            coordinator.drop(items.first!.dragItem, toItemAt: dIndexPath)
        }
        
        do {
            let x = StoreStruct.bookmarkedPodcast
            try Disk.save(x, to: .documents, as: "bookmarked.json")
        } catch {
            print("error")
        }
    }
    
    func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
        var arr = array
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)
        
        return arr
    }
    
    func removeTabbarItemsText() {
        if let items = tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
                item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0);
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.removeTabbarItemsText()
        
        //self.collectionView.reloadData()
        
        if StoreStruct.bookmarkedPodcast.isEmpty {
            if self.isLoadedMiss == false {
                self.isLoadedMiss = true
            self.missingView.frame = CGRect(x: self.view.bounds.width/2 - 140, y: self.view.bounds.height/2 - 180, width: 280, height: 280)
            self.missingView.image = UIImage(named: "missing")?.maskWithColor(color: Colours.tabUnselected)
            self.missingView.backgroundColor = Colours.clear
            self.view.addSubview(self.missingView)
            
            //self.missingText.frame = CGRect(x: self.view.bounds.width/2 - 140, y: (self.view.bounds.height/4)*3 - 25, width: 280, height: 50)
            self.missingText.frame = CGRect(x: self.view.bounds.width/2 - 140, y: (self.view.bounds.height/4)*3 - 45, width: 280, height: 90)
            //self.missingText.text = "Episodes you download will appear here"
            self.missingText.text = "Subscribed podcasts will appear here\n\nVisit the Discover section or search for podcasts to add them here".localized
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
            self.missingButton.addTarget(self, action: #selector(self.touchDiscover), for: .touchUpInside)
                if (UserDefaults.standard.object(forKey: "theme") == nil || UserDefaults.standard.object(forKey: "theme") as! Int == 0) {
                    self.missingButton.layer.shadowColor = Colours.tabSelected.cgColor
                } else {
                    self.missingButton.layer.shadowColor = UIColor.black.cgColor
                }
            self.missingButton.layer.shadowOffset = CGSize(width:0, height:9)
            self.missingButton.layer.shadowRadius = 16
            self.missingButton.layer.shadowOpacity = 0.6
            self.view.addSubview(self.missingButton)
            }
            self.missingView.alpha = 1
            self.missingText.alpha = 1
            self.missingButton.alpha = 1
            self.collectionView.alpha = 0
        } else {
            self.missingView.alpha = 0
            self.missingText.alpha = 0
            self.missingButton.alpha = 0
            self.collectionView.alpha = 1
        }
    }
    
    @objc func touchDiscover() {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "switchdisc"), object: self)
    }
    
    @objc func columnLoad() {
        if StoreStruct.bookmarkedPodcast.isEmpty {
            self.missingView.alpha = 1
            self.missingText.alpha = 1
            self.missingButton.alpha = 1
            self.collectionView.alpha = 0
        } else {
            self.missingView.alpha = 0
            self.missingText.alpha = 0
            self.missingButton.alpha = 0
            self.collectionView.alpha = 1
        }
        let layout = ColumnFlowLayout(
            cellsPerRow: StoreStruct.columns,
            minimumInteritemSpacing: 5,
            minimumLineSpacing: 5,
            sectionInset: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        )
        //self.collectionView.collectionViewLayout = layout
        self.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Podcasts".localized
        NotificationCenter.default.addObserver(self, selector: #selector(self.columnLoad), name: NSNotification.Name(rawValue: "column"), object: nil)
        
        if UserDefaults.standard.object(forKey: "gridCol") == nil {
            colcol = 3
            StoreStruct.columns = colcol
        } else {
            colcol = UserDefaults.standard.object(forKey: "gridCol") as! Int
            StoreStruct.columns = colcol
        }
        
        var customStyle = VolumeBarStyle.likeInstagram
        customStyle.trackTintColor = Colours.cellQuote
        customStyle.progressTintColor = Colours.grayDark
        customStyle.backgroundColor = Colours.cellNorm
        volumeBar.style = customStyle
        volumeBar.start()
        volumeBar.showInitial()
        
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
        self.collectionView = UICollectionView(frame: CGRect(x: CGFloat(0), y: CGFloat(offset), width: CGFloat(wid), height: CGFloat(he) - CGFloat(offset) - CGFloat(tabHeight)), collectionViewLayout: layout)
        self.collectionView.backgroundColor = Colours.white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(HomeCell.self, forCellWithReuseIdentifier: "Cell")
        self.view.addSubview(self.collectionView)
        
        self.collectionView.dragDelegate = self
        self.collectionView.dropDelegate = self
        self.collectionView.dragInteractionEnabled = true
        
        if (traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: self.collectionView)
        }
        
        self.loadLoadLoad()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StoreStruct.bookmarkedPodcast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let x = StoreStruct.columns
        let y = self.view.bounds.width
        let z = CGFloat(y)/CGFloat(x)
        return CGSize(width: z - 7.5, height: z - 7.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HomeCell
        if StoreStruct.bookmarkedPodcast.isEmpty {} else {
            cell.configure(StoreStruct.bookmarkedPodcast[indexPath.row])
            
            cell.image.image = nil
            let secureImageUrl = URL(string: StoreStruct.bookmarkedPodcast[indexPath.row].artworkUrl600 ?? "")!
            cell.image.pin_setPlaceholder(with: UIImage(named: "logo"))
            cell.image.pin_updateWithProgress = true
            cell.image.pin_setImage(from: secureImageUrl)
            cell.layer.cornerRadius = 6
            cell.image.layer.cornerRadius = 6
            cell.image.layer.masksToBounds = true
            
        }
        
        cell.image.frame.size.width = cell.frame.size.width
        cell.image.frame.size.height = cell.frame.size.height
        cell.backgroundColor = Colours.clear
        /*
        let longHold = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        longHold.minimumPressDuration = 0.4
        cell.tag = indexPath.row
        cell.addGestureRecognizer(longHold)
        */
        return cell
    }
    
    @objc func longPressed(gesture: UILongPressGestureRecognizer) {
        let index = gesture.view?.tag ?? 0
        var bookText = "Subscribe to Podcast".localized
        if StoreStruct.bookmarkedPodcast.contains(StoreStruct.bookmarkedPodcast[index]) {
            bookText = "Remove from Subscriptions".localized
        }
        let zz = "episodes by".localized
        let se = "Share Podcast".localized
        let theMessage = "\(StoreStruct.bookmarkedPodcast[index].trackCount ?? 0) \(zz) \(StoreStruct.bookmarkedPodcast[index].artistName ?? "")"
        Alertift.actionSheet(title: StoreStruct.bookmarkedPodcast[index].trackName ?? "", message: theMessage)
            .backgroundColor(Colours.grayDark2)
            .titleTextColor(UIColor.white)
            .messageTextColor(UIColor.white.withAlphaComponent(0.8))
            .messageTextAlignment(.left)
            .titleTextAlignment(.left)
            .action(.default(bookText), image: UIImage(named: "bookmark")) { (action, ind) in
                print(action, ind)
                
                if StoreStruct.bookmarkedPodcast.contains(StoreStruct.bookmarkedPodcast[index]) {
                    
                    let statusAlert = StatusAlert()
                    statusAlert.image = UIImage(named: "star")?.maskWithColor(color: UIColor.white)
                    statusAlert.title = "Unsubscribed"
                    statusAlert.message = StoreStruct.bookmarkedPodcast[index].trackName ?? ""
                    //statusAlert.canBePickedOrDismissed = isUserInteractionAllowed
                    statusAlert.show()
                    let impact = UIImpactFeedbackGenerator()
                    impact.impactOccurred()
                    
                    StoreStruct.bookmarkedPodcast = StoreStruct.bookmarkedPodcast.filter { $0 != StoreStruct.bookmarkedPodcast[index] }
                    self.collectionView.reloadData()
                } else {
                    
                    let statusAlert = StatusAlert()
                    statusAlert.image = UIImage(named: "star")?.maskWithColor(color: UIColor.white)
                    statusAlert.title = "Subscribed"
                    statusAlert.message = StoreStruct.bookmarkedPodcast[index].trackName ?? ""
                    //statusAlert.canBePickedOrDismissed = isUserInteractionAllowed
                    statusAlert.show()
                    let impact = UIImpactFeedbackGenerator()
                    impact.impactOccurred()
                    
                    StoreStruct.bookmarkedPodcast.append(StoreStruct.bookmarkedPodcast[index])
                    StoreStruct.bookmarkedPodcast = StoreStruct.bookmarkedPodcast.removeDuplicates()
                }
                
                if StoreStruct.bookmarkedPodcast.isEmpty {
                    self.missingView.alpha = 1
                    self.missingText.alpha = 1
                    self.missingButton.alpha = 1
                    self.collectionView.alpha = 0
                } else {
                    self.missingView.alpha = 0
                    self.missingText.alpha = 0
                    self.missingButton.alpha = 0
                    self.collectionView.alpha = 1
                }
            }
            .action(.default("More by the Author".localized), image: UIImage(named: "more")) { (action, ind) in
                print(action, ind)
                let artist: String = StoreStruct.bookmarkedPodcast[index].artistName ?? ""
                let dict:[String: String] = ["artist": artist]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "searchOpen"), object: self, userInfo: dict)
            }
            .action(.default(" \(se)"), image: UIImage(named: "up")) { (action, ind) in
                print(action, ind)
                if let myWebsite = NSURL(string: StoreStruct.bookmarkedPodcast[index].feedUrl ?? "") {
                //if let myWebsite = StoreStruct.bookmarkedPodcast[index].feedUrl {
                    let objectsToShare = [myWebsite]
                    let vc = VisualActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    vc.previewNumberOfLines = 5
                    vc.previewFont = UIFont.systemFont(ofSize: 14)
                    self.present(vc, animated: true, completion: nil)
                }
            }
            .action(.cancel("Dismiss"))
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
        
        StoreStruct.searchIndex = indexPath.item
        StoreStruct.tappedFeedURL = StoreStruct.bookmarkedPodcast[indexPath.item].feedUrl ?? ""
        StoreStruct.sendPodcast = [StoreStruct.bookmarkedPodcast[indexPath.item]]
        self.goToNextFromPrev()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        StoreStruct.whichView = 0
        self.navigationController?.navigationBar.topItem?.title = "Podcasts".localized
        self.navigationController?.navigationBar.tintColor = Colours.tabUnselected
        self.navigationController?.navigationBar.barTintColor = Colours.tabUnselected
        self.navigationController?.navigationItem.backBarButtonItem?.tintColor = Colours.tabUnselected
        self.removeTabbarItemsText()
        
        
        
        
        
        // FETCH DISCOVER STUFF
        /*
        FetchContent.shared.fetchGenrePodcasts(searchText: "26") { podcasts in
            StoreStruct.discoverPodcasts = podcasts
            NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
        }
        
        
        FetchContent.shared.fetchGenrePodcasts(searchText: "1301") { podcasts in
            StoreStruct.artsPodcasts = podcasts
            NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
        }
        FetchContent.shared.fetchGenrePodcasts(searchText: "1321") { podcasts in
            StoreStruct.businessPodcasts = podcasts
            NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
        }
        FetchContent.shared.fetchGenrePodcasts(searchText: "1303") { podcasts in
            StoreStruct.comedyPodcasts = podcasts
            NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
        }*/
        
        
        /*
        FetchContent.shared.fetchTopPodcasts() { podcasts in
            print("p-:")
            let z = (podcasts.value as! [String: Any])
            let z1 = (z["feed"] as! [String: Any])
            let z2 = (z1["results"] as! [Any])
            StoreStruct.allResults = z2
            NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
            
            let z3 = (z2[0] as! [String: Any])
            print(z3)
        }
        */
        
        
        
        
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
        var customStyle = VolumeBarStyle.likeInstagram
        customStyle.trackTintColor = Colours.cellQuote
        customStyle.progressTintColor = Colours.grayDark
        customStyle.backgroundColor = Colours.cellNorm
        volumeBar.style = customStyle
        volumeBar.start()
        
        self.missingView.image = UIImage(named: "missing")?.maskWithColor(color: Colours.tabUnselected)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : Colours.grayDark]
        self.collectionView.backgroundColor = Colours.white
        self.removeTabbarItemsText()
    }
    
    
    func goToNextFromPrev() {
        print("nbnbnb")
        let index = StoreStruct.searchIndex
        let controller = EpisodesViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension PodcastsViewController: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return URL.init(string: "https://itunes.apple.com/app/id1170886809")!
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "ScreenSort for iOS: https://itunes.apple.com/app/id1170886809"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
        return nil
    }
}
