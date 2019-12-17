//
//  ViewController.swift
//  PlayKitAppleTVSample
//
//  Created by Gal Orlanczyk on 03/05/2017.
//  Copyright © 2017 Kaltura. All rights reserved.
//

import UIKit
import KalturaNetKit
import PlayKit
import PlayKitYoubora
import PlayKitKava

class VideoViewController: UIViewController {
    
    let animationDuration: TimeInterval = 0.5
    let seekAmount: TimeInterval = 15
    let settingsSegueIdentifier = "showSettings"
    
    var player: Player!
    var duration: TimeInterval?
    var progressTimer: Timer?
    var focusedViews = [UIView]()
    var playerSettings = PlayerSettings()
    var shouldShowControlsOnViewWillAppear = false
    // tracks //
    var tracks: PKTracks?
    var selectedAudioTrack: Track?
    var selectedCaptionTrack: Track?
    
    // playback controls
    weak var playbackControlsView: UIView?
    weak var playbackControlsViewBottomConstraint: NSLayoutConstraint?
    weak var playPauseButton: UIButton?
    weak var progressView: UIProgressView?
    weak var currentTimeLabel: UILabel?
    weak var durationLabel: UILabel?
    
    // captions controls
    weak var tracksControlsView: UIView?
    weak var captionsSegmentedControl: UISegmentedControl?
    weak var audioTracksSegmentedControl: UISegmentedControl?
    
    /************************************************************/
    // MARK: - Life Cycle
    /************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // config options
        let idForVendor = UIDevice.current.identifierForVendor!.uuidString
        debugPrint("<info:>  deviceIdentifier = \(idForVendor)")
        let youboraOptions: [String: Any] = [
            "accountCode": "viacom18", // mandatory
            "username": idForVendor,
            "media": [
                
                "isLive": false,
                "title": "First title",
                "duration": 0.2
            ],
            
            // YouboraPlugin.enableSmartAdsKey: true - use this if you want to enable smart ads
        ]
        // create analytics config with the created params
        let youboraConfig = AnalyticsConfig(params: youboraOptions)
        
        let kavaConfig = KavaPluginConfig(partnerId: 1982551, entryId: nil, ks: nil, playbackContext: nil, referrer: nil, applicationVersion: "1.0", playlistId: "abc", customVar1: nil, customVar2: nil, customVar3: nil)
        kavaConfig.playbackType = KavaPluginConfig.PlaybackType.vod
        
        // create config dictionary
        let config = [YouboraPlugin.pluginName: youboraConfig, KavaPlugin.pluginName: kavaConfig]
        // create plugin config object
        let pluginConfig = PluginConfig(config: config)
        
//        PlayKitManager.shared.configurePlayer(with: mediaInfo)
        self.player = PlayKitManager.shared.loadPlayer(pluginConfig: pluginConfig)
        player.view = (self.view as! PlayerView)
        player.view?.backgroundColor = UIColor.black
        var vdo = VideoData(partnerID: 225, serverURL: "https://rest-as.ott.kaltura.com/v5_0_3/api_v3/", assetId: "868641")
        vdo.formats = ["TV Main"]
        vdo.networkProtocol = "https"
        playerSettings.createMediaConfig(video: vdo) { [weak self] (mediaConfig) in
            guard let mc = mediaConfig else { return }
            self?.player.prepare(mc)
            self?.player.play()
        }
        
        player.addObserver(self, event: PlayerEvent.durationChanged) { event in
            self.duration = event.duration?.doubleValue
            self.durationLabel?.text = self.getTimeRepresentation(time: self.duration ?? 0)
        }
        player.addObserver(self, event: PlayerEvent.tracksAvailable) { event in
            self.tracks = event.tracks
        }
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp(gesture:)))
        swipeUpGesture.direction = .up
        player.view?.addGestureRecognizer(swipeUpGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown(gesture:)))
        swipeDownGesture.direction = .down
        player.view?.addGestureRecognizer(swipeDownGesture)
        
        player.play()
    }
    
    fileprivate func createYouboraPluginConfig(some: Bool) -> AnalyticsConfig? {
        
        let idForVendor = UIDevice.current.identifierForVendor!.uuidString
        
        let userName = idForVendor
        let appVersion = "1.0.55"
        let duration = Float(0)
        let accountCode = "viacom18"
        
        // account code is mandatory, make sure to put the correct one.
        let youboraPluginParams: [String: Any] = [
            "accountCode": accountCode,
            "username": userName,
            "haltOnError": true,
            "enableSmartAds": true,
            "enableAnalytics": true,
            "httpSecure": true,
            "parseHLS": true,
            //            "media": [
            //                "title": self.mediaInfo.mName ?? "",
            //                "isLive": self.mediaInfo.isLive,
            //                "duration": duration/1000,
            //            ],
            "properties": [
                "genre": "",
                "type": "",
                "transaction_type": "",
                "year": 0,
                "cast": "",
                "director": "",
                "owner": "",
                "parental": "",
                "price": "",
                "rating": "",
                "audioType": "",
                "audioChannels": "",
                "device": "",
                "quality": "",
            ],
            "media": [
                
                "isLive": false,
                "title": "Apna changes",
                "duration": 0.2
            ],
            
            "ads": [
                "adsExpected": true,
                "campaign": "VootCamp",
            ],
            "extraParams": [
                "param1": "mobile",
                //                "param2": self.mediaInfo.mId ,
                "param3": appVersion,
                "param4": "true"
            ],
        ]
        
        return AnalyticsConfig(params: youboraPluginParams)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.shouldShowControlsOnViewWillAppear {
            self.shouldShowControlsOnViewWillAppear = false
            self.showPlaybackControlsView()
        }
    }
    
    /************************************************************/
    // MARK: - Overrides
    /************************************************************/
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if focusedViews.count > 0  {
            return focusedViews
        } else {
            return super.preferredFocusEnvironments
        }
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.first?.type == UIPress.PressType.menu && (self.playbackControlsView != nil || self.tracksControlsView != nil) {
            self.removePlaybackControlsView()
            self.removeTracksControlsView()
        } else if presses.first?.type == UIPress.PressType.playPause {
            self.playPause()
        } else {
            super.pressesBegan(presses, with: event)
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
    }
    
    /************************************************************/
    // MARK: - Actions
    /************************************************************/
    
    @objc func handleSwipeUp(gesture: UISwipeGestureRecognizer) {
        if self.playbackControlsView == nil && self.tracksControlsView == nil {
            self.showPlaybackControlsView()
        } else if self.playbackControlsView == nil && self.tracksControlsView != nil {
            self.removeTracksControlsView()
        }
    }
    
    @objc func handleSwipeDown(gesture: UISwipeGestureRecognizer) {
        if self.playbackControlsView != nil {
            self.removePlaybackControlsView()
        } else if let tracks = self.tracks, self.tracksControlsView == nil {
            self.showTracksControlsView(tracks: tracks)
        }
    }
    
    /************************************************************/
    // MARK: - Navigation
    /************************************************************/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.settingsSegueIdentifier {
            let destinationVC = segue.destination as! SettingsViewController
            destinationVC.playerSettings = self.playerSettings
            self.shouldShowControlsOnViewWillAppear = true
            self.removePlaybackControlsView()
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    /************************************************************/
    // MARK: - Internal
    /************************************************************/
    
    @objc func playPause() {
        if self.player.rate == 0 {
            self.player.play()
            self.playPauseButton?.setTitle("Pause", for: .normal)
            self.startProgressTimer()
        } else if self.player.rate == 1 {
            self.player.pause()
            self.playPauseButton?.setTitle("Play", for: .normal)
            self.stopProgressTimer()
        }
    }
    
    func startProgressTimer() {
        self.stopProgressTimer()
        self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            self?.updateProgress()
        }
    }
    
    func stopProgressTimer() {
        self.progressTimer?.invalidate()
        self.progressTimer = nil
    }
    
    func getTimeRepresentation(time: TimeInterval) -> String {
        if time < 0 {
            return "--:--"
        } else if time > 3600 {
            let hours = Int(time / 3600)
            let minutes = Int(time.truncatingRemainder(dividingBy: 3600) / 60)
            let seconds = Int(time.truncatingRemainder(dividingBy: 60))
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            let minutes = Int(time / 60)
            let seconds = Int(time.truncatingRemainder(dividingBy: 60))
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    func updateProgress(animated: Bool = true) {
        let currentTime = self.player.currentTime
        self.currentTimeLabel?.text = self.getTimeRepresentation(time: currentTime)
        if currentTime > 0 {
            self.progressView?.setProgress(Float(self.player.currentTime/self.player.duration), animated: animated)
        }
    }
}

