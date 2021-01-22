//
//  File.swift
//  
//
//  Created by Marina on 22.01.2021.
//

import Vapor

struct PortfolioContext: Encodable {
    var instruments: [Instrument]
    
    init(instruments: [Instrument]) {
        self.instruments = instruments
    }
}
