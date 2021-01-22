//
//  File 2.swift
//  
//
//  Created by Marina on 22.01.2021.
//

import Vapor
import Leaf
import LeafKit

/*{
  "trackingId": "c1909783f5c90037",
  "payload": {
    "positions": [
      {
        "figi": "BBG000BM2FL9",
        "ticker": "ET",
        "isin": "US29273V1008",
        "instrumentType": "Stock",
        "balance": 1,
        "blocked": 0,
        "lots": 1,
        "name": "Energy Transfer LP"
      },
      {
        "figi": "BBG0013HGFT4",
        "ticker": "USD000UTSTOM",
        "instrumentType": "Currency",
        "balance": 900,
        "blocked": 0,
        "lots": 0,
        "name": "Доллар США"
      }
    ]
  },
  "status": "Ok"
}*/

final public class Portfolio: Content {

    enum CodingKeys: String, CodingKey {
        case payload
    }

    enum PayloadCodingKeys: String, CodingKey {
        case positions
    }

    var instrumentList = [Instrument]()

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nestedContainer = try container.nestedContainer(keyedBy: PayloadCodingKeys.self, forKey: .payload)
        
        instrumentList = try nestedContainer.decode([Instrument].self, forKey: .positions)
        return

        throw DecodingError.typeMismatch(
            Portfolio.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Portfolio"))
    }
    
    public func encode(to encoder: Encoder) throws {}

}

extension Portfolio : LeafDataRepresentable {
    public var leafData: LeafData {
        .array(self.instrumentList.map{ LeafData(stringLiteral: "name: \($0.name) balance: \($0.balance)") })
    }
}
