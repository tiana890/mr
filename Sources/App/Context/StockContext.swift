//
//  File.swift
//  
//
//  Created by Marina on 22.01.2021.
//

import Foundation
import Vapor

struct StockContext: Encodable {
    var stocks: Stocks
    
    init(stocks: Stocks) {
        self.stocks = stocks
    }
}
