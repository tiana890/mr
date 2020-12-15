//
//  File.swift
//  
//
//  Created by Marina on 08.12.2020.
//

import Vapor
import Fluent

final public class Lot: Content {
    var price: Double
    var count: Int
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode([Double].self), value.count == 2 {
            self.price = value[0]
            self.count = Int(value[1])
            return
        }
       
        throw DecodingError.typeMismatch(
            Lot.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Lot"))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = try encoder.unkeyedContainer()
        
        let array = [price, Double(count)]
        try container.encode(array)
            
        throw EncodingError.invalidValue(Lot.self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Wrong type for Lot"))
    }
}

final public class Glass: Content {
    
    enum CodingKeys: String, CodingKey {
        case payload, event
    }
    
    enum PayloadCodingKeys: String, CodingKey {
        case figi, depth, bids, asks
    }

    var payload: String?
    var figi: String = ""
    var depth: Int = 0
    var bids: [Lot] = []
    var asks: [Lot] = []
    var event: String

    /*
     {"payload":{"figi":"BBG0013HGFT4","depth":10,"bids":[[73.24,391],[73.2375,240],[73.235,438],[73.2325,492],[73.23,337],[73.2275,390],[73.225,350],[73.2225,720],[73.22,538],[73.2175,370]],"asks":[[73.2475,193],[73.25,226],[73.2525,450],[73.255,889],[73.2575,340],[73.26,700],[73.2625,94],[73.265,428],[73.2675,1201],[73.27,150]]},"event":"orderbook","time":"2020-12-08T12:31:18.492261389Z"
     **/
    public init() {
        event = "Error"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        event = try container.decode(String.self, forKey: .event)
            
        let nestedContainer = try container.nestedContainer(keyedBy: PayloadCodingKeys.self, forKey: .payload)
        figi = try nestedContainer.decode(String.self, forKey: .figi)
        depth = try nestedContainer.decode(Int.self, forKey: .depth)
        bids = try nestedContainer.decode([Lot].self, forKey: .bids)
        asks = try nestedContainer.decode([Lot].self, forKey: .asks)
        return

        throw DecodingError.typeMismatch(
            Glass.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Glass"))
    }
    
}


extension Glass: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(event, forKey: .event)
        
        var nestedContainer = container.nestedContainer(keyedBy: PayloadCodingKeys.self, forKey: .payload)
        try nestedContainer.encode(figi, forKey: .figi)
        try nestedContainer.encode(depth, forKey: .depth)
        try nestedContainer.encode(bids, forKey: .bids)
        try nestedContainer.encode(asks, forKey: .asks)
        
        throw EncodingError.invalidValue(Glass.self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Wrong type for Glass"))
    }
}
