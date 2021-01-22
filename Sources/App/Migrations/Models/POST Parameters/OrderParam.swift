//
//  File.swift
//
//
//  Created by Marina on 06.01.2021.
//

import Vapor
import Fluent
import LeafKit

public enum Operation: String {
    case buy, sell
}

final public class OrderParam: Content {
    /*{
     "lots": 0,
     "operation": "Buy"
     "price": 0
   }*/

    
    enum CodingKeys: String, CodingKey {
        case lots, operation, price
    }
    
    var lots: Int = 0
    var operation: Operation = .buy
    var price: Double = 0

    public init(lots: Int, operation: Operation) {
        self.lots = lots
        self.operation = operation
    }
    
    public init(lots: Int, operation: Operation, price: Double) {
        self.lots = lots
        self.operation = operation
        self.price = price
    }
    
    public init(from decoder: Decoder) throws {
        
        throw DecodingError.typeMismatch(
            OrderParam.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for OrderParam"))
    }
    
}

extension OrderParam: LeafDataRepresentable {
    public var leafData: LeafData {
        .dictionary(["lots": .int(lots), "operation": .string(operation.rawValue), "price": .double(price)])
    }
}


extension OrderParam: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lots, forKey: .lots)
        try container.encode(operation.rawValue, forKey: .operation)
        try container.encode(price, forKey: .price)
        return
        
        throw EncodingError.invalidValue(OrderParam.self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Wrong type for LimitOrderParam"))
    }
}

