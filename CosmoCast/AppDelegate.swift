//
//  AppDelegate.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 01/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import UIKit
import Disk
import FeedKit
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == "Dynamic01" {
            print("play")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "toPlay"), object: self, userInfo: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "switch"), object: self)
            
            completionHandler(true)
        } else if shortcutItem.type == "Dynamic02" {
            print("play next")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "plaNext"), object: self, userInfo: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "switch"), object: self)
            
            completionHandler(true)
        } else {
            completionHandler(false)
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == "com.shi.Cosmo.play" {
            let viewController = window?.rootViewController as! ViewController
            viewController.siriShort()
        } else if userActivity.activityType == "com.shi.Cosmo.light" {
            let viewController = window?.rootViewController as! ViewController
            viewController.siriLight()
        } else if userActivity.activityType == "com.shi.Cosmo.dark" {
            let viewController = window?.rootViewController as! ViewController
            viewController.siriDark()
        } else {
            let viewController = window?.rootViewController as! ViewController
            viewController.siriOled()
        }
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "816f2212-65eb-49e8-9814-0f1515f88011",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        BarButtonItemAppearance.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -600, vertical: 4), for:UIBarMetrics.default)
        BarButtonItemAppearance.tintColor = Colours.clear
        
        window?.tintColor = Colours.tabSelected
        
        do {
            let retrieved = try Disk.retrieve("bookmarked.json", from: .documents, as: [Podcast].self)
            StoreStruct.bookmarkedPodcast = retrieved
            
            let retrieved2 = try Disk.retrieve("podcastdownload.json", from: .documents, as: [Podcast].self)
            StoreStruct.downloadPodcast = retrieved2
            
            let retrieved3 = try Disk.retrieve("episodedownload.json", from: .documents, as: [Episode].self)
            StoreStruct.downloadEpisode = retrieved3
            
            let retrieved4 = try Disk.retrieve("sendpodcast.json", from: .documents, as: [Podcast].self)
            StoreStruct.sendPodcast = retrieved4
            
            let retrieved5 = try Disk.retrieve("playdrawer.json", from: .documents, as: [Episode].self)
            StoreStruct.playDrawerEpisode = retrieved5
            
            if StoreStruct.playDrawerEpisode.isEmpty {} else {
                StoreStruct.isPlaying = false
                StoreStruct.isPlayingInitial = false
                StoreStruct.playEpisode = [StoreStruct.playDrawerEpisode[0]]
                StoreStruct.playPodcast = [StoreStruct.sendPodcast[0]]
                StoreStruct.playArtist = StoreStruct.sendPodcast[0].artistName ?? ""
                StoreStruct.mainImage = StoreStruct.sendPodcast[0].artworkUrl600 ?? ""
                StoreStruct.playDrawerPodcast = [StoreStruct.sendPodcast[0]]
                StoreStruct.playDrawerArtist = StoreStruct.sendPodcast[0].artistName ?? ""
                StoreStruct.mainDrawerImage = StoreStruct.sendPodcast[0].artworkUrl600 ?? ""
            }
        } catch {
            print("error")
        }
        if UserDefaults.standard.object(forKey: "backSkip") == nil || UserDefaults.standard.object(forKey: "forwardSkip") == nil {} else {
            StoreStruct.leftSkip = UserDefaults.standard.object(forKey: "backSkip") as! Int
            StoreStruct.rightSkip = UserDefaults.standard.object(forKey: "forwardSkip") as! Int
        }
        if UserDefaults.standard.object(forKey: "speed") == nil {} else {
            StoreStruct.playbackSpeed = UserDefaults.standard.object(forKey: "speed") as! Float
        }
        if UserDefaults.standard.object(forKey: "country") == nil {} else {
            StoreStruct.country = UserDefaults.standard.object(forKey: "country") as! String
        }
        if UserDefaults.standard.object(forKey: "countryFull") == nil {} else {
            StoreStruct.countryFull = UserDefaults.standard.object(forKey: "countryFull") as! String
        }
        if UserDefaults.standard.object(forKey: "mainImage") == nil {} else {
            StoreStruct.mainImage = UserDefaults.standard.object(forKey: "mainImage") as! String
            StoreStruct.mainDrawerImage = UserDefaults.standard.object(forKey: "mainImage") as! String
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url)
        
        DispatchQueue.global(qos: .userInteractive).async {
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return }
        
        let datasource = FeedImporterDatasourceAEXML(data: data)
        
        for xyz in datasource.urls! {
            let parser = FeedParser(URL: xyz)
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
                    let fee = xyz.absoluteString
                    let gen = feed.iTunes?.iTunesCategories?[0].attributes?.text
                    let adv = feed.iTunes?.iTunesExplicit
                    let singlePodcast = Podcast.init(track: tr, artist: ar, artwork: aw, count: co, feedURL: fee, genre: gen, rating: adv)
                    StoreStruct.tappedFeedURL = fee
                    StoreStruct.sendPodcast = [singlePodcast]
                    StoreStruct.bookmarkedPodcast.append(StoreStruct.sendPodcast[0])
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "column"), object: self)
                }
            })
        }
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        do {
            let x = StoreStruct.bookmarkedPodcast
            try Disk.save(x, to: .documents, as: "bookmarked.json")
            let x2 = StoreStruct.downloadEpisode
            try Disk.save(x2, to: .documents, as: "episodedownload.json")
            let x3 = StoreStruct.downloadPodcast
            try Disk.save(x3, to: .documents, as: "podcastdownload.json")
            let x4 = StoreStruct.sendPodcast
            try Disk.save(x4, to: .documents, as: "sendpodcast.json")
            let x5 = StoreStruct.playDrawerEpisode
            try Disk.save(x5, to: .documents, as: "playdrawer.json")
        } catch {
            print("error")
        }
        
        UserDefaults.standard.set(StoreStruct.leftSkip, forKey: "backSkip")
        UserDefaults.standard.set(StoreStruct.rightSkip, forKey: "forwardSkip")
        UserDefaults.standard.set(StoreStruct.playbackSpeed, forKey: "speed")
        UserDefaults.standard.set(StoreStruct.country, forKey: "country")
        UserDefaults.standard.set(StoreStruct.countryFull, forKey: "countryFull")
        UserDefaults.standard.set(StoreStruct.mainImage, forKey: "mainImage")
        
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

