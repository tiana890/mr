//
//  File.swift
//  
//
//  Created by Marina on 14.12.2020.
//

import Vapor

final public class GlassTime: Content {
    
    enum CodingKeys: String, CodingKey {
        case time
    }

    private var isoDate: String = ""
    var date: Date
    /*
     {"payload":{"figi":"BBG0013HGFT4","depth":10,"bids":[[73.24,391],[73.2375,240],[73.235,438],[73.2325,492],[73.23,337],[73.2275,390],[73.225,350],[73.2225,720],[73.22,538],[73.2175,370]],"asks":[[73.2475,193],[73.25,226],[73.2525,450],[73.255,889],[73.2575,340],[73.26,700],[73.2625,94],[73.265,428],[73.2675,1201],[73.27,150]]},"event":"orderbook","time":"2020-12-08T12:31:18.492261389Z"
     **/
    public init() {
        date = Date()
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isoDate = try container.decode(String.self, forKey: .time)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSSZ"
        self.date = dateFormatter.date(from:isoDate)!
        return

        throw DecodingError.typeMismatch(
            GlassTime.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for GlassTime"))
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
    
}


