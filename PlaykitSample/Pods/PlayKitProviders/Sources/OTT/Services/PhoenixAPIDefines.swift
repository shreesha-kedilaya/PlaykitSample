// ===================================================================================================
// Copyright (C) 2017 Kaltura Inc.
//
// Licensed under the AGPLv3 license, unless a different license for a 
// particular library is specified in the applicable library path.
//
// You may obtain a copy of the License at
// https://www.gnu.org/licenses/agpl-3.0.html
// ===================================================================================================

import Foundation

//  0 – EPG linear programs; 1 - Recording; any asset type ID according to the asset types IDs defined in the system - Media.
enum AssetTypeAPI: Int, CustomStringConvertible {
    case epg
    case recording
    case media
    
    var description: String {
        switch self {
        case .media: return "media"
        case .epg: return "epg"
        case .recording: return "recording"
        }
    }
}

enum AssetReferenceTypeAPI: Int, CustomStringConvertible {
    case media
    case epgInternal
    case epgExternal
    case npvr
    
    var description: String {
        switch self {
        case .media: return "media"
        case .epgInternal: return "epg_internal"
        case .epgExternal: return "epg_external"
        case .npvr: return "npvr"
        }
    }
}

enum PlaybackTypeAPI: Int, CustomStringConvertible {
    
    case trailer
    case catchup
    case startOver
    case playback
    
    var description: String {
        switch self {
        case .trailer: return "TRAILER"
        case .catchup: return "CATCHUP"
        case .startOver: return "START_OVER"
        case .playback: return "PLAYBACK"
        }
    }
}
