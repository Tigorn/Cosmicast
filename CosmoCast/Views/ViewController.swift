//
//  ViewController.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 01/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import UIKit
import Alamofire
import FeedKit
import MediaPlayer
import Intents

class ViewController: UITabBarController, UITabBarControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    var tabOne = SloppyNavigationController()
    var tabTwo = SloppyNavigationController()
    var tabThree = SloppyNavigationController()
    var tabFour = SloppyNavigationController()
    
    var firstView = PodcastsViewController()
    var secondView = DiscoverViewController()
    var thirdView = DownloadsViewController()
    var fourthView = PlayerViewController()
    
    var statusBarView = UIView()
    var backgroundView = UIButton()
    var bgView = UIView()
    var settingsButton = MNGExpandedTouchAreaButton()
    var searchButton = MNGExpandedTouchAreaButton()
    var switcherView = UIView()
    var searcherView = UIView()
    var searchTextField = UITextField()
    
    var option1 = UIButton()
    var option2 = UIButton()
    var option3 = UIButton()
    var option4 = UIButton()
    var option5 = UIButton()
    var option6 = UIButton()
    
    var circlebg = UIView()
    var circleArrow = UIImageView()
    var circle1 = MNGExpandedTouchAreaButton()
    var circle2 = MNGExpandedTouchAreaButton()
    var circle3 = MNGExpandedTouchAreaButton()
    var circle4 = MNGExpandedTouchAreaButton()
    var circle5 = MNGExpandedTouchAreaButton()
    var circle6 = MNGExpandedTouchAreaButton()
    
    var podcasts: [Podcast] = []
    var tableView = UITableView()
    var drawerTableView = UITableView()
    
    var selectedOption = 1
    var hideStatusBar = false
    
    var screenshotLabel = UILabel()
    var screenshot = UIImage()
    var identity = CGAffineTransform.identity
    let view0pinch = UIView()
    let view1pinch = UIImageView()
    var doOnce = true
    var doOncePinch = true
    var doOnceScreen = true
    
    var playButton = UIButton()
    var titleLab = MarqueeLabel()
    var forwardSkip = UIButton()
    var backwardSkip = UIButton()
    var lowerLab = UILabel()
    var upperLab = UILabel()
    var slider = CustomUISlider()
    var mainImageView = UIImageView()
    var timer: Timer? = nil
    
    func siriShort() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "toPlay"), object: self, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "switch"), object: self)
    }
    
    func siriLight() {
        UIApplication.shared.statusBarStyle = .default
        Colours.keyCol = UIKeyboardAppearance.dark
        UserDefaults.standard.set(0, forKey: "theme")
        self.genericStuff()
    }
    
    func siriDark() {
        UIApplication.shared.statusBarStyle = .lightContent
        Colours.keyCol = UIKeyboardAppearance.dark
        UserDefaults.standard.set(1, forKey: "theme")
        self.genericStuff()
    }
    
    func siriOled() {
        UIApplication.shared.statusBarStyle = .lightContent
        Colours.keyCol = UIKeyboardAppearance.dark
        UserDefaults.standard.set(2, forKey: "theme")
        self.genericStuff()
    }
    
    func genericStuff() {
        
        self.firstView.loadLoadLoad()
        self.secondView.loadLoadLoad()
        self.thirdView.loadLoadLoad()
        self.fourthView.loadLoadLoad()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "load"), object: self)
        
        self.view.backgroundColor = Colours.white
        self.navigationController?.navigationBar.backgroundColor = Colours.white
        self.navigationController?.navigationBar.tintColor = Colours.white
        
        self.tabBar.barTintColor = Colours.white
        self.tabBar.backgroundColor = Colours.white
        self.tabBar.unselectedItemTintColor = Colours.tabUnselected
        self.tabBar.tintColor = Colours.tabSelected
        
        self.firstView.view.backgroundColor = Colours.white
        self.secondView.view.backgroundColor = Colours.white
        self.thirdView.view.backgroundColor = Colours.white
        self.fourthView.view.backgroundColor = Colours.white
        
        self.tabOne.navigationBar.backgroundColor = Colours.white
        self.tabOne.navigationBar.barTintColor = Colours.white
        self.tabTwo.navigationBar.backgroundColor = Colours.white
        self.tabTwo.navigationBar.barTintColor = Colours.white
        self.tabThree.navigationBar.backgroundColor = Colours.white
        self.tabThree.navigationBar.barTintColor = Colours.white
        self.tabFour.navigationBar.backgroundColor = Colours.white
        self.tabFour.navigationBar.barTintColor = Colours.white
        
        statusBarView.backgroundColor = Colours.white
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    func setupSiri() {
        let activity = NSUserActivity(activityType: "com.shi.Cosmo.play")
        activity.title = "Play or pause the current episode".localized
        activity.userInfo = ["state" : "play"]
        activity.isEligibleForSearch = true
        if #available(iOS 12.0, *) {
            activity.isEligibleForPrediction = true
            activity.persistentIdentifier = "com.shi.Cosmo.play"
        } else {
            // Fallback on earlier versions
        }
        view.userActivity = activity
        activity.becomeCurrent()
        
        delay(1.5) {
            let activity1 = NSUserActivity(activityType: "com.shi.Cosmo.light")
            activity1.title = "Switch to light mode".localized
            activity1.userInfo = ["state" : "light"]
            activity1.isEligibleForSearch = true
            if #available(iOS 12.0, *) {
                activity1.isEligibleForPrediction = true
                activity1.persistentIdentifier = "com.shi.Cosmo.light"
            } else {
                // Fallback on earlier versions
            }
            self.view.userActivity = activity1
            activity1.becomeCurrent()
        }
        
        delay(3) {
            let activity2 = NSUserActivity(activityType: "com.shi.Cosmo.dark")
            activity2.title = "Switch to dark mode".localized
            activity2.userInfo = ["state" : "dark"]
            activity2.isEligibleForSearch = true
            if #available(iOS 12.0, *) {
                activity2.isEligibleForPrediction = true
                activity2.persistentIdentifier = "com.shi.Cosmo.dark"
            } else {
                // Fallback on earlier versions
            }
            self.view.userActivity = activity2
            activity2.becomeCurrent()
        }
        
        delay(4.5) {
            let activity3 = NSUserActivity(activityType: "com.shi.Cosmo.oled")
            activity3.title = "Switch to true black dark mode".localized
            activity3.userInfo = ["state" : "oled"]
            activity3.isEligibleForSearch = true
            if #available(iOS 12.0, *) {
                activity3.isEligibleForPrediction = true
                activity3.persistentIdentifier = "com.shi.Cosmo.oled"
            } else {
                // Fallback on earlier versions
            }
            self.view.userActivity = activity3
            activity3.becomeCurrent()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = Colours.white
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.switchTab), name: NSNotification.Name(rawValue: "switch"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.switchTabD), name: NSNotification.Name(rawValue: "switchd"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.switchTabDisc), name: NSNotification.Name(rawValue: "switchdisc"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.searchOpen), name: NSNotification.Name(rawValue: "searchOpen"), object: nil)
        
        self.tableView.register(PodcastTableViewCell.self, forCellReuseIdentifier: "cell")
        self.drawerTableView.register(EpisodeTableViewCell.self, forCellReuseIdentifier: "celld")
        
        
        self.tabBar.barTintColor = Colours.white
        self.tabBar.backgroundColor = Colours.white
        self.tabBar.isTranslucent = false
        self.tabBar.unselectedItemTintColor = Colours.tabUnselected
        self.tabBar.tintColor = Colours.tabSelected
        
        statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarView.backgroundColor = Colours.white
        view.addSubview(statusBarView)
        
        if UserDefaults.standard.object(forKey: "theme") == nil {} else {
            let z = UserDefaults.standard.object(forKey: "theme") as! Int
            if z == 0 {
                UIApplication.shared.statusBarStyle = .default
            }
            if z == 1 {
                UIApplication.shared.statusBarStyle = .lightContent
            }
            if z == 2 {
                UIApplication.shared.statusBarStyle = .lightContent
            }
        }
        
        self.createTabBar()
        
        self.setupSiri()
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
        
        
        self.view0pinch.frame = self.view.frame
        self.view1pinch.frame = self.view.frame
        self.screenshotLabel.frame = (CGRect(x: 40, y: 70, width: self.view.bounds.width - 80, height: 50))
        self.screenshotLabel.text = "LET GO TO TWEET SCREENSHOT"
        self.screenshotLabel.textColor = UIColor.white
        self.screenshotLabel.textAlignment = .center
        self.screenshotLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(Colours.fontSize1))
        self.screenshotLabel.alpha = 0
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panAction(sender:)))
        panGesture.minimumNumberOfTouches = 2
        panGesture.delegate = self
        self.view.addGestureRecognizer(panGesture)
        
        
        //let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchAction(sender:)))
        //self.view.addGestureRecognizer(pinchGesture)
        
        FetchContent.shared.fetchGenrePodcasts(searchText: "26", country: StoreStruct.country) { podcasts in
            StoreStruct.discoverPodcasts = podcasts
            NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
        }
        
        /*
         MPMediaLibrary.requestAuthorization({
         (status) in
         switch status {
         case .notDetermined:
         print("notDetermined")
         case .denied:
         print("denied")
         case .restricted:
         print("restricted")
         case .authorized:
         print("authorized")
         var songsArray: [MPMediaItem] = [MPMediaItem]()
         songsArray = MPMediaQuery.podcasts().items!
         for songItem in songsArray {
         print(songItem)
         }
         }
         })
         */
        
        
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
    
    
    
    @objc func pinchAction(sender:UIPinchGestureRecognizer) {
        
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        
        if sender.state == .began {
            
            
            
            self.identity = self.view1pinch.transform
            
            
            //if self.doOncePinch == true {
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
            layer.render(in: UIGraphicsGetCurrentContext()!)
            self.screenshot = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            self.view0pinch.backgroundColor = UIColor(red: 0/250, green: 0/250, blue: 0/250, alpha: 1.0)
            
            self.view1pinch.layer.masksToBounds = true
            self.view1pinch.image = self.screenshot
            self.view1pinch.layer.shadowColor = UIColor.black.cgColor
            self.view1pinch.layer.shadowOffset = CGSize(width:0, height:5)
            self.view1pinch.layer.shadowRadius = 12
            self.view1pinch.layer.shadowOpacity = 0.2
            //self.view1pinch.layer.cornerRadius = 38
            
            self.screenshotLabel.frame = (CGRect(x: 40, y: 70, width: self.view.bounds.width - 80, height: 50))
            self.screenshotLabel.text = "Release to export podcasts"
            self.screenshotLabel.textColor = UIColor.white
            self.screenshotLabel.textAlignment = .center
            self.screenshotLabel.font = UIFont.boldSystemFont(ofSize: 16)
            self.screenshotLabel.alpha = 0
            
            self.view.addSubview(self.view0pinch)
            self.view.addSubview(self.view1pinch)
            self.view0pinch.addSubview(self.screenshotLabel)
            
            self.doOncePinch = false
            //}
            
        }
        if sender.state == .changed {
            print(sender.scale)
            
            if self.doOnceScreen == true {
                springWithDelay(duration: 0.75, delay: 0.15, animations: {
                    self.screenshotLabel.alpha = 1
                })
                self.doOnceScreen = false
            }
            
            
            if sender.scale < 0.9 {
                
                if doOnce == true {
                    
                    let impact = UIImpactFeedbackGenerator()
                    impact.impactOccurred()
                    
                    doOnce = false
                }
                
                
            }
            
            
            if sender.scale > 1 {
                
            } else {
                DispatchQueue.main.async {
                    springWithDelay(duration: 0.4, delay: 0, animations: {
                        self.view1pinch.transform = self.identity.scaledBy(x: sender.scale, y: sender.scale)
                    })
                }
            }
            
        }
        if sender.state == .ended {
            
            DispatchQueue.main.async {
                springWithCompletion(duration: 0.4, animations: {
                    self.view0pinch.frame = self.view.frame
                    self.view1pinch.frame = self.view.frame
                    
                    self.screenshotLabel.alpha = 0
                }, completion: { finished in
                    self.view0pinch.removeFromSuperview()
                    self.view1pinch.removeFromSuperview()
                    self.doOnceScreen = true
                    self.doOnce = true
                    self.doOncePinch = true
                    self.displayPodcastExport()
                })
            }
            
        }
    }
    
    func displayPodcastExport() {
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
        present(vc, animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }
    
    @objc func tapAction2(sender: UITapGestureRecognizer) {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
        self.dismissDrawer()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "switch"), object: self)
    }
    
    @objc func tapAction(sender: UITapGestureRecognizer) {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
        self.dismissDrawer()
    }
    
    func dismissDrawer() {
        DispatchQueue.main.async {
            UIApplication.shared.setStatusBarHidden(false, with: .fade)
            springWithCompletion(duration: 0.6, animations: {
                self.view1pinch.layer.cornerRadius = 0
                self.view1pinch.layer.masksToBounds = true
                self.view0pinch.frame = self.view.frame
                self.view1pinch.center = CGPoint(x: self.view!.center.x, y: self.view!.center.y)
                self.playButton.alpha = 0
                self.titleLab.alpha = 0
                self.backwardSkip.alpha = 0
                self.forwardSkip.alpha = 0
                self.lowerLab.alpha = 0
                self.upperLab.alpha = 0
                self.slider.alpha = 0
                self.mainImageView.alpha = 0
                self.drawerTableView.alpha = 0
            }, completion: { finished in
                self.view0pinch.removeFromSuperview()
                self.view1pinch.removeFromSuperview()
                self.doOnce = true
                self.doOncePinch = true
            })
        }
    }
    
    @objc func panAction(sender: UIPanGestureRecognizer) {
        
        let velocity = sender.velocity(in: view)
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        
        
        StoreStruct.fromSearchB = false
        
        
        //playdrawer
        if StoreStruct.whichView == 3 {
            
            if StoreStruct.playDrawerEpisode.isEmpty {} else {
                
                
                
                if velocity.y > 0 {
                    /*
                     if sender.state == .began {
                     DispatchQueue.main.async {
                     springWithDelay(duration: 0.4, delay: 0, animations: {
                     self.view1pinch.center = CGPoint(x: sender.view!.center.x, y: sender.view!.center.y)
                     })
                     }
                     }
                     
                     if sender.state == .changed {
                     
                     }
                     
                     if sender.state == .ended {
                     let selection = UISelectionFeedbackGenerator()
                     selection.selectionChanged()
                     UIApplication.shared.setStatusBarHidden(false, with: .fade)
                     
                     
                     
                     DispatchQueue.main.async {
                     springWithCompletion(duration: 0.6, animations: {
                     self.view1pinch.layer.cornerRadius = 0
                     self.view1pinch.layer.masksToBounds = true
                     self.view0pinch.frame = self.view.frame
                     self.view1pinch.center = CGPoint(x: self.view!.center.x, y: self.view!.center.y)
                     self.playButton.alpha = 0
                     self.titleLab.alpha = 0
                     self.backwardSkip.alpha = 0
                     self.forwardSkip.alpha = 0
                     self.lowerLab.alpha = 0
                     self.upperLab.alpha = 0
                     self.slider.alpha = 0
                     self.mainImageView.alpha = 0
                     self.drawerTableView.alpha = 0
                     }, completion: { finished in
                     self.view0pinch.removeFromSuperview()
                     self.view1pinch.removeFromSuperview()
                     self.doOnce = true
                     self.doOncePinch = true
                     })
                     }
                     }
                     */
                } else {
                    
                    if sender.state == .began {
                        
                        UIApplication.shared.setStatusBarHidden(true, with: .fade)
                        self.identity = self.view1pinch.transform
                        
                        if self.doOncePinch == true {
                            
                            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
                            layer.render(in: UIGraphicsGetCurrentContext()!)
                            self.screenshot = UIGraphicsGetImageFromCurrentImageContext()!
                            UIGraphicsEndImageContext()
                            
                            self.view0pinch.backgroundColor = Colours.blackSlider
                            self.view1pinch.image = self.screenshot
                            
                            let window = UIApplication.shared.keyWindow
                            var bottomPadding = 0
                            if UIDevice().userInterfaceIdiom == .phone {
                                switch UIScreen.main.nativeBounds.height {
                                case 1136:
                                    print("iPhone 5 or 5S or 5C")
                                case 1334:
                                    print("iPhone 6/6S/7/8")
                                case 2208:
                                    print("iPhone 6+/6S+/7+/8+")
                                case 2688:
                                    print("iPhone Xs Max")
                                    self.view1pinch.layer.cornerRadius = 38
                                    self.view1pinch.layer.masksToBounds = true
                                    if #available(iOS 11.0, *) {
                                        bottomPadding = Int(window!.safeAreaInsets.bottom)
                                    }
                                case 2436:
                                    print("iPhone X")
                                    self.view1pinch.layer.cornerRadius = 38
                                    self.view1pinch.layer.masksToBounds = true
                                    if #available(iOS 11.0, *) {
                                        bottomPadding = Int(window!.safeAreaInsets.bottom)
                                    }
                                default:
                                    print("unknown")
                                }
                            }
                            
                            self.view.addSubview(self.view0pinch)
                            self.view.addSubview(self.view1pinch)
                            self.view0pinch.addSubview(self.screenshotLabel)
                            
                            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(sender:)))
                            self.view1pinch.isUserInteractionEnabled = true
                            self.view1pinch.addGestureRecognizer(tapGesture)
                            
                            
                            self.drawerTableView.frame = CGRect(x: 0, y: Int(self.view.bounds.height - 440), width: Int(self.view.bounds.width), height: Int(450 - bottomPadding))
                            self.drawerTableView.alpha = 1
                            self.drawerTableView.delegate = self
                            self.drawerTableView.dataSource = self
                            self.drawerTableView.separatorStyle = .none
                            self.drawerTableView.backgroundColor = UIColor.black
                            self.drawerTableView.separatorColor = UIColor.black
                            self.drawerTableView.layer.masksToBounds = true
                            self.drawerTableView.estimatedRowHeight = 89
                            self.drawerTableView.rowHeight = UITableView.automaticDimension
                            self.view0pinch.addSubview(self.drawerTableView)
                            self.drawerTableView.reloadData()
                            
                            let topGradient = UIView()
                            topGradient.frame = CGRect(x: 0, y: Int(self.view.bounds.height - 440), width: Int(self.view.bounds.width), height: Int(30))
                            topGradient.backgroundColor = Colours.clear
                            self.view0pinch.addSubview(topGradient)
                            
                            let gradientLayer = CAGradientLayer()
                            gradientLayer.frame = topGradient.bounds
                            gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
                            topGradient.layer.addSublayer(gradientLayer)
                            
                            let botGradient = UIView()
                            botGradient.frame = CGRect(x: 0, y: Int(self.view.bounds.height - 20) - Int(bottomPadding), width: Int(self.view.bounds.width), height: Int(30))
                            botGradient.backgroundColor = Colours.clear
                            self.view0pinch.addSubview(botGradient)
                            
                            let gradientLayer2 = CAGradientLayer()
                            gradientLayer2.frame = botGradient.bounds
                            gradientLayer2.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
                            botGradient.layer.addSublayer(gradientLayer2)
                        }
                    }
                    
                    if sender.state == .changed {
                        
                        DispatchQueue.main.async {
                            springWithDelay(duration: 0.1, delay: 0, animations: {
                                let translation = sender.translation(in: self.view)
                                self.view1pinch.center = CGPoint(x: self.view!.center.x, y: self.view!.center.y + translation.y)
                            })
                        }
                        
                    }
                    
                    if sender.state == .ended {
                        let selection = UISelectionFeedbackGenerator()
                        selection.selectionChanged()
                        DispatchQueue.main.async {
                            springWithCompletion(duration: 0.6, animations: {
                                self.view0pinch.frame = self.view.frame
                                self.view1pinch.center = CGPoint(x: sender.view!.center.x, y: sender.view!.center.y - 450)
                            }, completion: { finished in
                                self.doOnce = false
                                self.doOncePinch = false
                            })
                        }
                    }
                    
                }
                
                
                
                
                
                
            }
            
            
            
            
            
        } else {
            
            if StoreStruct.playEpisode.isEmpty {} else {
                
                if velocity.y > 0 {
                    /*
                     if sender.state == .began || sender.state == .changed {
                     DispatchQueue.main.async {
                     springWithDelay(duration: 0.4, delay: 0, animations: {
                     self.view1pinch.center = CGPoint(x: sender.view!.center.x, y: sender.view!.center.y)
                     })
                     }
                     }
                     
                     if sender.state == .ended {
                     let selection = UISelectionFeedbackGenerator()
                     selection.selectionChanged()
                     UIApplication.shared.setStatusBarHidden(false, with: .fade)
                     
                     DispatchQueue.main.async {
                     springWithCompletion(duration: 0.6, animations: {
                     self.view1pinch.layer.cornerRadius = 0
                     self.view1pinch.layer.masksToBounds = true
                     self.view0pinch.frame = self.view.frame
                     self.view1pinch.center = CGPoint(x: self.view!.center.x, y: self.view!.center.y)
                     self.playButton.alpha = 0
                     self.titleLab.alpha = 0
                     self.backwardSkip.alpha = 0
                     self.forwardSkip.alpha = 0
                     self.lowerLab.alpha = 0
                     self.upperLab.alpha = 0
                     self.slider.alpha = 0
                     self.mainImageView.alpha = 0
                     self.drawerTableView.alpha = 0
                     }, completion: { finished in
                     self.view0pinch.removeFromSuperview()
                     self.view1pinch.removeFromSuperview()
                     self.doOnce = true
                     self.doOncePinch = true
                     })
                     }
                     }
                     */
                } else {
                    
                    if sender.state == .began {
                        
                        UIApplication.shared.setStatusBarHidden(true, with: .fade)
                        self.identity = self.view1pinch.transform
                        
                        if self.doOncePinch == true {
                            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
                            layer.render(in: UIGraphicsGetCurrentContext()!)
                            self.screenshot = UIGraphicsGetImageFromCurrentImageContext()!
                            UIGraphicsEndImageContext()
                            
                            self.view0pinch.backgroundColor = Colours.blackSlider
                            self.view1pinch.image = self.screenshot
                            
                            let window = UIApplication.shared.keyWindow
                            var bottomPadding = 0
                            if UIDevice().userInterfaceIdiom == .phone {
                                switch UIScreen.main.nativeBounds.height {
                                case 1136:
                                    print("iPhone 5 or 5S or 5C")
                                case 1334:
                                    print("iPhone 6/6S/7/8")
                                case 2208:
                                    print("iPhone 6+/6S+/7+/8+")
                                case 2688:
                                    print("iPhone Xs Max")
                                    self.view1pinch.layer.cornerRadius = 38
                                    self.view1pinch.layer.masksToBounds = true
                                    if #available(iOS 11.0, *) {
                                        bottomPadding = Int(window!.safeAreaInsets.bottom)
                                    }
                                case 2436:
                                    print("iPhone X")
                                    self.view1pinch.layer.cornerRadius = 38
                                    self.view1pinch.layer.masksToBounds = true
                                    if #available(iOS 11.0, *) {
                                        bottomPadding = Int(window!.safeAreaInsets.bottom)
                                    }
                                default:
                                    print("unknown")
                                }
                            }
                            
                            self.view.addSubview(self.view0pinch)
                            self.view.addSubview(self.view1pinch)
                            self.view0pinch.addSubview(self.screenshotLabel)
                            
                            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(sender:)))
                            self.view1pinch.isUserInteractionEnabled = true
                            self.view1pinch.addGestureRecognizer(tapGesture)
                            
                            
                            self.mainImageView.frame = CGRect(x: 20, y: Int(self.view.bounds.height) - 185 - Int(bottomPadding), width: 40, height: 40)
                            self.mainImageView.layer.cornerRadius = 10
                            guard let secureImageUrl = URL(string: StoreStruct.mainImage) else { return }
                            self.mainImageView.image = UIImage(named: "logo")
                            self.mainImageView.pin_updateWithProgress = true
                            self.mainImageView.pin_setImage(from: secureImageUrl)
                            self.mainImageView.layer.masksToBounds = true
                            self.mainImageView.contentMode = .scaleAspectFill
                            self.mainImageView.alpha = 1
                            let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.tapAction2(sender:)))
                            self.mainImageView.isUserInteractionEnabled = true
                            self.mainImageView.addGestureRecognizer(tapGesture2)
                            self.view0pinch.addSubview(self.mainImageView)
                            
                            
                            
                            self.playButton.frame = CGRect(x: Int(self.view.bounds.width/2) - 40, y: Int(self.view.bounds.height) - 85 - Int(bottomPadding), width: 80, height: 80)
                            self.playButton.backgroundColor = Colours.clear
                            self.playButton.layer.cornerRadius = 40
                            self.playButton.alpha = 0
                            if StoreStruct.isPlaying {
                                self.playButton.setImage(UIImage(named: "pause")?.maskWithColor(color: UIColor.white), for: .normal)
                            } else {
                                self.playButton.setImage(UIImage(named: "play")?.maskWithColor(color: UIColor.white), for: .normal)
                            }
                            self.playButton.addTarget(self, action: #selector(self.touchPlay), for: .touchUpInside)
                            self.view0pinch.addSubview(self.playButton)
                            
                            
                            self.backwardSkip.frame = CGRect(x: Int(self.view.bounds.width/4) - 25, y: Int(self.view.bounds.height) - 70 - Int(bottomPadding), width: 50, height: 50)
                            self.backwardSkip.backgroundColor = Colours.clear
                            self.backwardSkip.layer.cornerRadius = 25
                            self.backwardSkip.setTitle("\(StoreStruct.leftSkip)", for: .normal)
                            self.backwardSkip.setTitleColor(UIColor.white, for: .normal)
                            self.backwardSkip.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
                            self.backwardSkip.alpha = 0
                            self.backwardSkip.addTarget(self, action: #selector(self.touchBack), for: .touchUpInside)
                            self.view0pinch.addSubview(self.backwardSkip)
                            
                            
                            self.forwardSkip.frame = CGRect(x: Int(self.view.bounds.width/4)*3 - 25, y: Int(self.view.bounds.height) - 70 - Int(bottomPadding), width: 50, height: 50)
                            self.forwardSkip.backgroundColor = Colours.clear
                            self.forwardSkip.layer.cornerRadius = 25
                            self.forwardSkip.setTitle("\(StoreStruct.rightSkip)", for: .normal)
                            self.forwardSkip.setTitleColor(UIColor.white, for: .normal)
                            self.forwardSkip.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
                            self.forwardSkip.alpha = 0
                            self.forwardSkip.addTarget(self, action: #selector(self.touchForward), for: .touchUpInside)
                            self.view0pinch.addSubview(self.forwardSkip)
                            
                            
                            self.titleLab = MarqueeLabel.init(frame: CGRect(x: 80, y: Int(self.view.bounds.height) - 185 - Int(bottomPadding), width: Int(self.view.bounds.width - 100), height: 40), duration: 9, fadeLength: 20)
                            self.titleLab.text = ""
                            if StoreStruct.playEpisode.isEmpty {
                                self.titleLab.text = ""
                            } else {
                                if StoreStruct.playDrawerPodcast[0].contentAdvisoryRating == "Explicit" || StoreStruct.playDrawerPodcast[0].contentAdvisoryRating == "yes" {
                                    self.titleLab.text = "🅴 \(StoreStruct.playEpisode[0].title ?? "")"
                                } else {
                                    self.titleLab.text = StoreStruct.playEpisode[0].title
                                }
                            }
                            self.titleLab.textColor = UIColor.white.withAlphaComponent(1)
                            self.titleLab.font = UIFont.boldSystemFont(ofSize: 18)
                            self.titleLab.textAlignment = .left
                            self.titleLab.alpha = 0
                            self.view0pinch.addSubview(self.titleLab)
                            
                            
                            self.lowerLab.frame = CGRect(x: 40, y: Int(self.view.bounds.height) - 105 - Int(bottomPadding), width: 120, height: 40)
                            self.lowerLab.text = "00:00:00"
                            self.lowerLab.textColor = UIColor.white.withAlphaComponent(0.5)
                            self.lowerLab.font = UIFont.systemFont(ofSize: 12)
                            self.lowerLab.textAlignment = .left
                            self.lowerLab.alpha = 0
                            self.view0pinch.addSubview(self.lowerLab)
                            
                            self.upperLab.frame = CGRect(x:  Int(self.view.bounds.width) - 160, y: Int(self.view.bounds.height) - 105 - Int(bottomPadding), width: 120, height: 40)
                            self.upperLab.text = StoreStruct.upperLab
                            self.upperLab.textColor = UIColor.white.withAlphaComponent(0.5)
                            self.upperLab.font = UIFont.systemFont(ofSize: 12)
                            self.upperLab.textAlignment = .right
                            self.upperLab.alpha = 0
                            self.view0pinch.addSubview(self.upperLab)
                            
                            slider = CustomUISlider(frame: CGRect(x: 40, y: Int(self.view.bounds.height) - 110 - Int(bottomPadding), width: Int(self.view.bounds.width) - 40, height: 20))
                            slider.layer.position = CGPoint(x: Int(self.view.frame.midX), y: Int(self.view.bounds.height) - 110 - Int(bottomPadding))
                            slider.backgroundColor = Colours.clear
                            slider.layer.cornerRadius = 10
                            slider.layer.masksToBounds = false
                            slider.minimumValue = 0
                            slider.maximumValue = StoreStruct.seconds
                            slider.maximumTrackTintColor = Colours.grayDark2
                            slider.minimumTrackTintColor = Colours.tabSelected
                            slider.setMaximumTrackImage(UIImage(named: "maxslide")?.maskWithColor(color: Colours.grayDark2), for: .normal)
                            slider.setThumbImage(UIImage(named: "slidethumb"), for: .normal)
                            slider.addTarget(self, action: #selector(onChangeValueMySlider), for: .valueChanged)
                            slider.alpha = 0
                            self.view0pinch.addSubview(slider)
                            
                            
                            
                            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                                self.lowerLab.text = self.toCorrectTime(time: StoreStruct.currentSeconds)
                                self.slider.setValue(StoreStruct.currentSeconds, animated: true)
                            }
                            timer!.fire()
                            
                            
                            springWithDelay(duration: 0.6, delay: 0, animations: {
                                self.playButton.alpha = 1
                                self.titleLab.alpha = 1
                                self.backwardSkip.alpha = 1
                                self.forwardSkip.alpha = 1
                                self.lowerLab.alpha = 1
                                self.upperLab.alpha = 1
                                self.slider.alpha = 1
                            })
                            
                            
                            self.doOncePinch = false
                        }
                        
                    }
                    if sender.state == .changed {
                        
                        DispatchQueue.main.async {
                            springWithDelay(duration: 0.1, delay: 0, animations: {
                                let translation = sender.translation(in: self.view)
                                self.view1pinch.center = CGPoint(x: self.view!.center.x, y: self.view!.center.y + translation.y)
                            })
                        }
                        
                    }
                    if sender.state == .ended {
                        let selection = UISelectionFeedbackGenerator()
                        selection.selectionChanged()
                        DispatchQueue.main.async {
                            springWithCompletion(duration: 0.6, animations: {
                                self.view0pinch.frame = self.view.frame
                                self.view1pinch.center = CGPoint(x: sender.view!.center.x, y: sender.view!.center.y - 245)
                            }, completion: { finished in
                                self.doOnce = false
                                self.doOncePinch = false
                            })
                        }
                    }
                }
            }
        }
    }
    
    
    
    func toCorrectTime(time: Float) -> String {
        print(time)
        if time.isNaN {
            return String(format:"%02i:%02i:%02i", 0, 0, 0)
        } else {
            let hours = Int(time) / 3600
            let minutes = Int(time) / 60 % 60
            let seconds = Int(time) % 60
            return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        }
    }
    
    @objc func onChangeValueMySlider(sender: UISlider) {
        let seconds: Int64 = Int64(sender.value)
        let dict:[String: Int64] = ["sec": seconds]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "sliderA"), object: self, userInfo: dict)
    }
    
    @objc func touchBack(button: UIButton) {
        self.doHaptics()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "backA"), object: self)
    }
    
    @objc func touchForward(button: UIButton) {
        self.doHaptics()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "forwardA"), object: self)
    }
    
    @objc func touchPlay(button: UIButton) {
        let impact = UIImpactFeedbackGenerator()
        impact.impactOccurred()
        
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
        
        if StoreStruct.isPlaying {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "pauseA"), object: self)
            StoreStruct.isPlaying = false
            self.playButton.setImage(UIImage(named: "play")?.maskWithColor(color: UIColor.white), for: .normal)
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "playA"), object: self)
            StoreStruct.isPlaying = true
            self.playButton.setImage(UIImage(named: "pause")?.maskWithColor(color: UIColor.white), for: .normal)
        }
    }
    
    
    
    
    
    @objc func dismissOverlay(button: UIButton) {
        dismissOverlayProper()
    }
    func dismissOverlayProper() {
        var fromTop = 45
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688:
                print("iPhone Xs Max")
                fromTop = 45
            case 2436:
                print("iPhone X")
                fromTop = 45
            default:
                fromTop = 22
            }
        }
        
        self.backgroundView.alpha = 0
        self.circlebg.alpha = 0
        self.circleArrow.alpha = 0
        self.circle6.alpha = 0
        
        self.searchTextField.resignFirstResponder()
        self.searchTextField.text = ""
        self.podcasts = []
        
        let wid = self.view.bounds.width
        //self.searcherView.frame = CGRect(x: 10, y: fromTop, width: Int(wid), height: 60)
        //self.searcherView.transform = CGAffineTransform(scaleX: 1, y: 1)
        springWithDelay(duration: 0.37, delay: 0, animations: {
            self.searcherView.alpha = 0
            //self.searcherView.frame = CGRect(x: Int(wid) - 10, y: fromTop, width: 200, height: 60)
            //self.searcherView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        self.switcherView.frame = CGRect(x: 10, y: fromTop, width: 200, height: 335)
        springWithDelay(duration: 0.37, delay: 0, animations: {
            self.switcherView.frame = CGRect(x: 10, y: fromTop, width: 0, height: 0)
            self.circle1.alpha = 0
            self.circle2.alpha = 0
            self.circle3.alpha = 0
            self.circle4.alpha = 0
            self.circle5.alpha = 0
            self.option1.alpha = 0
            self.option2.alpha = 0
            self.option3.alpha = 0
            self.option4.alpha = 0
            self.option5.alpha = 0
            self.option6.alpha = 0
        })
        springWithDelay(duration: 0.1, delay: 0.18, animations: {
            self.switcherView.alpha = 0
        })
        //self.tableView.reloadData()
    }
    
    @objc func touch1(button: UIButton) {
        doHaptics()
        self.selectedOption = 1
        StoreStruct.columns = 1
        NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
        dismissOverlayProper()
        UserDefaults.standard.set(1, forKey: "gridCol")
    }
    
    @objc func touch2(button: UIButton) {
        doHaptics()
        self.selectedOption = 2
        StoreStruct.columns = 2
        NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
        dismissOverlayProper()
        UserDefaults.standard.set(2, forKey: "gridCol")
    }
    
    @objc func touch3(button: UIButton) {
        doHaptics()
        self.selectedOption = 3
        StoreStruct.columns = 3
        NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
        dismissOverlayProper()
        UserDefaults.standard.set(3, forKey: "gridCol")
    }
    
    @objc func touch4(button: UIButton) {
        doHaptics()
        self.selectedOption = 4
        StoreStruct.columns = 4
        NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
        dismissOverlayProper()
        UserDefaults.standard.set(4, forKey: "gridCol")
    }
    
    @objc func touch5(button: UIButton) {
        doHaptics()
        self.selectedOption = 5
        StoreStruct.columns = 5
        NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
        dismissOverlayProper()
        UserDefaults.standard.set(5, forKey: "gridCol")
    }
    
    @objc func touch6(button: UIButton) {
        doHaptics()
        
        var newNum = 0
        if UserDefaults.standard.object(forKey: "theme") == nil {} else {
            let z = UserDefaults.standard.object(forKey: "theme") as! Int
            if z == 0 {
                newNum = 1
                UIApplication.shared.statusBarStyle = .lightContent
                Colours.keyCol = UIKeyboardAppearance.dark
            }
            if z == 1 {
                newNum = 2
                UIApplication.shared.statusBarStyle = .lightContent
                Colours.keyCol = UIKeyboardAppearance.dark
            }
            if z == 2 {
                newNum = 0
                UIApplication.shared.statusBarStyle = .default
                Colours.keyCol = UIKeyboardAppearance.dark
            }
        }
        
        UserDefaults.standard.set(newNum, forKey: "theme")
        
        DispatchQueue.main.async {
            
        self.firstView.loadLoadLoad()
        self.secondView.loadLoadLoad()
        self.thirdView.loadLoadLoad()
        self.fourthView.loadLoadLoad()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "load"), object: self)
        
        self.view.backgroundColor = Colours.white
        self.navigationController?.navigationBar.backgroundColor = Colours.white
        self.navigationController?.navigationBar.tintColor = Colours.white
        
        self.tabBar.barTintColor = Colours.white
        self.tabBar.backgroundColor = Colours.white
        self.tabBar.unselectedItemTintColor = Colours.tabUnselected
        self.tabBar.tintColor = Colours.tabSelected
        
        self.firstView.view.backgroundColor = Colours.white
        self.secondView.view.backgroundColor = Colours.white
        self.thirdView.view.backgroundColor = Colours.white
        self.fourthView.view.backgroundColor = Colours.white
        
        self.tabOne.navigationBar.backgroundColor = Colours.white
        self.tabOne.navigationBar.barTintColor = Colours.white
        self.tabTwo.navigationBar.backgroundColor = Colours.white
        self.tabTwo.navigationBar.barTintColor = Colours.white
        self.tabThree.navigationBar.backgroundColor = Colours.white
        self.tabThree.navigationBar.barTintColor = Colours.white
        self.tabFour.navigationBar.backgroundColor = Colours.white
        self.tabFour.navigationBar.barTintColor = Colours.white
        
            self.statusBarView.backgroundColor = Colours.white
        }
    }
    
    @objc func searchOpen(notification: NSNotification) {
        var fromTop = 45
        StoreStruct.fromSearchB = true
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688:
                print("iPhone Xs Max")
                fromTop = 45
            case 2436:
                print("iPhone X")
                fromTop = 45
            default:
                fromTop = 22
            }
        }
        
        let wid = self.view.bounds.width - 20
        if let artist = notification.userInfo?["artist"] as? String {
            self.searchTextField.text = artist
            self.tSearch()
            if self.tableView.alpha == 0 {
                self.searcherView.frame = CGRect(x: 10, y: fromTop, width: Int(wid), height: 60)
                springWithDelay(duration: 0.5, delay: 0, animations: {
                    self.searcherView.alpha = 1
                    self.searcherView.frame = CGRect(x: 10, y: fromTop, width: Int(wid), height: 340)
                })
                self.tableView.frame = CGRect(x: 0, y: 60, width: Int(wid), height: Int(0))
                springWithDelay(duration: 0.5, delay: 0, animations: {
                    self.tableView.alpha = 1
                    self.tableView.frame = CGRect(x: 0, y: 60, width: Int(wid), height: Int(280))
                })
            }
            FetchContent.shared.fetchPodcasts(searchText: artist) { podcasts in
                self.podcasts = podcasts
                self.podcasts = self.podcasts.filter { $0.artistName == artist }
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func didTouchSearch(button: UIButton) {
        StoreStruct.fromSearchB = true
        self.tSearch()
    }
    
    func tSearch() {
        doHaptics()
        var fromTop = 45
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688:
                print("iPhone Xs Max")
                fromTop = 45
            case 2436:
                print("iPhone X")
                fromTop = 45
            default:
                fromTop = 22
            }
        }
        
        self.backgroundView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.backgroundView.backgroundColor = UIColor.black
        self.backgroundView.alpha = 0.2
        self.backgroundView.addTarget(self, action: #selector(self.dismissOverlay), for: .touchUpInside)
        self.view.addSubview(self.backgroundView)
        
        let wid = self.view.bounds.width - 20
        self.searcherView.frame = CGRect(x: 10, y: fromTop, width: Int(wid), height: 60)
        self.searcherView.backgroundColor = Colours.grayDark2
        self.searcherView.layer.cornerRadius = 20
        self.searcherView.alpha = 0
        self.searcherView.layer.masksToBounds = true
        self.view.addSubview(self.searcherView)
        
        //text field
        
        searchTextField.frame = CGRect(x: 10, y: 10, width: Int(Int(wid) - 20), height: 40)
        searchTextField.backgroundColor = Colours.grayDark3
        searchTextField.font = UIFont.systemFont(ofSize: 16)
        searchTextField.layer.cornerRadius = 10
        searchTextField.alpha = 1
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search for podcasts or paste URL".localized,
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor(red:110/250, green: 113/250, blue: 121/250, alpha: 1.0)])
        searchTextField.becomeFirstResponder()
        searchTextField.keyboardAppearance = Colours.keyCol
        searchTextField.returnKeyType = .search
        searchTextField.delegate = self
        searchTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchTextField.textColor = UIColor.white
        searchTextField.keyboardAppearance = UIKeyboardAppearance.dark
        self.searcherView.addSubview(searchTextField)
        
        //table
        
        self.tableView.frame = CGRect(x: 0, y: 60, width: Int(wid), height: Int(0))
        self.tableView.alpha = 0
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .singleLine
        self.tableView.backgroundColor = Colours.grayDark2
        self.tableView.separatorColor = Colours.grayDark3
        self.tableView.layer.masksToBounds = true
        self.tableView.estimatedRowHeight = 89
        self.tableView.rowHeight = UITableView.automaticDimension
        self.searcherView.addSubview(self.tableView)
        
        //animate
        
        //self.searcherView.frame = CGRect(x: Int(wid) - 10, y: fromTop, width: 200, height: 60)
        self.searcherView.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        springWithDelay(duration: 0.5, delay: 0, animations: {
            self.searcherView.alpha = 1
            //self.searcherView.frame = CGRect(x: 10, y: fromTop, width: Int(wid), height: 60)
            self.searcherView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        print("changed")
        var fromTop = 45
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688:
                print("iPhone Xs Max")
                fromTop = 45
            case 2436:
                print("iPhone X")
                fromTop = 45
            default:
                fromTop = 22
            }
        }
        
        let wid = self.view.bounds.width - 20
        
        
        //comebacksearch
        if textField.text!.contains("http") && textField.text!.contains("/") {
            
            let parser = FeedParser(URL: URL(string: textField.text!)!)
            parser?.parseAsync(result: { (result) in
                
                if let err = result.error {
                    print("Failed to parse XML feed:", err)
                    return
                }
                
                guard let feed = result.rssFeed else { return }
                StoreStruct.rssFeed = feed
                DispatchQueue.main.async {
                    let tr = feed.title
                    let ar = feed.iTunes?.iTunesAuthor
                    var aw = feed.image?.url
                    if aw == nil {
                        aw = feed.iTunes?.iTunesImage?.attributes?.href
                    }
                    let co = feed.items?.count
                    let fee = feed.link
                    let gen = feed.iTunes?.iTunesCategories?[0].attributes?.text
                    let adv = feed.iTunes?.iTunesExplicit
                    let singlePodcast = Podcast.init(track: tr, artist: ar, artwork: aw, count: co, feedURL: fee, genre: gen, rating: adv)
                    StoreStruct.tappedFeedURL = fee ?? ""
                    StoreStruct.sendPodcast = [singlePodcast]
                    self.dismissOverlayProper()
                    StoreStruct.fromCopy = true
                    if StoreStruct.whichView == 0 {
                        self.firstView.goToNextFromPrev()
                    } else if StoreStruct.whichView == 1 {
                        self.secondView.goToNextFromPrev()
                    } else if StoreStruct.whichView == 2 {
                        self.thirdView.goToNextFromPrev()
                    } else if StoreStruct.whichView == 3 {
                        self.thirdView.goToNextFromPrev()
                    } else {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "nextfrom"), object: self)
                    }
                }
            })
            
        } else {
            
            
            
            if textField.text == "" {
                self.searcherView.frame = CGRect(x: 10, y: fromTop, width: Int(wid), height: 340)
                springWithDelay(duration: 0.7, delay: 0, animations: {
                    self.searcherView.alpha = 1
                    self.searcherView.frame = CGRect(x: 10, y: fromTop, width: Int(wid), height: 60)
                })
                self.tableView.frame = CGRect(x: 0, y: 60, width: Int(wid), height: Int(260))
                springWithDelay(duration: 0.7, delay: 0, animations: {
                    self.tableView.alpha = 0
                    self.tableView.frame = CGRect(x: 0, y: 60, width: Int(wid), height: Int(0))
                })
            } else {
                
                if self.tableView.alpha == 0 {
                    self.searcherView.frame = CGRect(x: 10, y: fromTop, width: Int(wid), height: 60)
                    springWithDelay(duration: 0.5, delay: 0, animations: {
                        self.searcherView.alpha = 1
                        self.searcherView.frame = CGRect(x: 10, y: fromTop, width: Int(wid), height: 340)
                    })
                    self.tableView.frame = CGRect(x: 0, y: 60, width: Int(wid), height: Int(0))
                    springWithDelay(duration: 0.5, delay: 0, animations: {
                        self.tableView.alpha = 1
                        self.tableView.frame = CGRect(x: 0, y: 60, width: Int(wid), height: Int(280))
                    })
                }
                
            }
            FetchContent.shared.fetchPodcasts(searchText: textField.text ?? "") { podcasts in
                self.podcasts = podcasts
                self.tableView.reloadData()
            }
            
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        var fromTop = 45
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688:
                print("iPhone Xs Max")
                fromTop = 45
            case 2436:
                print("iPhone X")
                fromTop = 45
            default:
                fromTop = 22
            }
        }
        
        let wid = self.view.bounds.width - 20
        
        if textField.text != "" {
            springWithDelay(duration: 0.5, delay: 0, animations: {
                self.searcherView.alpha = 1
                self.searcherView.frame = CGRect(x: 10, y: fromTop, width: Int(wid), height: 340)
            })
            springWithDelay(duration: 0.5, delay: 0, animations: {
                self.tableView.alpha = 1
                self.tableView.frame = CGRect(x: 0, y: 60, width: Int(wid), height: Int(280))
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var fromTop = 45
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688:
                print("iPhone Xs Max")
                fromTop = 45
            case 2436:
                print("iPhone X")
                fromTop = 45
            default:
                fromTop = 22
            }
        }
        
        let wid = self.view.bounds.width - 20
        let he = Int(self.view.bounds.height) - fromTop - fromTop
        
        textField.resignFirstResponder()
        
        self.searcherView.frame = CGRect(x: 10, y: fromTop, width: Int(wid), height: 340)
        springWithDelay(duration: 0.5, delay: 0, animations: {
            self.searcherView.frame = CGRect(x: 10, y: fromTop, width: Int(wid), height: Int(he))
        })
        self.tableView.frame = CGRect(x: 0, y: 60, width: Int(wid), height: Int(280))
        springWithDelay(duration: 0.5, delay: 0, animations: {
            self.tableView.frame = CGRect(x: 0, y: 60, width: Int(wid), height: Int(he) - 60)
        })
        
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if StoreStruct.fromSearchB == true {
            return self.podcasts.count
        } else {
            return StoreStruct.playDrawerEpisode.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if StoreStruct.fromSearchB == true && tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PodcastTableViewCell
            cell.configure(podcasts[indexPath.row])
            cell.backgroundColor = Colours.grayDark2
            let bgColorView = UIView()
            bgColorView.backgroundColor = Colours.grayDark3
            cell.selectedBackgroundView = bgColorView
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "celld", for: indexPath) as! EpisodeTableViewCell
            
            cell.configure(StoreStruct.playDrawerEpisode[indexPath.row])
            
            cell.trackNameLabel.textColor = UIColor.white
            cell.artistNameLabel.textColor = UIColor.white.withAlphaComponent(0.6)
            cell.dateLabel.textColor = UIColor.white.withAlphaComponent(0.3)
            cell.backgroundColor = UIColor.black
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.black
            cell.selectedBackgroundView = bgColorView
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        if StoreStruct.fromSearchB == true && tableView == self.tableView {
            StoreStruct.searchIndex = indexPath.row
            StoreStruct.tappedFeedURL = podcasts[indexPath.row].feedUrl ?? ""
            StoreStruct.sendPodcast = [podcasts[indexPath.row]]
            
            self.dismissOverlayProper()
            
            if StoreStruct.whichView == 0 {
                self.firstView.goToNextFromPrev()
            } else if StoreStruct.whichView == 1 {
                self.secondView.goToNextFromPrev()
            } else if StoreStruct.whichView == 2 {
                self.thirdView.goToNextFromPrev()
            } else if StoreStruct.whichView == 3 {
                self.thirdView.goToNextFromPrev()
            } else {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "nextfrom"), object: self)
            }
        } else {
            
            self.dismissDrawer()
            
            StoreStruct.isPlaying = false
            StoreStruct.isPlayingInitial = false
            StoreStruct.playEpisode = [StoreStruct.playDrawerEpisode[indexPath.item]]
            StoreStruct.playPodcast = StoreStruct.playDrawerPodcast
            StoreStruct.playArtist = StoreStruct.playDrawerArtist
            StoreStruct.mainImage = StoreStruct.mainDrawerImage
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: self)
            
        }
    }
    
    func doHaptics() {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
    }
    
    @objc func touchGrid(button: UIButton) {
        doHaptics()
        var fromTop = 45
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688:
                print("iPhone Xs Max")
                fromTop = 45
            case 2436:
                print("iPhone X")
                fromTop = 45
            default:
                fromTop = 22
            }
        }
        
        self.backgroundView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.backgroundView.backgroundColor = UIColor.black
        self.backgroundView.alpha = 0.2
        self.backgroundView.addTarget(self, action: #selector(self.dismissOverlay), for: .touchUpInside)
        self.view.addSubview(self.backgroundView)
        
        self.switcherView.frame = CGRect(x: 10, y: fromTop, width: 200, height: 335)
        self.switcherView.backgroundColor = Colours.grayDark2
        self.switcherView.layer.cornerRadius = 30
        self.switcherView.alpha = 0
        self.view.addSubview(self.switcherView)
        
        //circles
        
        self.circlebg.frame = CGRect(x: 16, y: 18, width: 42, height: 242)
        self.circlebg.backgroundColor = Colours.grayDark3
        self.circlebg.layer.cornerRadius = 21
        self.circlebg.alpha = 1
        self.switcherView.addSubview(self.circlebg)
        
        self.circle1.frame = CGRect(x: 32, y: 34, width: 10, height: 10)
        self.circle1.backgroundColor = Colours.blue
        self.circle1.layer.cornerRadius = 5
        self.circle1.alpha = 1
        self.circle1.addTarget(self, action: #selector(self.touch1), for: .touchUpInside)
        self.switcherView.addSubview(self.circle1)
        
        self.circle2.frame = CGRect(x: 32, y: 84, width: 10, height: 10)
        self.circle2.backgroundColor = Colours.red
        self.circle2.layer.cornerRadius = 5
        self.circle2.alpha = 1
        self.circle2.addTarget(self, action: #selector(self.touch2), for: .touchUpInside)
        self.switcherView.addSubview(self.circle2)
        
        self.circle3.frame = CGRect(x: 32, y: 134, width: 10, height: 10)
        self.circle3.backgroundColor = Colours.green
        self.circle3.layer.cornerRadius = 5
        self.circle3.alpha = 1
        self.circle3.addTarget(self, action: #selector(self.touch3), for: .touchUpInside)
        self.switcherView.addSubview(self.circle3)
        
        self.circle4.frame = CGRect(x: 32, y: 184, width: 10, height: 10)
        self.circle4.backgroundColor = Colours.orange
        self.circle4.layer.cornerRadius = 5
        self.circle4.alpha = 1
        self.circle4.addTarget(self, action: #selector(self.touch4), for: .touchUpInside)
        self.switcherView.addSubview(self.circle4)
        
        self.circle5.frame = CGRect(x: 32, y: 234, width: 10, height: 10)
        self.circle5.backgroundColor = Colours.lightBlue
        self.circle5.layer.cornerRadius = 5
        self.circle5.alpha = 1
        self.circle5.addTarget(self, action: #selector(self.touch5), for: .touchUpInside)
        self.circle5.imageEdgeInsets = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
        self.switcherView.addSubview(self.circle5)
        
        self.circle6.frame = CGRect(x: 22, y: 282, width: 30, height: 30)
        self.circle6.backgroundColor = Colours.tabSelected
        self.circle6.layer.cornerRadius = 15
        self.circle6.alpha = 0
        self.circle6.setImage(UIImage(named: "moon"), for: .normal)
        self.circle6.addTarget(self, action: #selector(self.touch6), for: .touchUpInside)
        self.circle6.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        self.switcherView.addSubview(self.circle6)
        
        //arrow
        
        self.circleArrow.frame = CGRect(x: 29, y: 31, width: 16, height: 16)
        self.circleArrow.backgroundColor = Colours.clear
        self.circleArrow.alpha = 1
        self.circleArrow.image = UIImage(named: "right")?.maskWithColor(color: UIColor.white)
        self.switcherView.addSubview(self.circleArrow)
        
        //list text
        
        let colgr = "Column Grid".localized
        
        self.option1.frame = CGRect(x: 70, y: 20, width: 125, height: 40)
        self.option1.setTitle("1 \(colgr)", for: .normal)
        self.option1.setTitleColor(UIColor.white, for: .normal)
        self.option1.contentHorizontalAlignment = .left
        self.option1.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.option1.alpha = 1
        self.option1.addTarget(self, action: #selector(self.touch1), for: .touchUpInside)
        self.switcherView.addSubview(self.option1)
        
        self.option2.frame = CGRect(x: 70, y: 70, width: 125, height: 40)
        self.option2.setTitle("2 \(colgr)", for: .normal)
        self.option2.setTitleColor(UIColor.white, for: .normal)
        self.option2.contentHorizontalAlignment = .left
        self.option2.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.option2.alpha = 1
        self.option2.addTarget(self, action: #selector(self.touch2), for: .touchUpInside)
        self.switcherView.addSubview(self.option2)
        
        self.option3.frame = CGRect(x: 70, y: 120, width: 125, height: 40)
        self.option3.setTitle("3 \(colgr)", for: .normal)
        self.option3.setTitleColor(UIColor.white, for: .normal)
        self.option3.contentHorizontalAlignment = .left
        self.option3.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.option3.alpha = 1
        self.option3.addTarget(self, action: #selector(self.touch3), for: .touchUpInside)
        self.switcherView.addSubview(self.option3)
        
        self.option4.frame = CGRect(x: 70, y: 170, width: 125, height: 40)
        self.option4.setTitle("4 \(colgr)", for: .normal)
        self.option4.setTitleColor(UIColor.white, for: .normal)
        self.option4.contentHorizontalAlignment = .left
        self.option4.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.option4.alpha = 1
        self.option4.addTarget(self, action: #selector(self.touch4), for: .touchUpInside)
        self.switcherView.addSubview(self.option4)
        
        self.option5.frame = CGRect(x: 70, y: 220, width: 125, height: 40)
        self.option5.setTitle("5 \(colgr)", for: .normal)
        self.option5.setTitleColor(UIColor.white, for: .normal)
        self.option5.contentHorizontalAlignment = .left
        self.option5.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.option5.alpha = 1
        self.option5.addTarget(self, action: #selector(self.touch5), for: .touchUpInside)
        self.switcherView.addSubview(self.option5)
        
        self.option6.frame = CGRect(x: 70, y: 276, width: 125, height: 40)
        self.option6.setTitle("Toggle Theme".localized, for: .normal)
        self.option6.setTitleColor(UIColor.white, for: .normal)
        self.option6.contentHorizontalAlignment = .left
        self.option6.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.option6.alpha = 1
        self.option6.addTarget(self, action: #selector(self.touch6), for: .touchUpInside)
        self.switcherView.addSubview(self.option6)
        
        //current
        
        if UserDefaults.standard.object(forKey: "gridCol") == nil {
            selectedOption = 3
        } else {
            selectedOption = UserDefaults.standard.object(forKey: "gridCol") as! Int
        }
        if selectedOption == 1 {
            self.circleArrow.frame = CGRect(x: 29, y: 31, width: 16, height: 16)
            self.circle1.frame = CGRect(x: 22, y: 24, width: 30, height: 30)
            self.circle1.layer.cornerRadius = 15
            self.option1.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        }
        if selectedOption == 2 {
            self.circleArrow.frame = CGRect(x: 29, y: 81, width: 16, height: 16)
            self.circle2.frame = CGRect(x: 22, y: 74, width: 30, height: 30)
            self.circle2.layer.cornerRadius = 15
            self.option2.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        }
        if selectedOption == 3 {
            self.circleArrow.frame = CGRect(x: 29, y: 131, width: 16, height: 16)
            self.circle3.frame = CGRect(x: 22, y: 124, width: 30, height: 30)
            self.circle3.layer.cornerRadius = 15
            self.option3.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        }
        if selectedOption == 4 {
            self.circleArrow.frame = CGRect(x: 29, y: 181, width: 16, height: 16)
            self.circle4.frame = CGRect(x: 22, y: 174, width: 30, height: 30)
            self.circle4.layer.cornerRadius = 15
            self.option4.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        }
        if selectedOption == 5 {
            self.circleArrow.frame = CGRect(x: 29, y: 231, width: 16, height: 16)
            self.circle5.frame = CGRect(x: 22, y: 224, width: 30, height: 30)
            self.circle5.layer.cornerRadius = 15
            self.option5.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        }
        
        //animate
        
        self.switcherView.frame = CGRect(x: 10, y: fromTop, width: 0, height: 0)
        springWithDelay(duration: 0.5, delay: 0, animations: {
            self.switcherView.alpha = 1
            self.switcherView.frame = CGRect(x: 10, y: fromTop, width: 205, height: 335)
        })
        
        self.circlebg.frame = CGRect(x: 16, y: 18, width: 42, height: 0)
        springWithDelay(duration: 0.5, delay: 0, animations: {
            self.switcherView.alpha = 1
            self.circlebg.frame = CGRect(x: 16, y: 18, width: 42, height: 242)
        })
        
        springWithDelay(duration: 0.5, delay: 0.05, animations: {
            self.circle6.alpha = 1
        })
    }
    
    @objc func switchTab() {
        print("switch")
        self.viewControllers?.last?.tabBarController?.selectedIndex = 3
    }
    
    @objc func switchTabD() {
        print("switch")
        self.viewControllers?.last?.tabBarController?.selectedIndex = 2
    }
    
    @objc func switchTabDisc() {
        print("switch")
        self.viewControllers?.last?.tabBarController?.selectedIndex = 1
    }
    
    func createTabBar() {
        
        DispatchQueue.main.async {
            // Create Tab one
            self.tabOne = SloppyNavigationController(rootViewController: self.firstView)
            //let tabOne = TweetsViewController()
            let tabOneBarItem = UITabBarItem(title: "", image: UIImage(named: "bookmark"), selectedImage: UIImage(named: "bookmark"))
            tabOneBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            self.tabOne.tabBarItem = tabOneBarItem
            self.tabOne.navigationBar.backgroundColor = Colours.white
            self.tabOne.navigationBar.barTintColor = Colours.white
            self.tabOne.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.tabOne.tabBarItem.tag = 1
            //tabOne.navigationBar.shadowImage = UIImage()
            
            // Create Tab two
            self.tabTwo = SloppyNavigationController(rootViewController: self.secondView)
            //let tabTwo = MentionsViewController()
            let tabTwoBarItem2 = UITabBarItem(title: "", image: UIImage(named: "scope"), selectedImage: UIImage(named: "scope"))
            tabTwoBarItem2.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            self.tabTwo.tabBarItem = tabTwoBarItem2
            self.tabTwo.navigationBar.backgroundColor = Colours.white
            self.tabTwo.navigationBar.barTintColor = Colours.white
            self.tabTwo.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.tabTwo.tabBarItem.tag = 2
            //tabTwo.navigationBar.shadowImage = UIImage()
            
            // Create Tab three
            self.tabThree = SloppyNavigationController(rootViewController: self.thirdView)
            //let tabThree = MessageViewController()
            let tabThreeBarItem = UITabBarItem(title: "", image: UIImage(named: "list"), selectedImage: UIImage(named: "list"))
            tabThreeBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            self.tabThree.tabBarItem = tabThreeBarItem
            self.tabThree.navigationBar.backgroundColor = Colours.white
            self.tabThree.navigationBar.barTintColor = Colours.white
            self.tabThree.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.tabThree.tabBarItem.tag = 3
            //tabThree.navigationBar.shadowImage = UIImage()
            
            // Create Tab four
            self.tabFour = SloppyNavigationController(rootViewController: self.fourthView)
            //let tabFour = ProfileViewController()
            let tabFourBarItem = UITabBarItem(title: "", image: UIImage(named: "play"), selectedImage: UIImage(named: "play"))
            tabFourBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            self.tabFour.tabBarItem = tabFourBarItem
            self.tabFour.navigationBar.backgroundColor = Colours.white
            self.tabFour.navigationBar.barTintColor = Colours.white
            self.tabFour.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.tabFour.tabBarItem.tag = 4
            //tabFour.navigationBar.shadowImage = UIImage()
            
            let viewControllerList = [self.tabOne, self.tabTwo, self.tabThree, self.tabFour]
            
            for x in viewControllerList {
                
                if UIDevice().userInterfaceIdiom == .phone {
                    switch UIScreen.main.nativeBounds.height {
                    case 2688:
                        print("iPhone Xs Max")
                        
                        self.bgView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 88)
                        self.bgView.backgroundColor = Colours.cellNorm
                        self.navigationController?.view.addSubview(self.bgView)
                        
                        let topIcon = UIButton(frame:(CGRect(x: self.view.bounds.width/2 - 100, y: 50, width: 200, height: 30)))
                        //topIcon.setImage(UIImage(named: "IconSmall"), for: .normal)
                        //topIcon.setTitle(titleToGo, for: .normal)
                        topIcon.setTitleColor(Colours.grayDark, for: .normal)
                        topIcon.adjustsImageWhenHighlighted = false
                        //topIcon.addTarget(self, action: #selector(self.didTouchMiddle), for: .touchUpInside)
                        //let longPressRecognizer1 = UILongPressGestureRecognizer(target: self, action: #selector(self.recognizerFiredNav))
                        //longPressRecognizer1.minimumPressDuration = 0.25
                        //topIcon.addGestureRecognizer(longPressRecognizer1)
                        self.navigationController?.view.addSubview(topIcon)
                        
                        self.settingsButton = MNGExpandedTouchAreaButton(frame:(CGRect(x: 15, y: 47, width: 32, height: 32)))
                        self.settingsButton.setImage(UIImage(named: "grid")?.maskWithColor(color: Colours.grayLight2), for: .normal)
                        self.settingsButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                        self.settingsButton.adjustsImageWhenHighlighted = false
                        self.settingsButton.addTarget(self, action: #selector(self.touchGrid), for: .touchUpInside)
                        //self.navigationController?.view.addSubview(settingsButton)
                        
                        self.searchButton = MNGExpandedTouchAreaButton(frame:(CGRect(x: self.view.bounds.width - 50, y: 49, width: 32, height: 32)))
                        self.searchButton.setImage(UIImage(named: "search")?.maskWithColor(color: Colours.grayLight2), for: .normal)
                        self.searchButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                        self.searchButton.adjustsImageWhenHighlighted = false
                        self.searchButton.addTarget(self, action: #selector(self.didTouchSearch), for: .touchUpInside)
                        //self.navigationController?.view.addSubview(self.searchButton)
                        
                        x.view.addSubview(topIcon)
                        x.view.addSubview(self.settingsButton)
                        x.view.addSubview(self.searchButton)
                        
                    case 2436:
                        print("iPhone X")
                        
                        self.bgView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 88)
                        self.bgView.backgroundColor = Colours.cellNorm
                        self.navigationController?.view.addSubview(self.bgView)
                        
                        let topIcon = UIButton(frame:(CGRect(x: self.view.bounds.width/2 - 100, y: 50, width: 200, height: 30)))
                        //topIcon.setImage(UIImage(named: "IconSmall"), for: .normal)
                        //topIcon.setTitle(titleToGo, for: .normal)
                        topIcon.setTitleColor(Colours.grayDark, for: .normal)
                        topIcon.adjustsImageWhenHighlighted = false
                        //topIcon.addTarget(self, action: #selector(self.didTouchMiddle), for: .touchUpInside)
                        //let longPressRecognizer1 = UILongPressGestureRecognizer(target: self, action: #selector(self.recognizerFiredNav))
                        //longPressRecognizer1.minimumPressDuration = 0.25
                        //topIcon.addGestureRecognizer(longPressRecognizer1)
                        self.navigationController?.view.addSubview(topIcon)
                        
                        self.settingsButton = MNGExpandedTouchAreaButton(frame:(CGRect(x: 15, y: 47, width: 32, height: 32)))
                        self.settingsButton.setImage(UIImage(named: "grid")?.maskWithColor(color: Colours.grayLight2), for: .normal)
                        self.settingsButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                        self.settingsButton.adjustsImageWhenHighlighted = false
                        self.settingsButton.addTarget(self, action: #selector(self.touchGrid), for: .touchUpInside)
                        //self.navigationController?.view.addSubview(settingsButton)
                        
                        self.searchButton = MNGExpandedTouchAreaButton(frame:(CGRect(x: self.view.bounds.width - 50, y: 49, width: 32, height: 32)))
                        self.searchButton.setImage(UIImage(named: "search")?.maskWithColor(color: Colours.grayLight2), for: .normal)
                        self.searchButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                        self.searchButton.adjustsImageWhenHighlighted = false
                        self.searchButton.addTarget(self, action: #selector(self.didTouchSearch), for: .touchUpInside)
                        //self.navigationController?.view.addSubview(self.searchButton)
                        
                        x.view.addSubview(topIcon)
                        x.view.addSubview(self.settingsButton)
                        x.view.addSubview(self.searchButton)
                        
                    default:
                        
                        self.bgView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 64)
                        self.bgView.backgroundColor = Colours.cellNorm
                        self.navigationController?.view.addSubview(self.bgView)
                        
                        let topIcon = UIButton(frame:(CGRect(x: self.view.bounds.width/2 - 100, y: 26, width: 200, height: 30)))
                        //topIcon.setImage(UIImage(named: "IconSmall"), for: .normal)
                        //topIcon.setTitle(titleToGo, for: .normal)
                        topIcon.setTitleColor(Colours.grayDark, for: .normal)
                        topIcon.adjustsImageWhenHighlighted = false
                        //topIcon.addTarget(self, action: #selector(self.didTouchMiddle), for: .touchUpInside)
                        //let longPressRecognizer1 = UILongPressGestureRecognizer(target: self, action: #selector(self.recognizerFiredNav))
                        //longPressRecognizer1.minimumPressDuration = 0.25
                        //topIcon.addGestureRecognizer(longPressRecognizer1)
                        self.navigationController?.view.addSubview(topIcon)
                        
                        self.settingsButton = MNGExpandedTouchAreaButton(frame:(CGRect(x: 15, y: 24, width: 32, height: 35)))
                        self.settingsButton.setImage(UIImage(named: "grid")?.maskWithColor(color: Colours.grayLight2), for: .normal)
                        self.settingsButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                        self.settingsButton.adjustsImageWhenHighlighted = false
                        self.settingsButton.addTarget(self, action: #selector(self.touchGrid), for: .touchUpInside)
                        //self.navigationController?.view.addSubview(settingsButton)
                        
                        self.searchButton = MNGExpandedTouchAreaButton(frame:(CGRect(x: self.view.bounds.width - 50, y: 26, width: 32, height: 32)))
                        self.searchButton.setImage(UIImage(named: "search")?.maskWithColor(color: Colours.grayLight2), for: .normal)
                        self.searchButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                        self.searchButton.adjustsImageWhenHighlighted = false
                        self.searchButton.addTarget(self, action: #selector(self.didTouchSearch), for: .touchUpInside)
                        //self.navigationController?.view.addSubview(self.searchButton)
                        
                        x.view.addSubview(topIcon)
                        x.view.addSubview(self.settingsButton)
                        x.view.addSubview(self.searchButton)
                        
                    }
                }
                
            }
            
            self.viewControllers = viewControllerList
            
        }
    }
    
}

extension UIImage {
    
    public func maskWithColor(color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        color.setFill()
        self.draw(in: rect)
        
        context.setBlendMode(.sourceIn)
        context.fill(rect)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage
    }
    
}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}

class MNGExpandedTouchAreaButton: UIButton {
    
    var margin:CGFloat = 10.0
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let area = self.bounds.insetBy(dx: -margin, dy: -margin)
        return area.contains(point)
    }
    
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
