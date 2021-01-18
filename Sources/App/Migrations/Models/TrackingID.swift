//
//  File.swift
//  
//
//  Created by Marina on 30.11.2020.
//

import Vapor

//trackingId: "0d76257233b6cbeb",
//payload: {
//brokerAccountType: "Tinkoff",
//brokerAccountId: "SB2242034"
//},
//status: "Ok"

final class TrackingID: Content {
    var trackingId: String
    let payload: [String: String]
    
    init() {
        trackingId = "xxx"
        payload = [:]
    }
}
