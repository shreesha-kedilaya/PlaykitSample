//
//  ResponseSerializer.swift
//  Pods
//
//  Created by Rivka Peleg on 14/03/2017.
//
//

import Foundation

enum SerializerError: Error {
    case serializationError
}


public protocol ResponseSerializer {
    /**
     This fuction will serialize the response data of certin request to the expected type according to the serializer type
     */
    func serialize(data: Data) throws -> Any
}


public class JSONSerializer: ResponseSerializer {
    public init() {}
    public func serialize(data: Data) throws -> Any {
        let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
        return json
    }
}


public class IntSerializer: ResponseSerializer {
    public init() {}
    public func serialize(data: Data) throws -> Any {
        guard let int8 = [UInt8](data).last else {
           throw SerializerError.serializationError
        }
        
        let int: Int = Int(int8)
        return int
    }
}

public class StringSerializer: ResponseSerializer {
    
    public init() {}
    public func serialize(data: Data) throws -> Any {
        let string = String(data: data, encoding: .utf8)
        return string ?? ""
    }
}
