//
//  File.swift
//  
//
//  Created by Marina on 06.01.2021.
//

import Vapor

final public class BalanceParam: Content {
    /*{
      "currency": "RUB",
      "balance": 0
    }*/
    
    enum CodingKeys: String, CodingKey {
        case currency, balance
    }
    
    var currency: String
    var balance: Int

    public init(currency: String, balance: Int) {
        self.currency = currency
        self.balance = balance
    }
    
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        event = try container.decode(String.self, forKey: .event)
//
//        let nestedContainer = try container.nestedContainer(keyedBy: PayloadCodingKeys.self, forKey: .payload)
//        figi = try nestedContainer.decode(String.self, forKey: .figi)
//        depth = try nestedContainer.decode(Int.self, forKey: .depth)
//        bids = try nestedContainer.decode([Lot].self, forKey: .bids)
//        asks = try nestedContainer.decode([Lot].self, forKey: .asks)
//        return
//
//        throw DecodingError.typeMismatch(
//            Glass.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Glass"))
//    }
    
}
extension BalanceParam: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(balance, forKey: .balance)
        try container.encode(currency, forKey: .currency)
        return 
        
        throw EncodingError.invalidValue(BalanceParam.self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Wrong type for Balance Param"))
    }
}
