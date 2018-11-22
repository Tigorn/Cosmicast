//
//  MoreViewController.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 01/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import PINRemoteImage
import AVKit
import MediaPlayer
import StatusAlert
import SafariServices

class PlayerViewController: UIViewController, SFSafariViewControllerDelegate {
    
    var mainImageViewBG = UIImageView()
    var mainImageView = UIImageView()
    var playButton = UIButton(type: .custom)
    var avPlayer: AVPlayer?
    var avPlayerItem: AVPlayerItem?
    var isPlaying = false
    var timer: Timer? = nil
    var sleepTimer: Timer? = nil
    var lowerLab = UILabel()
    var upperLab = UILabel()
    var slider = CustomUISlider()
    var titleLab = MarqueeLabel()
    var forwardSkip = UIButton()
    var backwardSkip = UIButton()
    var backgroundView = UIButton()
    var playbackView = UIView()
    var isPlaybackInvoked = false
    var moreButton = UIButton()
    var isSleepTimerActive = false
    var playerLayer: AVPlayerLayer = AVPlayerLayer()
    var isThisVideo = false
    var wasLandscape = false
    
    var option1 = UIButton()
    var option2 = UIButton()
    var option3 = UIButton()
    var option4 = UIButton()
    var option5 = UIButton()
    var fromLeftSkip = true
    var fromSpeed = false
    
    func removeTabbarItemsText() {
        if let items = tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
                item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0);
            }
        }
    }
    
    @objc func playA() {
        avPlayer?.play()
    }
    
    @objc func pauseA() {
        avPlayer?.pause()
    }
    
    @objc func backA() {
        let dur1: CMTime = self.avPlayerItem!.currentTime()
        let a1 = CMTimeGetSeconds(dur1)
        let a2 = a1 - Double(StoreStruct.leftSkip)
        let targetTime:CMTime = CMTimeMake(value: Int64(a2), timescale: 1)
        self.avPlayer!.seek(to: targetTime)
    }
    
    @objc func forwardA() {
        let dur1: CMTime = self.avPlayerItem!.currentTime()
        let a1 = CMTimeGetSeconds(dur1)
        let a2 = a1 + Double(StoreStruct.rightSkip)
        let targetTime:CMTime = CMTimeMake(value: Int64(a2), timescale: 1)
        self.avPlayer!.seek(to: targetTime)
    }
    
    @objc func sliderA(notification: NSNotification) {
        if let sec = notification.userInfo?["sec"] as? Int64 {
            let targetTime:CMTime = CMTimeMake(value: sec, timescale: 1)
        
            self.avPlayer!.seek(to: targetTime)
            if avPlayer!.rate == 0 && self.isPlaying {
                avPlayer?.play()
            }
        }
    }
    
    @objc func reload() {
        self.loadWill()
        self.reloadAll()
    }
    
    @objc func rotated() {
        var offset = 88
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                offset = 64
            case 2688:
                offset = 88
            case 2436:
                offset = 88
            default:
                offset = 64
            }
        }
        
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            self.wasLandscape = true
            if self.isThisVideo == true {
                print("landscapevid")
                let xy = UIView()
                xy.frame = (self.navigationController?.view.bounds)!
                xy.backgroundColor = UIColor.black
                UIApplication.shared.keyWindow?.addSubview(xy)
                self.playerLayer.bringToFront()
                self.playerLayer.transform = CATransform3DMakeRotation(90.0 / 180.0 * .pi, 0.0, 0.0, 1.0)
                self.playerLayer.frame = self.view.frame
                self.playerLayer.videoGravity = .resizeAspectFill
            }
        } else {
            print("Portrait")
            if self.isThisVideo == true && self.wasLandscape == true {
                print("portraitvid")
                self.playerLayer.transform = CATransform3DMakeRotation(0, 0.0, 0.0, 1.0)
                self.playerLayer.frame = CGRect(x: 0, y: Int(offset + 30), width: Int(self.view.bounds.width), height: Int(self.view.bounds.width - 80))
                self.playerLayer.videoGravity = .resizeAspect
            }
        }
    }
    
    @objc func toPlay() {
        self.tPlay()
    }
    
    @objc func plaNext() {
        self.plNext()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadLoadLoad()
        self.title = ""
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "reload"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playA), name: NSNotification.Name(rawValue: "playA"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.pauseA), name: NSNotification.Name(rawValue: "pauseA"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.forwardA), name: NSNotification.Name(rawValue: "forwardA"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.backA), name: NSNotification.Name(rawValue: "backA"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sliderA), name: NSNotification.Name(rawValue: "sliderA"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.toPlay), name: NSNotification.Name(rawValue: "toPlay"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.plaNext), name: NSNotification.Name(rawValue: "plaNext"), object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
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
        
        
        let mpRemoteControlCenter = MPRemoteCommandCenter.shared()
        mpRemoteControlCenter.skipForwardCommand.isEnabled = true
        mpRemoteControlCenter.skipForwardCommand.addTarget(self, action: #selector(self.nextTrack))
        mpRemoteControlCenter.skipBackwardCommand.isEnabled = true
        mpRemoteControlCenter.skipBackwardCommand.addTarget(self, action: #selector(self.prevTrack))
        mpRemoteControlCenter.pauseCommand.isEnabled = true
        mpRemoteControlCenter.pauseCommand.addTarget(self, action: #selector(self.pause))
        mpRemoteControlCenter.playCommand.isEnabled = true
        mpRemoteControlCenter.playCommand.addTarget(self, action: #selector(self.play))
        //mpRemoteControlCenter.changePlaybackPositionCommand.isEnabled = true
        //mpRemoteControlCenter.changePlaybackPositionCommand.addTarget(self, action: #selector(self.changePlaybackPositionCommand(_:)))
        //mpRemoteControlCenter.togglePlayPauseCommand.isEnabled = true
        //mpRemoteControlCenter.togglePlayPauseCommand.addTarget(self, action: #selector(self.playPause))
        
        
        
        if #available(iOS 11.0, *) {
            var AirPlayButton : AVRoutePickerView!
            AirPlayButton = AVRoutePickerView(frame: CGRect(x: Int(self.view.bounds.width/2 - 25), y: Int(offset - 47), width: 50, height: 50))
            AirPlayButton.activeTintColor = Colours.tabSelected
            AirPlayButton.tintColor = Colours.grayLight2
            self.navigationController?.view.addSubview(AirPlayButton)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func changePlaybackPositionCommand(_ event:MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus {
        let time = event.positionTime
        print("poiuytre")
        print(time)
        //use time to update your track time
        let seconds: Int64 = Int64(time)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        self.avPlayer!.seek(to: targetTime)
        if avPlayer!.rate == 0 && self.isPlaying {
            avPlayer?.play()
        }
        return MPRemoteCommandHandlerStatus.success;
    }
    
    func setNowPlayingMediaWith(current: Double, upper: Double) {
        if StoreStruct.playEpisode.isEmpty {} else {
        guard let url = URL(string: StoreStruct.mainImage) else { return }
        let data = try? Data(contentsOf: url)
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = StoreStruct.playEpisode[0].title
        nowPlayingInfo[MPMediaItemPropertyArtist] = StoreStruct.playArtist
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 100, height: 100)) { size in
            return UIImage(data: data ?? Data()) ?? UIImage()
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = current
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = upper
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: 1)
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = NSNumber(value: MPNowPlayingInfoMediaType.audio.rawValue)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
    
    @objc func position(_ event: MPChangePlaybackPositionCommandEvent) {
        print("position")
        print(event)
        let seconds: Int64 = Int64(event.positionTime)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        print("popo")
        print(targetTime)
        self.avPlayer!.seek(to: targetTime)
//        if avPlayer!.rate == 0 && self.isPlaying {
//            avPlayer?.play()
//        }
    }
    @objc func playPause() {
        print("play pause")
        
        var tabHeight = Int(UITabBarController().tabBar.frame.size.height) + Int(34)
        var offset = 88
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                offset = 64
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
            avPlayer?.pause()
            self.isPlaying = false
            StoreStruct.isPlaying = false
            self.playButton.setImage(UIImage(named: "play")?.maskWithColor(color: Colours.tabSelected), for: .normal)
            springWithDelay(duration: 0.4, delay: 0, animations: {
                self.mainImageView.frame = CGRect(x: 40, y: Int(offset + 25), width: Int(self.view.bounds.width - 80), height: Int(self.view.bounds.width - 80))
                self.mainImageViewBG.frame = self.mainImageView.frame
                self.mainImageViewBG.layer.shadowOffset = CGSize(width:0, height:3)
                self.mainImageViewBG.layer.shadowRadius = 16
                self.mainImageViewBG.layer.shadowOpacity = 0.28
            })
        } else {
            avPlayer?.play()
            self.isPlaying = true
            StoreStruct.isPlaying = true
            self.playButton.setImage(UIImage(named: "pause")?.maskWithColor(color: Colours.tabSelected), for: .normal)
            springWithDelay(duration: 0.4, delay: 0, animations: {
                self.mainImageView.frame = CGRect(x: 20, y: Int(offset + 5), width: Int(self.view.bounds.width - 40), height: Int(self.view.bounds.width - 40))
                self.mainImageViewBG.frame = self.mainImageView.frame
                self.mainImageViewBG.layer.shadowOffset = CGSize(width:0, height:15)
                self.mainImageViewBG.layer.shadowRadius = 15
                self.mainImageViewBG.layer.shadowOpacity = 0.15
            })
        }
        
    }
    @objc func pause() {
        print("pause")
        
        var tabHeight = Int(UITabBarController().tabBar.frame.size.height) + Int(34)
        var offset = 88
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                offset = 64
            case 2688:
                offset = 88
            case 2436:
                offset = 88
            default:
                offset = 64
                tabHeight = Int(UITabBarController().tabBar.frame.size.height)
            }
        }
        avPlayer?.pause()
        self.isPlaying = false
        StoreStruct.isPlaying = false
        self.playButton.setImage(UIImage(named: "play")?.maskWithColor(color: Colours.tabSelected), for: .normal)
        springWithDelay(duration: 0.4, delay: 0, animations: {
            self.mainImageView.frame = CGRect(x: 40, y: Int(offset + 25), width: Int(self.view.bounds.width - 80), height: Int(self.view.bounds.width - 80))
            self.mainImageViewBG.frame = self.mainImageView.frame
            self.mainImageViewBG.layer.shadowOffset = CGSize(width:0, height:3)
            self.mainImageViewBG.layer.shadowRadius = 16
            self.mainImageViewBG.layer.shadowOpacity = 0.28
        })
    }
    @objc func play() {
        print("play")
        
        var tabHeight = Int(UITabBarController().tabBar.frame.size.height) + Int(34)
        var offset = 88
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                offset = 64
            case 2688:
                offset = 88
            case 2436:
                offset = 88
            default:
                offset = 64
                tabHeight = Int(UITabBarController().tabBar.frame.size.height)
            }
        }
        avPlayer?.play()
        self.isPlaying = true
        StoreStruct.isPlaying = true
        self.playButton.setImage(UIImage(named: "pause")?.maskWithColor(color: Colours.tabSelected), for: .normal)
        springWithDelay(duration: 0.4, delay: 0, animations: {
            self.mainImageView.frame = CGRect(x: 20, y: Int(offset + 5), width: Int(self.view.bounds.width - 40), height: Int(self.view.bounds.width - 40))
            self.mainImageViewBG.frame = self.mainImageView.frame
            self.mainImageViewBG.layer.shadowOffset = CGSize(width:0, height:15)
            self.mainImageViewBG.layer.shadowRadius = 15
            self.mainImageViewBG.layer.shadowOpacity = 0.15
        })
    }
    @objc func nextTrack(){
        print("next")
        
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
        let dur1: CMTime = self.avPlayerItem!.currentTime()
        let a1 = CMTimeGetSeconds(dur1)
        let a2 = a1 + Double(StoreStruct.rightSkip)
        let targetTime:CMTime = CMTimeMake(value: Int64(a2), timescale: 1)
        self.avPlayer!.seek(to: targetTime)
    }
    @objc func prevTrack() {
        print("prev")
        
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
        let dur1: CMTime = self.avPlayerItem!.currentTime()
        let a1 = CMTimeGetSeconds(dur1)
        let a2 = a1 - Double(StoreStruct.leftSkip)
        let targetTime:CMTime = CMTimeMake(value: Int64(a2), timescale: 1)
        self.avPlayer!.seek(to: targetTime)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadWill()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    func loadWill() {
        
        self.removeTabbarItemsText()
        
        var tabHeight = Int(UITabBarController().tabBar.frame.size.height) + Int(34)
        var offset = 88
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                offset = 64
            case 2688:
                offset = 88
            case 2436:
                offset = 88
            default:
                offset = 64
                tabHeight = Int(UITabBarController().tabBar.frame.size.height)
            }
        }
        
        let wid = self.view.bounds.width - 40
        
        //mainimagewashere
        
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                self.playButton.frame = CGRect(x: Int(self.view.bounds.width/2) - 35, y: Int(offset) + Int(self.view.bounds.width - 40) + 85, width: 70, height: 70)
                self.playButton.layer.cornerRadius = 35
                self.playButton.layer.shadowColor = UIColor.black.cgColor
                self.playButton.layer.shadowOffset = CGSize(width:0, height:8)
                self.playButton.layer.shadowRadius = 10
                self.playButton.layer.shadowOpacity = 0.1
            case 2688:
                self.playButton.frame = CGRect(x: Int(self.view.bounds.width/2) - 50, y: Int(offset + 25) + Int(self.view.bounds.width - 40) + 130, width: 100, height: 100)
                self.playButton.layer.cornerRadius = 50
                self.playButton.layer.shadowColor = UIColor.black.cgColor
                self.playButton.layer.shadowOffset = CGSize(width:0, height:11)
                self.playButton.layer.shadowRadius = 14
                self.playButton.layer.shadowOpacity = 0.1
            case 2436:
                self.playButton.frame = CGRect(x: Int(self.view.bounds.width/2) - 50, y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 130, width: 100, height: 100)
                self.playButton.layer.cornerRadius = 50
                self.playButton.layer.shadowColor = UIColor.black.cgColor
                self.playButton.layer.shadowOffset = CGSize(width:0, height:11)
                self.playButton.layer.shadowRadius = 14
                self.playButton.layer.shadowOpacity = 0.1
            case 2208:
                self.playButton.frame = CGRect(x: Int(self.view.bounds.width/2) - 40, y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 130, width: 80, height: 80)
                self.playButton.layer.cornerRadius = 40
                self.playButton.layer.shadowColor = UIColor.black.cgColor
                self.playButton.layer.shadowOffset = CGSize(width:0, height:8)
                self.playButton.layer.shadowRadius = 10
                self.playButton.layer.shadowOpacity = 0.1
            default:
                self.playButton.frame = CGRect(x: Int(self.view.bounds.width/2) - 35, y: Int(offset) + Int(self.view.bounds.width - 40) + 130, width: 70, height: 70)
                self.playButton.layer.cornerRadius = 35
                self.playButton.layer.shadowColor = UIColor.black.cgColor
                self.playButton.layer.shadowOffset = CGSize(width:0, height:8)
                self.playButton.layer.shadowRadius = 10
                self.playButton.layer.shadowOpacity = 0.1
            }
        }
        self.playButton.backgroundColor = Colours.playButtonWhite
        if StoreStruct.isPlaying {
            self.playButton.setImage(UIImage(named: "pause")?.maskWithColor(color: Colours.tabSelected), for: .normal)
        } else {
            self.playButton.setImage(UIImage(named: "play")?.maskWithColor(color: Colours.tabSelected), for: .normal)
        }
        self.playButton.addTarget(self, action: #selector(self.touchPlay), for: .touchUpInside)
        let longHold0 = UILongPressGestureRecognizer(target: self, action: #selector(longPressedPlay))
        longHold0.minimumPressDuration = 0.4
        self.playButton.tag = 0
        self.playButton.addGestureRecognizer(longHold0)
        self.view.addSubview(self.playButton)
        
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                self.backwardSkip.frame = CGRect(x: Int(self.view.bounds.width/4) - 25, y: Int(offset) + Int(self.view.bounds.width - 40) + 103, width: 35, height: 35)
            case 2688:
                self.backwardSkip.frame = CGRect(x: Int(self.view.bounds.width/4) - 40, y: Int(offset + 25) + Int(self.view.bounds.width - 40) + 155, width: 50, height: 50)
            case 2436:
                self.backwardSkip.frame = CGRect(x: Int(self.view.bounds.width/4) - 40, y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 155, width: 50, height: 50)
            case 2208:
                self.backwardSkip.frame = CGRect(x: Int(self.view.bounds.width/4) - 25, y: Int(offset + 7) + Int(self.view.bounds.width - 40) + 148, width: 35, height: 35)
            default:
                self.backwardSkip.frame = CGRect(x: Int(self.view.bounds.width/4) - 25, y: Int(offset) + Int(self.view.bounds.width - 40) + 148, width: 35, height: 35)
            }
        }
        self.backwardSkip.backgroundColor = Colours.clear
        self.backwardSkip.layer.cornerRadius = 25
        self.backwardSkip.setTitle("\(StoreStruct.leftSkip)", for: .normal)
        self.backwardSkip.setTitleColor(Colours.tabSelected, for: .normal)
        self.backwardSkip.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        self.backwardSkip.addTarget(self, action: #selector(self.touchBack), for: .touchUpInside)
        let longHold = UILongPressGestureRecognizer(target: self, action: #selector(longPressedBack))
        longHold.minimumPressDuration = 0.4
        self.backwardSkip.tag = 0
        self.backwardSkip.addGestureRecognizer(longHold)
        self.view.addSubview(self.backwardSkip)
        
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                self.forwardSkip.frame = CGRect(x: Int(self.view.bounds.width/4)*3 - 10, y: Int(offset) + Int(self.view.bounds.width - 40) + 103, width: 35, height: 35)
            case 2688:
                self.forwardSkip.frame = CGRect(x: Int(self.view.bounds.width/4)*3 - 10, y: Int(offset + 25) + Int(self.view.bounds.width - 40) + 155, width: 50, height: 50)
            case 2436:
                self.forwardSkip.frame = CGRect(x: Int(self.view.bounds.width/4)*3 - 10, y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 155, width: 50, height: 50)
            case 2208:
                self.forwardSkip.frame = CGRect(x: Int(self.view.bounds.width/4)*3 - 10, y: Int(offset + 7) + Int(self.view.bounds.width - 40) + 148, width: 35, height: 35)
            default:
                self.forwardSkip.frame = CGRect(x: Int(self.view.bounds.width/4)*3 - 10, y: Int(offset) + Int(self.view.bounds.width - 40) + 148, width: 35, height: 35)
            }
        }
        self.forwardSkip.backgroundColor = Colours.clear
        self.forwardSkip.layer.cornerRadius = 25
        self.forwardSkip.setTitle("\(StoreStruct.rightSkip)", for: .normal)
        self.forwardSkip.setTitleColor(Colours.tabSelected, for: .normal)
        self.forwardSkip.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        self.forwardSkip.addTarget(self, action: #selector(self.touchForward), for: .touchUpInside)
        let longHold2 = UILongPressGestureRecognizer(target: self, action: #selector(longPressedForward))
        longHold2.minimumPressDuration = 0.4
        self.forwardSkip.tag = 1
        self.forwardSkip.addGestureRecognizer(longHold2)
        self.view.addSubview(self.forwardSkip)
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688:
                self.moreButton.frame = CGRect(x: Int(self.view.bounds.width/2) - 25, y: Int(offset + 35) + Int(self.view.bounds.width - 40) + 240, width: 50, height: 50)
            default:
                self.moreButton.frame = CGRect(x: Int(self.view.bounds.width/2) - 25, y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 240, width: 50, height: 50)
            }
        }
        self.moreButton.backgroundColor = Colours.clear
        self.moreButton.layer.cornerRadius = 25
        self.moreButton.setImage(UIImage(named: "more")?.maskWithColor(color: Colours.grayLight2), for: .normal)
        self.moreButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        self.moreButton.addTarget(self, action: #selector(self.tapMore), for: .touchUpInside)
        self.view.addSubview(self.moreButton)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer?.currentItem)
        
        
        self.lowerLab.alpha = 0
        self.upperLab.alpha = 0
        self.slider.alpha = 0
        self.titleLab.alpha = 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.setNowPlayingMediaWith(current: self.avPlayerItem?.currentTime().seconds ?? 0, upper: self.avPlayerItem?.asset.duration.seconds ?? 0)
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        
        var tabHeight = Int(UITabBarController().tabBar.frame.size.height) + Int(34)
        var offset = 88
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                offset = 64
            case 2688:
                offset = 88
            case 2436:
                offset = 88
            default:
                offset = 64
                tabHeight = Int(UITabBarController().tabBar.frame.size.height)
            }
        }
        
        
        if StoreStruct.endOfEp == true {
            StoreStruct.endOfEp = false
            avPlayer?.pause()
            self.isPlaying = false
            StoreStruct.isPlaying = false
            self.playButton.setImage(UIImage(named: "play")?.maskWithColor(color: Colours.tabSelected), for: .normal)
            springWithDelay(duration: 0.4, delay: 0, animations: {
                self.mainImageView.frame = CGRect(x: 40, y: Int(offset + 25), width: Int(self.view.bounds.width - 80), height: Int(self.view.bounds.width - 80))
                self.mainImageViewBG.frame = self.mainImageView.frame
                self.mainImageViewBG.layer.shadowOffset = CGSize(width:0, height:3)
                self.mainImageViewBG.layer.shadowRadius = 16
                self.mainImageViewBG.layer.shadowOpacity = 0.28
            })
            
        } else {
        
        
        
        StoreStruct.currentPlaylist = StoreStruct.currentPlaylist + 1
        if StoreStruct.currentPlaylist < StoreStruct.downloadEpisode.count {
            
            StoreStruct.isPlaying = false
            StoreStruct.isPlayingInitial = false
            StoreStruct.playEpisode = [StoreStruct.downloadEpisode[StoreStruct.currentPlaylist]]
            StoreStruct.playPodcast = [StoreStruct.downloadPodcast[StoreStruct.currentPlaylist]]
            StoreStruct.playArtist = StoreStruct.downloadPodcast[StoreStruct.currentPlaylist].artistName ?? ""
            StoreStruct.mainImage = StoreStruct.downloadPodcast[StoreStruct.currentPlaylist].artworkUrl600 ?? ""
            
            StoreStruct.playDrawerEpisode = StoreStruct.downloadEpisode
            StoreStruct.playDrawerPodcast = [StoreStruct.downloadPodcast[StoreStruct.currentPlaylist]]
            StoreStruct.playDrawerArtist = StoreStruct.downloadPodcast[StoreStruct.currentPlaylist].artistName ?? ""
            StoreStruct.mainDrawerImage = StoreStruct.downloadPodcast[StoreStruct.currentPlaylist].artworkUrl600 ?? ""
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: self)
            
        } else {
            avPlayer?.pause()
            self.isPlaying = false
            StoreStruct.isPlaying = false
            self.playButton.setImage(UIImage(named: "play")?.maskWithColor(color: Colours.tabSelected), for: .normal)
            springWithDelay(duration: 0.4, delay: 0, animations: {
                self.mainImageView.frame = CGRect(x: 40, y: Int(offset + 25), width: Int(self.view.bounds.width - 80), height: Int(self.view.bounds.width - 80))
                self.mainImageViewBG.frame = self.mainImageView.frame
                self.mainImageViewBG.layer.shadowOffset = CGSize(width:0, height:3)
                self.mainImageViewBG.layer.shadowRadius = 16
                self.mainImageViewBG.layer.shadowOpacity = 0.28
            })
        }
            
        }
    }
    
    @objc func tapAction(sender: UITapGestureRecognizer) {
        self.moreMore()
    }
    
    @objc func tapMore(button: UIButton) {
        self.moreMore()
    }
    
    func moreMore() {
        self.doHaptics()
        
        var sleepText = "Sleep Timer".localized
        if self.isSleepTimerActive {
            sleepText = "Cancel Sleep Timer".localized
        }
        
        var ti = ""
        if StoreStruct.playEpisode.isEmpty {
            ti = "The player is even more amazing once you've selected a podcast to play".localized
        } else {
            if StoreStruct.playDrawerPodcast[0].contentAdvisoryRating == "Explicit" || StoreStruct.playDrawerPodcast[0].contentAdvisoryRating == "yes" {
                ti = "🅴 \(StoreStruct.playEpisode[0].title)"
            } else {
                ti = StoreStruct.playEpisode[0].title
            }
        }

        var vb = ""
        if StoreStruct.vboost == false {
            vb = "Enable Volume Boost".localized
        } else {
            vb = "Disable Volume Boost".localized
        }
        
        let de = "Download Episode".localized
        let se = "Share Episode".localized

        Alertift.actionSheet(title: ti)
            .backgroundColor(Colours.grayDark2)
            .titleTextColor(UIColor.white)
            .messageTextColor(UIColor.white.withAlphaComponent(0.8))
            .messageTextAlignment(.left)
            .titleTextAlignment(.left)
            .action(.default(sleepText), image: UIImage(named: "sleep")) { (action, ind) in
                print(action, ind)
                if self.isSleepTimerActive {
                    self.sleepTimer!.invalidate()
                    self.isSleepTimerActive = false
                } else {
                    self.sleepAlert()
                }
            }
            .action(.default(vb), image: UIImage(named: "vboost")) { (action, ind) in
                print(action, ind)
                if StoreStruct.vboost == false {
                    self.avPlayer?.volume = 1.0
                    StoreStruct.vboost = true
                } else {
                    self.avPlayer?.volume = 0.75
                    StoreStruct.vboost = false
                }
            }
            .action(.default("Play Next".localized), image: UIImage(named: "listn")) { (action, ind) in
                print(action, ind)
                
                self.plNext()
            }
            .action(.default("Playback Speed".localized), image: UIImage(named: "speed0")) { (action, ind) in
                print(action, ind)
                self.speedAlert()
            }
            .action(.default("Back Skip Duration".localized), image: UIImage(named: "leftP")) { (action, ind) in
                print(action, ind)
                self.backAlert()
            }
            .action(.default("Forward Skip Duration".localized), image: UIImage(named: "rightP")) { (action, ind) in
                print(action, ind)
                self.forwardAlert()
            }
            .action(.default(" \(de)"), image: UIImage(named: "down")) { (action, ind) in
                print(action, ind)
                StoreStruct.downloadEpisode.insert(StoreStruct.playEpisode[0], at: 0)
                StoreStruct.downloadPodcast.insert(StoreStruct.playDrawerPodcast[0], at: 0)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "switchd"), object: self)
                
                let statusAlert = StatusAlert()
                statusAlert.image = UIImage(named: "down2")?.maskWithColor(color: UIColor.white)
                statusAlert.title = "Downloading"
                statusAlert.message = StoreStruct.playEpisode[0].title
                //statusAlert.canBePickedOrDismissed = isUserInteractionAllowed
                statusAlert.show()
                let impact = UIImpactFeedbackGenerator()
                impact.impactOccurred()
                
            }
            .action(.default("More by the Author".localized), image: UIImage(named: "more")) { (action, ind) in
                print(action, ind)
                let artist: String = StoreStruct.playArtist
                let dict:[String: String] = ["artist": artist]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "searchOpen"), object: self, userInfo: dict)
            }
            .action(.default("Episode Website".localized), image: UIImage(named: "w")) { (action, ind) in
                print(action, ind)
                let safariView = SFSafariViewController(url: URL(string: StoreStruct.playEpisode[0].streamUrl)!)
                safariView.preferredBarTintColor = Colours.white
                self.present(safariView, animated: true, completion: nil)
            }
            .action(.default(" \(se)"), image: UIImage(named: "up")) { (action, ind) in
                print(action, ind)
                let myWebsite = NSURL(string: StoreStruct.playEpisode[0].streamUrl)
                //let myWebsite = StoreStruct.playEpisode[0].streamUrl
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
    
    func plNext() {
        StoreStruct.currentPlaylist = StoreStruct.currentPlaylist + 1
        if StoreStruct.currentPlaylist < StoreStruct.downloadEpisode.count {
            
            StoreStruct.isPlaying = false
            StoreStruct.isPlayingInitial = false
            StoreStruct.playEpisode = [StoreStruct.downloadEpisode[StoreStruct.currentPlaylist]]
            StoreStruct.playPodcast = [StoreStruct.downloadPodcast[StoreStruct.currentPlaylist]]
            StoreStruct.playArtist = StoreStruct.downloadPodcast[StoreStruct.currentPlaylist].artistName ?? ""
            StoreStruct.mainImage = StoreStruct.downloadPodcast[StoreStruct.currentPlaylist].artworkUrl600 ?? ""
            
            StoreStruct.playDrawerEpisode = StoreStruct.downloadEpisode
            StoreStruct.playDrawerPodcast = [StoreStruct.downloadPodcast[StoreStruct.currentPlaylist]]
            StoreStruct.playDrawerArtist = StoreStruct.downloadPodcast[StoreStruct.currentPlaylist].artistName ?? ""
            StoreStruct.mainDrawerImage = StoreStruct.downloadPodcast[StoreStruct.currentPlaylist].artworkUrl600 ?? ""
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: self)
            
        }
    }
    
    func sleepAlert() {
        
        var se = "Seconds".localized
        var min = "Minute".localized
        var mins = "Minutes".localized
        var ho = "Hour".localized
        var hos = "Hours".localized
        
        Alertift.actionSheet()
            .backgroundColor(Colours.grayDark2)
            .titleTextColor(UIColor.white)
            .messageTextColor(UIColor.white.withAlphaComponent(0.8))
            .messageTextAlignment(.left)
            .titleTextAlignment(.left)
            .action(.default("30 \(se)")) { (action, ind) in
                print(action, ind)
                
                self.startSleep(seconds: 30)
            }
            .action(.default("1 \(min)")) { (action, ind) in
                print(action, ind)
                
                self.startSleep(seconds: 60)
            }
            .action(.default("5 \(mins)")) { (action, ind) in
                print(action, ind)
                
                self.startSleep(seconds: 300)
            }
            .action(.default("15 \(mins)")) { (action, ind) in
                print(action, ind)
                
                self.startSleep(seconds: 900)
            }
            .action(.default("30 \(mins)")) { (action, ind) in
                print(action, ind)
                
                self.startSleep(seconds: 1800)
            }
            .action(.default("1 \(ho)")) { (action, ind) in
                print(action, ind)
                
                self.startSleep(seconds: 3600)
            }
            .action(.default("2 \(hos)")) { (action, ind) in
                print(action, ind)
                
                self.startSleep(seconds: 7200)
            }
            .action(.default("End of Episode".localized)) { (action, ind) in
                print(action, ind)
                
                StoreStruct.endOfEp = true
            }
            .action(.cancel("Dismiss".localized))
            .finally { action, index in
                if action.style == .cancel {
                    return
                }
            }
            .show(on: self)
    }
    
    func speedAlert() {
        
        Alertift.actionSheet()
            .backgroundColor(Colours.grayDark2)
            .titleTextColor(UIColor.white)
            .messageTextColor(UIColor.white.withAlphaComponent(0.8))
            .messageTextAlignment(.left)
            .titleTextAlignment(.left)
            .action(.default("0.5x")) { (action, ind) in
                print(action, ind)
                self.avPlayer?.rate = 0.5
                StoreStruct.playbackSpeed = 0.5
            }
            .action(.default("0.75x")) { (action, ind) in
                print(action, ind)
                self.avPlayer?.rate = 0.75
                StoreStruct.playbackSpeed = 0.75
            }
            .action(.default("1x")) { (action, ind) in
                print(action, ind)
                self.avPlayer?.rate = 1
                StoreStruct.playbackSpeed = 1
            }
            .action(.default("1.25x")) { (action, ind) in
                print(action, ind)
                self.avPlayer?.rate = 1.25
                StoreStruct.playbackSpeed = 1.25
            }
            .action(.default("1.5x")) { (action, ind) in
                print(action, ind)
                self.avPlayer?.rate = 1.5
                StoreStruct.playbackSpeed = 1.5
            }
            .action(.default("1.75x")) { (action, ind) in
                print(action, ind)
                self.avPlayer?.rate = 1.75
                StoreStruct.playbackSpeed = 1.75
            }
            .action(.default("2x")) { (action, ind) in
                print(action, ind)
                self.avPlayer?.rate = 2
                StoreStruct.playbackSpeed = 2
            }
            .action(.default("3x")) { (action, ind) in
                print(action, ind)
                self.avPlayer?.rate = 3
                StoreStruct.playbackSpeed = 3
            }
            .action(.default("4x")) { (action, ind) in
                print(action, ind)
                self.avPlayer?.rate = 4
                StoreStruct.playbackSpeed = 4
            }
            .action(.default("5x")) { (action, ind) in
                print(action, ind)
                self.avPlayer?.rate = 5
                StoreStruct.playbackSpeed = 5
            }
            .action(.cancel("Dismiss".localized))
            .finally { action, index in
                if action.style == .cancel {
                    return
                }
            }
            .show(on: self)
    }
    
    func backAlert() {
        
        Alertift.actionSheet()
            .backgroundColor(Colours.grayDark2)
            .titleTextColor(UIColor.white)
            .messageTextColor(UIColor.white.withAlphaComponent(0.8))
            .messageTextAlignment(.left)
            .titleTextAlignment(.left)
            .action(.default("5 Seconds")) { (action, ind) in
                print(action, ind)
                StoreStruct.leftSkip = 5
                self.backwardSkip.setTitle("\(StoreStruct.leftSkip)", for: .normal)
            }
            .action(.default("10 Seconds")) { (action, ind) in
                print(action, ind)
                StoreStruct.leftSkip = 10
                self.backwardSkip.setTitle("\(StoreStruct.leftSkip)", for: .normal)
            }
            .action(.default("15 Seconds")) { (action, ind) in
                print(action, ind)
                StoreStruct.leftSkip = 15
                self.backwardSkip.setTitle("\(StoreStruct.leftSkip)", for: .normal)
            }
            .action(.default("30 Seconds")) { (action, ind) in
                print(action, ind)
                StoreStruct.leftSkip = 30
                self.backwardSkip.setTitle("\(StoreStruct.leftSkip)", for: .normal)
            }
            .action(.default("45 Seconds")) { (action, ind) in
                print(action, ind)
                StoreStruct.leftSkip = 45
                self.backwardSkip.setTitle("\(StoreStruct.leftSkip)", for: .normal)
            }
            .action(.default("60 Seconds")) { (action, ind) in
                print(action, ind)
                StoreStruct.leftSkip = 60
                self.backwardSkip.setTitle("\(StoreStruct.leftSkip)", for: .normal)
            }
            .action(.default("15 Minutes")) { (action, ind) in
                print(action, ind)
                StoreStruct.leftSkip = 900
                self.backwardSkip.setTitle("\(StoreStruct.leftSkip)", for: .normal)
            }
            .action(.cancel("Dismiss".localized))
            .finally { action, index in
                if action.style == .cancel {
                    return
                }
            }
            .show(on: self)
    }
    
    func forwardAlert() {
        
        Alertift.actionSheet()
            .backgroundColor(Colours.grayDark2)
            .titleTextColor(UIColor.white)
            .messageTextColor(UIColor.white.withAlphaComponent(0.8))
            .messageTextAlignment(.left)
            .titleTextAlignment(.left)
            .action(.default("5 Seconds")) { (action, ind) in
                print(action, ind)
                StoreStruct.rightSkip = 5
                self.forwardSkip.setTitle("\(StoreStruct.rightSkip)", for: .normal)
            }
            .action(.default("10 Seconds")) { (action, ind) in
                print(action, ind)
                StoreStruct.rightSkip = 10
                self.forwardSkip.setTitle("\(StoreStruct.rightSkip)", for: .normal)
            }
            .action(.default("15 Seconds")) { (action, ind) in
                print(action, ind)
                StoreStruct.rightSkip = 15
                self.forwardSkip.setTitle("\(StoreStruct.rightSkip)", for: .normal)
            }
            .action(.default("30 Seconds")) { (action, ind) in
                print(action, ind)
                StoreStruct.rightSkip = 30
                self.forwardSkip.setTitle("\(StoreStruct.rightSkip)", for: .normal)
            }
            .action(.default("45 Seconds")) { (action, ind) in
                print(action, ind)
                StoreStruct.rightSkip = 45
                self.forwardSkip.setTitle("\(StoreStruct.rightSkip)", for: .normal)
            }
            .action(.default("60 Seconds")) { (action, ind) in
                print(action, ind)
                StoreStruct.rightSkip = 60
                self.forwardSkip.setTitle("\(StoreStruct.rightSkip)", for: .normal)
            }
            .action(.default("15 Minutes")) { (action, ind) in
                print(action, ind)
                StoreStruct.rightSkip = 900
                self.forwardSkip.setTitle("\(StoreStruct.rightSkip)", for: .normal)
            }
            .action(.cancel("Dismiss".localized))
            .finally { action, index in
                if action.style == .cancel {
                    return
                }
            }
            .show(on: self)
    }
    
    func startSleep(seconds: Int) {
        
        let statusAlert = StatusAlert()
        statusAlert.image = UIImage(named: "sleep2")?.maskWithColor(color: UIColor.white)
        statusAlert.title = "Started Timer"
        statusAlert.message = "\(seconds) seconds"
        //statusAlert.canBePickedOrDismissed = isUserInteractionAllowed
        statusAlert.show()
        let impact = UIImpactFeedbackGenerator()
        impact.impactOccurred()
        
        self.isSleepTimerActive = true
        var tabHeight = Int(UITabBarController().tabBar.frame.size.height) + Int(34)
        var offset = 88
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                offset = 64
            case 2688:
                offset = 88
            case 2436:
                offset = 88
            default:
                offset = 64
                tabHeight = Int(UITabBarController().tabBar.frame.size.height)
            }
        }
        
        var count = 0
        sleepTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            count = count + 1
            if count == seconds {
                if StoreStruct.isPlaying {
                self.avPlayer?.pause()
                self.isPlaying = false
                StoreStruct.isPlaying = false
                self.playButton.setImage(UIImage(named: "play")?.maskWithColor(color: Colours.tabSelected), for: .normal)
                springWithDelay(duration: 0.4, delay: 0, animations: {
                    self.mainImageView.frame = CGRect(x: 40, y: Int(offset + 25), width: Int(self.view.bounds.width - 80), height: Int(self.view.bounds.width - 80))
                    self.mainImageViewBG.frame = self.mainImageView.frame
                    self.mainImageViewBG.layer.shadowOffset = CGSize(width:0, height:3)
                    self.mainImageViewBG.layer.shadowRadius = 16
                    self.mainImageViewBG.layer.shadowOpacity = 0.28
                })
                }
                self.sleepTimer!.invalidate()
                self.isSleepTimerActive = false
            }
        }
        sleepTimer!.fire()
    }
    
    @objc func longPressedPlay(gesture: UILongPressGestureRecognizer) {
        if isPlaybackInvoked == false {
            self.isPlaybackInvoked = true
            self.fromSpeed = true
            self.createPlaybackView()
        }
    }
    
    @objc func longPressedBack(gesture: UILongPressGestureRecognizer) {
        let index = gesture.view?.tag ?? 0
        if isPlaybackInvoked == false {
            self.isPlaybackInvoked = true
            self.fromSpeed = false
            self.fromLeftSkip = true
            self.createPlaybackView()
        }
    }
    
    @objc func longPressedForward(gesture: UILongPressGestureRecognizer) {
        let index = gesture.view?.tag ?? 0
        if isPlaybackInvoked == false {
            self.isPlaybackInvoked = true
            self.fromSpeed = false
            self.fromLeftSkip = false
            self.createPlaybackView()
        }
    }
    
    func createPlaybackView() {
        self.doHaptics()
        var offset = 88
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688:
                offset = 88
            case 2436:
                offset = 88
            default:
                offset = 64
            }
        }
        
        let window = UIApplication.shared.keyWindow!
        
        self.backgroundView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height + 100)
        self.backgroundView.backgroundColor = UIColor.black
        self.backgroundView.alpha = 0.2
        self.backgroundView.addTarget(self, action: #selector(self.dismissOverlay), for: .touchUpInside)
        window.addSubview(self.backgroundView)
        
        let wid = self.view.bounds.width - 40
        self.playbackView.frame = CGRect(x: 20, y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 12, width: Int(20), height: 60)
        self.playbackView.backgroundColor = Colours.grayDark2
        self.playbackView.layer.cornerRadius = 30
        self.playbackView.alpha = 0
        self.playbackView.layer.masksToBounds = true
        window.addSubview(self.playbackView)
        
        
        self.option1.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        if self.fromSpeed == true {
            self.option1.setTitle("0.5x", for: .normal)
        } else {
            self.option1.setTitle("15", for: .normal)
        }
        self.option1.setTitleColor(UIColor.white, for: .normal)
        self.option1.layer.cornerRadius = 20
        self.option1.backgroundColor = Colours.blue
        self.option1.contentHorizontalAlignment = .center
        self.option1.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.option1.alpha = 1
        self.option1.addTarget(self, action: #selector(self.touch1), for: .touchUpInside)
        self.playbackView.addSubview(self.option1)
        
        
        self.option2.frame = CGRect(x: 60, y: 10, width: 40, height: 40)
        if self.fromSpeed == true {
            self.option2.setTitle("1x", for: .normal)
        } else {
            self.option2.setTitle("30", for: .normal)
        }
        self.option2.setTitleColor(UIColor.white, for: .normal)
        self.option2.layer.cornerRadius = 20
        self.option2.backgroundColor = Colours.red
        self.option2.contentHorizontalAlignment = .center
        self.option2.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.option2.alpha = 1
        self.option2.addTarget(self, action: #selector(self.touch2), for: .touchUpInside)
        self.playbackView.addSubview(self.option2)
        
        
        self.option3.frame = CGRect(x: 110, y: 10, width: 40, height: 40)
        if self.fromSpeed == true {
            self.option3.setTitle("1.5x", for: .normal)
        } else {
            self.option3.setTitle("45", for: .normal)
        }
        self.option3.setTitleColor(UIColor.white, for: .normal)
        self.option3.layer.cornerRadius = 20
        self.option3.backgroundColor = Colours.green
        self.option3.contentHorizontalAlignment = .center
        self.option3.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.option3.alpha = 1
        self.option3.addTarget(self, action: #selector(self.touch3), for: .touchUpInside)
        self.playbackView.addSubview(self.option3)
        
        
        self.option4.frame = CGRect(x: 160, y: 10, width: 40, height: 40)
        if self.fromSpeed == true {
            self.option4.setTitle("2x", for: .normal)
        } else {
            self.option4.setTitle("60", for: .normal)
        }
        self.option4.setTitleColor(UIColor.white, for: .normal)
        self.option4.layer.cornerRadius = 20
        self.option4.backgroundColor = Colours.orange
        self.option4.contentHorizontalAlignment = .center
        self.option4.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.option4.alpha = 1
        self.option4.addTarget(self, action: #selector(self.touch4), for: .touchUpInside)
        self.playbackView.addSubview(self.option4)
        
        
        self.option5.frame = CGRect(x: Int(wid - 50), y: 10, width: 40, height: 40)
        if self.fromSpeed == true {
            self.option5.setTitle("5x", for: .normal)
        } else {
            self.option5.setTitle("15m", for: .normal)
        }
        self.option5.setTitleColor(UIColor.white, for: .normal)
        self.option5.layer.cornerRadius = 20
        self.option5.backgroundColor = UIColor.gray
        self.option5.contentHorizontalAlignment = .center
        self.option5.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.option5.alpha = 1
        self.option5.addTarget(self, action: #selector(self.touch5), for: .touchUpInside)
        self.playbackView.addSubview(self.option5)
        
        
        self.titleLab.text = "Please select an option".localized
        
        springWithDelay(duration: 0.5, delay: 0, animations: {
            self.playbackView.alpha = 1
            self.playbackView.frame = CGRect(x: 20, y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 12, width: Int(wid), height: 60)
        })
    }
    
    @objc func touch1(button: UIButton) {
        if self.fromSpeed == true {
            self.avPlayer?.rate = 0.5
            StoreStruct.playbackSpeed = 0.5
        } else {
        if self.fromLeftSkip == true {
            StoreStruct.leftSkip = 15
            self.backwardSkip.setTitle("\(StoreStruct.leftSkip)", for: .normal)
        } else {
            StoreStruct.rightSkip = 15
            self.forwardSkip.setTitle("\(StoreStruct.rightSkip)", for: .normal)
        }
        }
        self.dismissOverlayProper()
    }
    
    @objc func touch2(button: UIButton) {
        if self.fromSpeed == true {
            self.avPlayer?.rate = 1
            StoreStruct.playbackSpeed = 1
        } else {
        if self.fromLeftSkip == true {
            StoreStruct.leftSkip = 30
            self.backwardSkip.setTitle("\(StoreStruct.leftSkip)", for: .normal)
        } else {
            StoreStruct.rightSkip = 30
            self.forwardSkip.setTitle("\(StoreStruct.rightSkip)", for: .normal)
        }
        }
        self.dismissOverlayProper()
    }
    
    @objc func touch3(button: UIButton) {
        if self.fromSpeed == true {
            self.avPlayer?.rate = 1.5
            StoreStruct.playbackSpeed = 1.5
        } else {
        if self.fromLeftSkip == true {
            StoreStruct.leftSkip = 45
            self.backwardSkip.setTitle("\(StoreStruct.leftSkip)", for: .normal)
        } else {
            StoreStruct.rightSkip = 45
            self.forwardSkip.setTitle("\(StoreStruct.rightSkip)", for: .normal)
        }
        }
        self.dismissOverlayProper()
    }
    
    @objc func touch4(button: UIButton) {
        if self.fromSpeed == true {
            self.avPlayer?.rate = 2
            StoreStruct.playbackSpeed = 2
        } else {
        if self.fromLeftSkip == true {
            StoreStruct.leftSkip = 60
            self.backwardSkip.setTitle("\(StoreStruct.leftSkip)", for: .normal)
        } else {
            StoreStruct.rightSkip = 60
            self.forwardSkip.setTitle("\(StoreStruct.rightSkip)", for: .normal)
        }
        }
        self.dismissOverlayProper()
    }
    
    @objc func touch5(button: UIButton) {
        if self.fromSpeed == true {
            self.avPlayer?.rate = 5
            StoreStruct.playbackSpeed = 5
        } else {
        if self.fromLeftSkip == true {
            StoreStruct.leftSkip = 900
            self.backwardSkip.setTitle("15m", for: .normal)
        } else {
            StoreStruct.rightSkip = 900
            self.forwardSkip.setTitle("15m", for: .normal)
        }
        }
        self.dismissOverlayProper()
    }
    
    @objc func dismissOverlay(button: UIButton) {
        dismissOverlayProper()
    }
    func dismissOverlayProper() {
        var offset = 88
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688:
                offset = 88
            case 2436:
                offset = 88
            default:
                offset = 64
            }
        }
        
        self.backgroundView.alpha = 0
        self.isPlaybackInvoked = false
        
        if StoreStruct.playEpisode.isEmpty {
            self.titleLab.text = "Select a podcast from the Subscribed, Discover, or Playlist section...".localized
            self.titleLab.textColor = Colours.black.withAlphaComponent(0.3)
            
        } else {
            if StoreStruct.playDrawerPodcast[0].contentAdvisoryRating == "Explicit" || StoreStruct.playDrawerPodcast[0].contentAdvisoryRating == "yes" {
                self.titleLab.text = "🅴 \(StoreStruct.playEpisode[0].title ?? "")"
            } else {
                self.titleLab.text = StoreStruct.playEpisode[0].title
            }
            self.titleLab.textColor = Colours.black.withAlphaComponent(1)
        }
        
        let wid = self.view.bounds.width
        springWithDelay(duration: 0.5, delay: 0, animations: {
            self.playbackView.alpha = 1
            self.playbackView.frame = CGRect(x: 20, y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 12, width: Int(10), height: 60)
            self.playbackView.alpha = 0
            //self.playbackView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        
    }
    
    func doHaptics() {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
    }
    
    @objc func onChangeValueMySlider(sender: UISlider) {
        let seconds: Int64 = Int64(sender.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        self.avPlayer!.seek(to: targetTime)
        if avPlayer!.rate == 0 && self.isPlaying {
            avPlayer?.play()
        }
        //self.setNowPlayingMediaWith(current: self.avPlayerItem?.currentTime().seconds ?? 0, upper: self.avPlayerItem?.asset.duration.seconds ?? 0)
    }
    
    @objc func touchBack(button: UIButton) {
        self.doHaptics()
        let dur1: CMTime = self.avPlayerItem!.currentTime()
        let a1 = CMTimeGetSeconds(dur1)
        let a2 = a1 - Double(StoreStruct.leftSkip)
        let targetTime:CMTime = CMTimeMake(value: Int64(a2), timescale: 1)
        self.avPlayer!.seek(to: targetTime)
    }
    
    @objc func touchForward(button: UIButton) {
        self.doHaptics()
        let dur1: CMTime = self.avPlayerItem!.currentTime()
        let a1 = CMTimeGetSeconds(dur1)
        let a2 = a1 + Double(StoreStruct.rightSkip)
        let targetTime:CMTime = CMTimeMake(value: Int64(a2), timescale: 1)
        self.avPlayer!.seek(to: targetTime)
    }
    
    @objc func touchPlay(button: UIButton) {
        self.tPlay()
    }
    
    func tPlay() {
        
        let impact = UIImpactFeedbackGenerator()
        impact.impactOccurred()
        
        var tabHeight = Int(UITabBarController().tabBar.frame.size.height) + Int(34)
        var offset = 88
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                offset = 64
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
            avPlayer?.pause()
            self.isPlaying = false
            StoreStruct.isPlaying = false
            self.playButton.setImage(UIImage(named: "play")?.maskWithColor(color: Colours.tabSelected), for: .normal)
            springWithDelay(duration: 0.4, delay: 0, animations: {
                self.mainImageView.frame = CGRect(x: 40, y: Int(offset + 25), width: Int(self.view.bounds.width - 80), height: Int(self.view.bounds.width - 80))
                self.mainImageViewBG.frame = self.mainImageView.frame
                self.mainImageViewBG.layer.shadowOffset = CGSize(width:0, height:3)
                self.mainImageViewBG.layer.shadowRadius = 16
                self.mainImageViewBG.layer.shadowOpacity = 0.28
            })
        } else {
            avPlayer?.play()
            self.isPlaying = true
            StoreStruct.isPlaying = true
            self.playButton.setImage(UIImage(named: "pause")?.maskWithColor(color: Colours.tabSelected), for: .normal)
            springWithDelay(duration: 0.4, delay: 0, animations: {
                self.mainImageView.frame = CGRect(x: 20, y: Int(offset + 5), width: Int(self.view.bounds.width - 40), height: Int(self.view.bounds.width - 40))
                self.mainImageViewBG.frame = self.mainImageView.frame
                self.mainImageViewBG.layer.shadowOffset = CGSize(width:0, height:15)
                self.mainImageViewBG.layer.shadowRadius = 15
                self.mainImageViewBG.layer.shadowOpacity = 0.15
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.reloadAll()
        
        
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
    
    func reloadAll() {
        
        StoreStruct.whichView = 3
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = Colours.tabUnselected
        self.navigationController?.navigationBar.barTintColor = Colours.tabUnselected
        self.navigationController?.navigationItem.backBarButtonItem?.tintColor = Colours.tabUnselected
        
        
        var tabHeight = Int(UITabBarController().tabBar.frame.size.height) + Int(34)
        var offset = 88
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                offset = 64
            case 2688:
                offset = 88
            case 2436:
                offset = 88
            default:
                offset = 64
                tabHeight = Int(UITabBarController().tabBar.frame.size.height)
            }
        }
        
        let wid = self.view.bounds.width - 40
        
        
        
        self.titleLab = MarqueeLabel.init(frame: CGRect(x: 20, y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 75, width: Int(wid), height: 40), duration: 9, fadeLength: 20)
        if StoreStruct.playEpisode.isEmpty {
            self.titleLab.text = "Select a podcast from the Subscribed, Discover, or Playlist section...".localized
            self.titleLab.textColor = Colours.black.withAlphaComponent(0.3)
            self.backwardSkip.alpha = 0
            self.forwardSkip.alpha = 0
        } else {
            if StoreStruct.playDrawerPodcast[0].contentAdvisoryRating == "Explicit" || StoreStruct.playDrawerPodcast[0].contentAdvisoryRating == "yes" {
                self.titleLab.text = "🅴 \(StoreStruct.playEpisode[0].title ?? "")"
            } else {
                self.titleLab.text = StoreStruct.playEpisode[0].title
            }
            self.titleLab.textColor = Colours.black.withAlphaComponent(1)
            self.backwardSkip.alpha = 1
            self.forwardSkip.alpha = 1
        }
        self.titleLab.font = UIFont.boldSystemFont(ofSize: 18)
        self.titleLab.textAlignment = .center
        self.titleLab.alpha = 1
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("")
            case 2688:
                self.view.addSubview(self.titleLab)
            case 2436:
                self.view.addSubview(self.titleLab)
            default:
                self.view.addSubview(self.titleLab)
            }
        }
        
        if StoreStruct.playEpisode.isEmpty {
            
            
            slider = CustomUISlider(frame: CGRect(x: 40, y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 32, width: Int(wid - 40), height: 20))
            
            if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
                case 1136:
                    slider.layer.position = CGPoint(x: Int(self.view.frame.midX), y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 32)
                case 2688:
                    slider.layer.position = CGPoint(x: Int(self.view.frame.midX), y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 32)
                case 2436:
                    slider.layer.position = CGPoint(x: Int(self.view.frame.midX), y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 32)
                default:
                    slider.layer.position = CGPoint(x: Int(self.view.frame.midX), y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 32)
                }
            }
            slider.backgroundColor = Colours.clear
            slider.layer.cornerRadius = 10
            slider.layer.masksToBounds = false
            slider.minimumValue = 0
            slider.maximumValue = Float(1)
            slider.maximumTrackTintColor = Colours.cellQuote
            slider.minimumTrackTintColor = Colours.tabSelected
            slider.setMaximumTrackImage(UIImage(named: "maxslide")?.maskWithColor(color: Colours.cellQuote), for: .normal)
            slider.setThumbImage(UIImage(named: "slidethumb"), for: .normal)
            slider.alpha = 1
            self.view.addSubview(slider)
            
            
            if StoreStruct.isPlaying == false {
                springWithDelay(duration: 0.4, delay: 0, animations: {
                    self.mainImageView.frame = CGRect(x: 40, y: Int(offset + 25), width: Int(self.view.bounds.width - 80), height: Int(self.view.bounds.width - 80))
                    self.mainImageViewBG.frame = self.mainImageView.frame
                    self.mainImageViewBG.layer.shadowOffset = CGSize(width:0, height:3)
                    self.mainImageViewBG.layer.shadowRadius = 16
                    self.mainImageViewBG.layer.shadowOpacity = 0.28
                })
            } else {
                springWithDelay(duration: 0.4, delay: 0, animations: {
                    self.mainImageView.frame = CGRect(x: 20, y: Int(offset + 5), width: Int(self.view.bounds.width - 40), height: Int(self.view.bounds.width - 40))
                    self.mainImageViewBG.frame = self.mainImageView.frame
                    self.mainImageViewBG.layer.shadowOffset = CGSize(width:0, height:15)
                    self.mainImageViewBG.layer.shadowRadius = 15
                    self.mainImageViewBG.layer.shadowOpacity = 0.15
                })
            }
            
            self.mainImageViewBG.layer.cornerRadius = 20
            self.mainImageViewBG.layer.shadowColor = UIColor.black.cgColor
            self.mainImageViewBG.backgroundColor = Colours.white
            
            self.mainImageView.layer.cornerRadius = 20
            guard let secureImageUrl = URL(string: StoreStruct.mainImage) else { return }
            self.mainImageView.image = UIImage(named: "logo")
            self.mainImageView.pin_updateWithProgress = true
            self.mainImageView.pin_setImage(from: secureImageUrl)
            self.mainImageView.layer.masksToBounds = true
            self.mainImageView.contentMode = .scaleAspectFill
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(sender:)))
            self.mainImageView.isUserInteractionEnabled = true
            self.mainImageView.addGestureRecognizer(tapGesture)
            self.mainImageViewBG.alpha = 1
            self.mainImageView.alpha = 1
            self.view.addSubview(self.mainImageViewBG)
            self.view.addSubview(self.mainImageView)
            
        } else {
            if StoreStruct.isPlayingInitial == false {
                self.mainImageViewBG.alpha = 0
                self.mainImageView.alpha = 0
                self.playerLayer.removeFromSuperlayer()
                self.avPlayer?.pause()
                StoreStruct.vboost = false
                self.isPlaying = true
                StoreStruct.isPlaying = true
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .allowAirPlay)
                    do {
                        try AVAudioSession.sharedInstance().setActive(true)
                    } catch _ as NSError {
                        print("error")
                    }
                } catch _ as NSError {
                    print("error")
                }
                
                
                if StoreStruct.isPlaying == false {
                    springWithDelay(duration: 0.4, delay: 0, animations: {
                        self.mainImageView.frame = CGRect(x: 40, y: Int(offset + 25), width: Int(self.view.bounds.width - 80), height: Int(self.view.bounds.width - 80))
                        self.mainImageViewBG.frame = self.mainImageView.frame
                        self.mainImageViewBG.layer.shadowOffset = CGSize(width:0, height:3)
                        self.mainImageViewBG.layer.shadowRadius = 16
                        self.mainImageViewBG.layer.shadowOpacity = 0.28
                    })
                } else {
                    springWithDelay(duration: 0.4, delay: 0, animations: {
                        self.mainImageView.frame = CGRect(x: 20, y: Int(offset + 5), width: Int(self.view.bounds.width - 40), height: Int(self.view.bounds.width - 40))
                        self.mainImageViewBG.frame = self.mainImageView.frame
                        self.mainImageViewBG.layer.shadowOffset = CGSize(width:0, height:15)
                        self.mainImageViewBG.layer.shadowRadius = 15
                        self.mainImageViewBG.layer.shadowOpacity = 0.15
                    })
                }
                
                self.mainImageViewBG.layer.cornerRadius = 20
                self.mainImageViewBG.layer.shadowColor = UIColor.black.cgColor
                self.mainImageViewBG.backgroundColor = Colours.white
                
                self.mainImageView.layer.cornerRadius = 20
                guard let secureImageUrl = URL(string: StoreStruct.mainImage) else { return }
                self.mainImageView.image = UIImage(named: "logo")
                self.mainImageView.pin_updateWithProgress = true
                self.mainImageView.pin_setImage(from: secureImageUrl)
                self.mainImageView.layer.masksToBounds = true
                self.mainImageView.contentMode = .scaleAspectFill
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(sender:)))
                self.mainImageView.isUserInteractionEnabled = true
                self.mainImageView.addGestureRecognizer(tapGesture)
                
                
                StoreStruct.downloadedStore = UserDefaults.standard.value(forKey: "downloadStore") as? [String: String] ?? [String: String]()
                print(StoreStruct.downloadedStore)
                var newName = "\(StoreStruct.playEpisode[0].author)\(StoreStruct.playEpisode[0].title)"
                newName = newName.replacingOccurrences(of: " ", with: "")
                if let fileURL = StoreStruct.downloadedStore[newName] {
                    print("furl1")
                    print(fileURL)
                    self.timer?.invalidate()
                    let url = URL(string: fileURL)!
                    avPlayerItem = AVPlayerItem.init(url: url)
                    avPlayer = AVPlayer.init(playerItem: avPlayerItem)
                    
                    let imageExtensions = ["mp4", "m4a", "m4v", "f4v", "f4a", "mov", "webm", "wmv", "avi", "flv", "mpg", "3gp", "asf", "rm", "swf"]
                    let pathExtention = url.pathExtension
                    if imageExtensions.contains(pathExtention) {
                        print("is video")
                        self.isThisVideo = true
                        self.playerLayer = AVPlayerLayer(player: avPlayer)
                        self.playerLayer.frame = CGRect(x: 00, y: Int(offset + 30), width: Int(self.view.bounds.width), height: Int(self.view.bounds.width - 80))
                        self.view.layer.addSublayer(self.playerLayer)
                    } else {
                        print("not video")
                        self.isThisVideo = false
                        self.mainImageViewBG.alpha = 1
                        self.mainImageView.alpha = 1
                        self.view.addSubview(self.mainImageViewBG)
                        self.view.addSubview(self.mainImageView)
                    }
                    
                    avPlayer?.volume = 0.75
                    avPlayer?.playImmediately(atRate: StoreStruct.playbackSpeed)
                    self.playButton.setImage(UIImage(named: "pause")?.maskWithColor(color: Colours.tabSelected), for: .normal)
                    StoreStruct.isPlayingInitial = true
                } else {
                    print("furl2")
                    let urlstring = StoreStruct.playEpisode[0].streamUrl
                    self.timer?.invalidate()
                    let url = NSURL(string: urlstring)
                    avPlayerItem = AVPlayerItem.init(url: url! as URL)
                    avPlayer = AVPlayer.init(playerItem: avPlayerItem)
                    
                    let imageExtensions = ["mp4", "m4a", "m4v", "f4v", "f4a", "mov", "webm", "wmv", "avi", "flv", "mpg", "3gp", "asf", "rm", "swf"]
                    let pathExtention = url?.pathExtension
                    if imageExtensions.contains(pathExtention!) {
                        print("is video")
                        self.isThisVideo = true
                        self.playerLayer = AVPlayerLayer(player: avPlayer)
                        self.playerLayer.frame = CGRect(x: 00, y: Int(offset + 30), width: Int(self.view.bounds.width), height: Int(self.view.bounds.width - 80))
                        self.view.layer.addSublayer(playerLayer)
                    } else {
                        print("not video")
                        self.isThisVideo = false
                        self.mainImageViewBG.alpha = 1
                        self.mainImageView.alpha = 1
                        self.view.addSubview(self.mainImageViewBG)
                        self.view.addSubview(self.mainImageView)
                    }
                    
                    avPlayer?.volume = 0.75
                    avPlayer?.playImmediately(atRate: StoreStruct.playbackSpeed)
                    self.playButton.setImage(UIImage(named: "pause")?.maskWithColor(color: Colours.tabSelected), for: .normal)
                    StoreStruct.isPlayingInitial = true
                }
                
                
            }
            
            
            if StoreStruct.isPlaying == false {
                springWithDelay(duration: 0.4, delay: 0, animations: {
                    self.mainImageView.frame = CGRect(x: 40, y: Int(offset + 25), width: Int(self.view.bounds.width - 80), height: Int(self.view.bounds.width - 80))
                    self.mainImageViewBG.frame = self.mainImageView.frame
                    self.mainImageViewBG.layer.shadowOffset = CGSize(width:0, height:3)
                    self.mainImageViewBG.layer.shadowRadius = 16
                    self.mainImageViewBG.layer.shadowOpacity = 0.28
                })
            } else {
                springWithDelay(duration: 0.4, delay: 0, animations: {
                    self.mainImageView.frame = CGRect(x: 20, y: Int(offset + 5), width: Int(self.view.bounds.width - 40), height: Int(self.view.bounds.width - 40))
                    self.mainImageViewBG.frame = self.mainImageView.frame
                    self.mainImageViewBG.layer.shadowOffset = CGSize(width:0, height:15)
                    self.mainImageViewBG.layer.shadowRadius = 15
                    self.mainImageViewBG.layer.shadowOpacity = 0.15
                })
            }
            
            
            if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
                case 1136:
                    self.lowerLab.frame = CGRect(x: 40, y:Int(offset + 5) + Int(self.view.bounds.width - 40) + 42, width: 120, height: 40)
                    self.upperLab.frame = CGRect(x: Int(self.view.bounds.width) - 160, y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 42, width: 120, height: 40)
                case 2688:
                    self.lowerLab.frame = CGRect(x: 40, y:Int(offset + 5) + Int(self.view.bounds.width - 40) + 42, width: 120, height: 40)
                    self.upperLab.frame = CGRect(x: Int(self.view.bounds.width) - 160, y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 42, width: 120, height: 40)
                case 2436:
                    self.lowerLab.frame = CGRect(x: 40, y:Int(offset + 5) + Int(self.view.bounds.width - 40) + 42, width: 120, height: 40)
                    self.upperLab.frame = CGRect(x: Int(self.view.bounds.width) - 160, y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 42, width: 120, height: 40)
                default:
                    self.lowerLab.frame = CGRect(x: 40, y:Int(offset + 5) + Int(self.view.bounds.width - 40) + 42, width: 120, height: 40)
                    self.upperLab.frame = CGRect(x: Int(self.view.bounds.width) - 160, y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 42, width: 120, height: 40)
                }
            }
            self.lowerLab.text = "00:00:00"
            self.lowerLab.textColor = Colours.black.withAlphaComponent(0.5)
            self.lowerLab.font = UIFont.systemFont(ofSize: 12)
            self.lowerLab.textAlignment = .left
            self.lowerLab.alpha = 1
            self.view.addSubview(self.lowerLab)
            
            self.upperLab.text = "00:00:00"
            self.upperLab.textColor = Colours.black.withAlphaComponent(0.5)
            self.upperLab.font = UIFont.systemFont(ofSize: 12)
            self.upperLab.textAlignment = .right
            self.upperLab.alpha = 1
            self.view.addSubview(self.upperLab)
            
            
            slider = CustomUISlider(frame: CGRect(x: 40, y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 32, width: Int(wid - 40), height: 20))
            if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
                case 1136:
                    slider.layer.position = CGPoint(x: Int(self.view.frame.midX), y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 32)
                case 2688:
                    slider.layer.position = CGPoint(x: Int(self.view.frame.midX), y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 32)
                case 2436:
                    slider.layer.position = CGPoint(x: Int(self.view.frame.midX), y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 32)
                default:
                    slider.layer.position = CGPoint(x: Int(self.view.frame.midX), y: Int(offset + 5) + Int(self.view.bounds.width - 40) + 32)
                }
            }
            slider.backgroundColor = Colours.clear
            slider.layer.cornerRadius = 10
            slider.layer.masksToBounds = false
            slider.minimumValue = 0
            let duration: CMTime = avPlayerItem!.asset.duration
            //let timeRange = self.avPlayer?.currentItem?.loadedTimeRanges[0].timeRangeValue
            //let seconds = CMTimeGetSeconds(timeRange?.duration ?? duration)
            let seconds: Float64 = CMTimeGetSeconds(duration)
            StoreStruct.seconds = Float(seconds)
            slider.maximumValue = Float(seconds)
            slider.maximumTrackTintColor = Colours.cellQuote
            slider.minimumTrackTintColor = Colours.tabSelected
            slider.setMaximumTrackImage(UIImage(named: "maxslide")?.maskWithColor(color: Colours.cellQuote), for: .normal)
            slider.setThumbImage(UIImage(named: "slidethumb"), for: .normal)
            slider.addTarget(self, action: #selector(onChangeValueMySlider), for: .valueChanged)
            slider.alpha = 1
            self.view.addSubview(slider)
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                let dur1: CMTime = self.avPlayerItem!.currentTime()
                let a1 = CMTimeGetSeconds(dur1)
                let dur2: CMTime = self.avPlayerItem!.asset.duration
                let a2 = CMTimeGetSeconds(dur2)
                let percent = Float(a1/a2)*100
                let currentSeconds = Float(a2)*percent/100
                StoreStruct.currentSeconds = currentSeconds
                
                self.slider.setValue(currentSeconds, animated: true)
                
                if a1 == 0 {
                    self.lowerLab.text = "Fetching Episode"
                } else {
                    self.lowerLab.text = self.toCorrectTime(time: currentSeconds)
                }
                self.upperLab.text = self.toCorrectTime(time: Float(a2))
                StoreStruct.upperLab = self.toCorrectTime(time: Float(a2))
                print("\(a1), \(a2)")
                
            }
            timer!.fire()
            
            
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        var tabHeight = Int(UITabBarController().tabBar.frame.size.height) + Int(34)
        var offset = 88
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                offset = 64
            case 2688:
                offset = 88
            case 2436:
                offset = 88
            default:
                offset = 64
                tabHeight = Int(UITabBarController().tabBar.frame.size.height)
            }
        }
        
        let wid = self.view.bounds.width - 40
        
        
        if keyPath == "status" {
            print("playstatus---")
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
            Colours.black = UIColor.black
            Colours.playButtonWhite = UIColor.white
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
            Colours.playButtonWhite = UIColor(red: 33/255.0, green: 33/255.0, blue: 43/255.0, alpha: 1.0)
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
            Colours.playButtonWhite = UIColor(red: 25/255.0, green: 25/255.0, blue: 30/255.0, alpha: 1.0)
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
        self.playButton.backgroundColor = Colours.playButtonWhite
        self.view.addSubview(self.playButton)
        self.upperLab.textColor = Colours.black.withAlphaComponent(0.5)
        self.lowerLab.textColor = Colours.black.withAlphaComponent(0.5)
        self.titleLab.textColor = Colours.black.withAlphaComponent(1)
        slider.maximumTrackTintColor = Colours.cellQuote
        slider.minimumTrackTintColor = Colours.tabSelected
        slider.setMaximumTrackImage(UIImage(named: "maxslide")?.maskWithColor(color: Colours.cellQuote), for: .normal)
        self.removeTabbarItemsText()
    }
    
    
    
    func goToNextFromPrev() {
        let index = StoreStruct.searchIndex
        let controller = EpisodesViewController()
        self.navigationController?.pushViewController(controller, animated: true)
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
}

extension CALayer {
    
    func bringToFront() {
        guard let sLayer = superlayer else {
            return
        }
        removeFromSuperlayer()
        sLayer.insertSublayer(self, at: UInt32(sLayer.sublayers?.count ?? 0))
    }
    
    func sendToBack() {
        guard let sLayer = superlayer else {
            return
        }
        removeFromSuperlayer()
        sLayer.insertSublayer(self, at: 0)
    }
}
