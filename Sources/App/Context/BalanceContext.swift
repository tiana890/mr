//
//  File.swift
//  
//
//  Created by Marina on 18.01.2021.
//

import Vapor

struct BalanceContext: Encodable {
    var currencies: Currencies
    var balanceParam: BalanceParam
    
    init(currencies: Currencies, balanceParam: BalanceParam) {
        self.currencies = currencies
        self.balanceParam = balanceParam
    }
}
