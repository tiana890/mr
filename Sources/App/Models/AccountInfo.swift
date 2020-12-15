//
//  File.swift
//  
//
//  Created by Marina on 30.11.2020.
//

import Vapor

final public class AccountInfo {
    var brokerAccountId: String?
    var trackingId: String?
    
    public init(bId: String, tId: String) {
        self.brokerAccountId = bId
        self.trackingId = tId
    }
}
