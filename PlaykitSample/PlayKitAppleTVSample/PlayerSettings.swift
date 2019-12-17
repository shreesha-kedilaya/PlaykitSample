//
//  PlayerSettings.swift
//  PlayKitAppleTVSample
//
//  Created by Gal Orlanczyk on 23/05/2017.
//  Copyright © 2017 Kaltura. All rights reserved.
//

import Foundation
import PlayKit
import PlayKitProviders



struct VideoData {
    var partnerID: Int
    var serverURL: String
    var ks: String?
    var assetId: String
    var assetType: AssetType = AssetType.media
    var assetRefType: AssetReferenceType = AssetReferenceType.media
    var assetPlaybackContextType: PlaybackContextType = PlaybackContextType.playback
    var formats: [String]?
    var fileIds: [String]?
    var networkProtocol: String?
    var referrer: String?
    
    init(partnerID:Int, serverURL:String, assetId: String ) {
        self.partnerID = partnerID
        self.serverURL = serverURL
        self.assetId = assetId
    }
}

class PlayerSettings {
    
    enum MediaType: Int {
        case clear = 0, live, drm, kalturaCaptions, kalturaAudioTracks
    }
    
    var mediaType: MediaType = .live
    var startTime: TimeInterval = 0
    var autoplay = false
    
    func createMediaConfig(video: VideoData, completionHandler: @escaping (MediaConfig?) -> Void) {
        switch self.mediaType {
        case .clear:
                        let id = "Apple Bip Bop"
                        let contentUrl = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8"
                        let mediaEntry = self.createMediaEntry(fromUrl: contentUrl, andId: id)
                        completionHandler(MediaConfig(mediaEntry: mediaEntry, startTime: self.startTime))
            
//            let sessionProvider = SimpleSessionProvider(serverURL: "https://rest-as.ott.kaltura.com/v5_0_3/api_v3/", partnerId: Int64(video.partnerID), ks: nil)
//
//            let phoenixMediaProvider = PhoenixMediaProvider()
//            phoenixMediaProvider.set(assetId: video.assetId)
//            phoenixMediaProvider.set(sessionProvider: sessionProvider)
//            phoenixMediaProvider.set(type: AssetType.media)
//
//            phoenixMediaProvider.set(refType: AssetReferenceType.media)
//            phoenixMediaProvider.set(playbackContextType: PlaybackContextType.playback)
//            phoenixMediaProvider.set(formats: video.formats)
//            phoenixMediaProvider.set(fileIds: video.fileIds)
//            phoenixMediaProvider.set(networkProtocol: video.networkProtocol)
//            phoenixMediaProvider.set(referrer: video.referrer)
//            phoenixMediaProvider.set(sessionProvider: sessionProvider)
//
//
//            phoenixMediaProvider.loadMedia() { (mediaEntry, error) in
//                if let me = mediaEntry {
//                    completionHandler(MediaConfig(mediaEntry: me, startTime: self.startTime))
//                }
//            }
            
        case .live:
            let mediaEntry = self.createMediaEntry(fromUrl: "https://rest-as.ott.kaltura.com/api_v3/service/assetFile/action/playManifest/partnerId/225/assetId/616430/assetType/media/assetFileId/5686125/contextType/PLAYBACK/a.m3u8", andId: "0_f8re4ujs")
            completionHandler(MediaConfig(mediaEntry: mediaEntry, startTime: self.startTime))
            
        case .drm:
            /*let id = "0_pl5lbfo0"
             let contentUrl = "https://cdnapisec.kaltura.com/p/1851571/playManifest/entryId/0_pl5lbfo0/format/applehttp/protocol/https/a/a.m3u8"
             let licenseDataUrl = URL(string: "https://cdnapisec.kaltura.com/html5/html5lib/v2.50/services.php?service=getLicenseData&uiconf_id=31956421&wid=_1851571&entry_id=0_pl5lbfo0&drm=fps")
             guard let dataTaskUrl = licenseDataUrl else {
             print("license data url for drm is wrong")
             completionHandler(nil)
             return
             }
             let dataTask = URLSession.shared.dataTask(with: dataTaskUrl) { (data, response, error) in
             if let data = data, error == nil {
             let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
             if let dict = json as? [String: Any], let drmData = DRMParams.fromJSON(dict) {
             let mediaEntry = MediaEntry(id, sources: [MediaSource(id, contentUrl: URL(string: contentUrl)!, drmData: [drmData])])
             DispatchQueue.main.async {
             completionHandler(MediaConfig(mediaEntry: mediaEntry, startTime: self.startTime))
             }
             }
             } else {
             print(error!.localizedDescription)
             }
             }
             dataTask.resume()*/
            
            let sessionProvider = SimpleSessionProvider(serverURL: "https://rest-as.ott.kaltura.com/v5_0_3/api_v3/", partnerId: 225, ks: nil)
            
            // Create the media provider
            let phoenixMediaProvider = PhoenixMediaProvider()
            phoenixMediaProvider.set(assetId: "684891")
            phoenixMediaProvider.set(sessionProvider: sessionProvider)
            phoenixMediaProvider.set(type: AssetType.media)
            phoenixMediaProvider.set(refType: AssetReferenceType.media)
            phoenixMediaProvider.set(playbackContextType: PlaybackContextType.playback)
            phoenixMediaProvider.set(formats: ["HLSFPS_Mobile_HD"])
            phoenixMediaProvider.set(fileIds: nil)
            phoenixMediaProvider.set(networkProtocol: "https")
            phoenixMediaProvider.set(referrer: nil)
            phoenixMediaProvider.set(sessionProvider: sessionProvider)
            
            
            phoenixMediaProvider.loadMedia() { (mediaEntry, error) in
                if let me = mediaEntry {
                    completionHandler(MediaConfig(mediaEntry: me, startTime: self.startTime))
                }
            }
        case .kalturaCaptions:
            let contentUrl = "https://cdnapisec.kaltura.com/p/811441/playManifest/entryId/1_mhyj12pj/format/applehttp/protocol/https/a.m3u8"
            let mediaEntry = self.createMediaEntry(fromUrl: contentUrl, andId: "Kaltura Multi-Captions")
            completionHandler(MediaConfig(mediaEntry: mediaEntry, startTime: self.startTime))
        case .kalturaAudioTracks:
            let contentUrl = "https://cdnapisec.kaltura.com/p/2035982/sp/203598200/playManifest/entryId/0_7s8q41df/format/applehttp/protocol/https/name/a.m3u8"
            let mediaEntry = self.createMediaEntry(fromUrl: contentUrl, andId: "Kaltura Multi-Audio")
            completionHandler(MediaConfig(mediaEntry: mediaEntry, startTime: self.startTime))
        }
    }
    
    private func createMediaEntry(fromUrl url: String, andId id: String) -> PKMediaEntry {
        let mediaSource = PKMediaSource.init(id, contentUrl: URL(string: url))
        return PKMediaEntry.init(id, sources: [mediaSource])
    }
}
