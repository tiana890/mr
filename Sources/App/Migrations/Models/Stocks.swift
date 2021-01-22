//
//  File.swift
//
//
//  Created by Marina on 14.12.2020.
//

import Vapor
import Leaf
import LeafKit
/*
 {
   "trackingId": "string",
   "status": "string",
   "payload": {
     "total": 0,
     "instruments": [
       {
         "figi": "string",
         "ticker": "string",
         "isin": "string",
         "minPriceIncrement": 0,
         "lot": 0,
         "minQuantity": 0,
         "currency": "RUB",
         "name": "string",
         "type": "Stock"
       }
     ]
   }
 }
 */
final public class Stock: Content {

    enum StockCodingKeys: String, CodingKey {
        case figi, ticker, isin, minPriceIncrement, lot, minQuantity, name, currency, type
    }

    var figi: String = ""
    var ticker: String = ""
    var isin: String = ""
    //var minPriceIncrement: Double = 0
    var lot: Int = 0
    //var minQuantity: Int = 0
    var name: String = ""
    var currency: String = ""
    var type: String = ""

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: StockCodingKeys.self)

        figi = try container.decode(String.self, forKey: .figi)
        ticker = try container.decode(String.self, forKey: .ticker)
        isin = try container.decode(String.self, forKey: .isin)
        //minPriceIncrement = try container.decode(Double.self, forKey: .minPriceIncrement)
        lot = try container.decode(Int.self, forKey: .lot)
        //minQuantity = try container.decode(Int.self, forKey: .minQuantity)
        name = try container.decode(String.self, forKey: .name)
        currency = try container.decode(String.self, forKey: .currency)
        type = try container.decode(String.self, forKey: .type)
        return

        throw DecodingError.typeMismatch(
            Stock.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Stock"))
    }

}

final public class Stocks: Content {

    enum CodingKeys: String, CodingKey {
        case payload
    }

    enum PayloadCodingKeys: String, CodingKey {
        case instruments
    }

    var stockList = [Stock]()

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nestedContainer = try container.nestedContainer(keyedBy: PayloadCodingKeys.self, forKey: .payload)
        
        stockList = try nestedContainer.decode([Stock].self, forKey: .instruments)
        return

        throw DecodingError.typeMismatch(
            Orders.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Stocks"))
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }

}

extension Stocks : LeafDataRepresentable {
    public var leafData: LeafData {
        .array(self.stockList.map{ LeafData(stringLiteral: "Stock name: \($0.name) FIGI: \($0.figi) ticker: \($0.ticker) lot: \($0.lot)") })
    }
}
