//
//  File.swift
//  
//
//  Created by Marina on 30.11.2020.
//

import Vapor
import LeafKit

final public class AccountInfo {
    var brokerAccountId: String
    var trackingId: String
    
    public init(bId: String, tId: String) {
        self.brokerAccountId = bId
        self.trackingId = tId
    }
}

extension AccountInfo : LeafDataRepresentable {
    public var leafData: LeafData {
        .dictionary([
            "brokerAccountId": LeafData(stringLiteral: brokerAccountId),
            "trackingId": LeafData(stringLiteral: trackingId),
        ])
    }
}
