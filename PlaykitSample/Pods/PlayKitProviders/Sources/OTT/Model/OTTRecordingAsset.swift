
import Foundation
import SwiftyJSON

fileprivate let recordingIdKey = "recordingId"
fileprivate let recordingTypeKey = "recordingType"

public enum RecordingType: String {
    case single = "SINGLE"
    case season = "SEASON"
    case series = "SERIES"
}

public class OTTRecordingAsset: OTTProgramAsset {
    /**  Recording identifier  */
    public var recordingId: String?
    /**  Recording Type: single/season/series  */
    public var recordingType: RecordingType?
    
    public required init?(json: Any) {
        super.init(json: json)
        
        let jsonObj: JSON = JSON(json)
        
        self.recordingId = jsonObj[recordingIdKey].string
        if let type = jsonObj[recordingTypeKey].string {
            self.recordingType = RecordingType(rawValue: type)
        }
    }
}
