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
   "payload": [
     {
       "orderId": "string",
       "figi": "string",
       "operation": "Buy",
       "status": "New",
       "requestedLots": 0,
       "executedLots": 0,
       "type": "Limit",
       "price": 0
     }
   ]
 }
 */
final public class Order: Content {

    enum OrderCodingKeys: String, CodingKey {
        case orderId, figi, operation, status, requestedLots, executedLots, type, price
    }

    var orderId: String = ""
    var figi: String = ""
    var operation: String = ""
    var requestedLots: Int = 0
    var executedLots: Int = 0
    var type: String = ""
    var price: Int = 0

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: OrderCodingKeys.self)

        orderId = try container.decode(String.self, forKey: .orderId)
        figi = try container.decode(String.self, forKey: .figi)
        operation = try container.decode(String.self, forKey: .operation)
        requestedLots = try container.decode(Int.self, forKey: .requestedLots)
        executedLots = try container.decode(Int.self, forKey: .executedLots)
        type = try container.decode(String.self, forKey: .type)
        price = try container.decode(Int.self, forKey: .price)
        return

        throw DecodingError.typeMismatch(
            Order.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Order"))
    }

}

final public class Orders: Content {

    enum CodingKeys: String, CodingKey {
        case payload
    }

    enum PayloadCodingKeys: String, CodingKey {
        case orderId, figi, operation, status, requestedLots, executedLots, type, price
    }

    var orderList = [Order]()

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderList = try container.decode([Order].self, forKey: .payload)
        return

        throw DecodingError.typeMismatch(
            Orders.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Orders"))
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }

}

extension Orders : LeafDataRepresentable {
    public var leafData: LeafData {
        .array(self.orderList.map{ LeafData(stringLiteral: "orderId: \($0.orderId)") })
    }
}
