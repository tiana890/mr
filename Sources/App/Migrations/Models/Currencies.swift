//
//  File.swift
//  
//
//  Created by Marina on 06.01.2021.
//

import Vapor
import LeafKit
/*{
  "trackingId": "d0e4be19f7c5c34a",
  "payload": {
    "currencies": [
      {
        "currency": "EUR",
        "balance": 0
      },
      {
        "currency": "RUB",
        "balance": 3000
      },
      {
        "currency": "USD",
        "balance": 0
      }
    ]
  },
  "status": "Ok"
}*/
final public class Currency: Content {
    var currency: String = ""
    var balance: Int = 0
    
    enum CurrencyKeys: String, CodingKey {
        case currency, balance
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CurrencyKeys.self)
        if let currency = try? container.decode(String.self, forKey: .currency) {
            self.currency = currency
            if let balance = try? container.decode(Int.self, forKey: .balance) {
                self.balance = balance
            }
            return
        }
        
        throw DecodingError.typeMismatch(
            Currency.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Currency"))
    }
    
    public func encode(to encoder: Encoder) throws {
//        var container = try encoder.unkeyedContainer()
//
//        let array = [price, Double(count)]
//        try container.encode(array)

        throw EncodingError.invalidValue(Currency.self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Wrong type for Currency"))
    }
}


final public class Currencies: Content {

    enum CodingKeys: String, CodingKey {
        case payload
    }

    enum PayloadCodingKeys: String, CodingKey {
        case currencies
    }

    var list: [Currency]
    

    public init() {
        //event = "Error"
        list = []
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
            
        let nestedContainer = try container.nestedContainer(keyedBy: PayloadCodingKeys.self, forKey: .payload)
        
        list = try nestedContainer.decode([Currency].self, forKey: .currencies)

        return

        throw DecodingError.typeMismatch(
            Glass.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Glass"))
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
    
    func getStringValue() -> String {
        var str = ""
        for el in list {
            str += "\n" + "currency: \(el.currency) balance: \(el.balance)"
        }
        return str
    }
    
    func getRUBBalance() -> Int? {
        return self.list.firstIndex(where: { $0.currency == "RUB" })
    }
}

extension Currencies : LeafDataRepresentable {
    public var leafData: LeafData {
        .array(self.list.map{ LeafData(stringLiteral: "currency: \($0.currency) balance: \($0.balance)") })
    }
}
