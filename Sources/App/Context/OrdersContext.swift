//
//  File.swift
//  
//
//  Created by Marina on 22.01.2021.
//

import Vapor

struct OrdersContext: Encodable {
    var orders: Orders
    
    init(orders: Orders) {
        self.orders = orders
    }
}
