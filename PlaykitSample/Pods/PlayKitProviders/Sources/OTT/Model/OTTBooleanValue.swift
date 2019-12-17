
import Foundation
import SwiftyJSON

class OTTBooleanValue: OTTBaseObject {
    
    var value: Bool?
    
    let valueKey = "value"
    
    required init?(json: Any) {
        if let jsonDictionary = JSON(json).dictionary {
            self.value = jsonDictionary[valueKey]?.bool
        }
    }
}
