//
//  File.swift
//  
//
//  Created by Marina on 28.11.2020.
//

import Vapor
import AsyncKit
import AsyncHTTPClient
import Fluent

final class MarketServiceController {
    let authToken  = "t.kvibl5piK_kk9pIk4OGNmAxUyd4gybhiVvYr2DN1xeJr9XGJOVQyUBKY02RRq4Pi8vKfj1m296g1TbkmNxltuA"
    let sandboxURL = "https://api-invest.tinkoff.ru/openapi/sandbox/sandbox/"
    
    var accountInfo: AccountInfo?
    
    func getInformationAboutClient(_ req: Request) throws -> EventLoopFuture<String> {
        if let accInfo = accountInfo {
            return req.eventLoop.future("Client with brokerID \(accInfo.brokerAccountId!) and trackingID \(accInfo.trackingId!) was registered")
        }
        return req.eventLoop.future("Client is not registered")
    }
    
    func registerInMarketAPI(_ req: Request) throws -> EventLoopFuture<String> {
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer " + authToken)
        let url = sandboxURL + "register"
        print(URI(string: url))
    
        return req.client.post(URI(string: url), headers: headers).flatMapThrowing { (cr) -> String in
            let trackingId =  try cr.content.decode(TrackingID.self).trackingId
            let brokerId = try cr.content.decode(TrackingID.self).payload["brokerAccountId"] ?? "c"
            let accInfo = AccountInfo(bId: brokerId, tId: trackingId)
            self.accountInfo = accInfo
            return "Client with brokerID \(brokerId) and trackingID \(trackingId) was registered"
        }
    }
    
    func setBalanceInSandbox(_ req: Request) throws -> EventLoopFuture<String> {
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer " + authToken)
        let url = sandboxURL + "currencies/balance"
        print(URI(string: url))
        return req.client.post(URI(string: url), headers: headers, beforeSend: { (clientRequest) in
            let balanceParam = BalanceParam(currency: "RUB", balance: 2000)
            try clientRequest.content.encode(balanceParam)
        }).flatMapThrowing { (clientResponse) -> String in
            print(clientResponse.content)
            return "OK"
        }
    }
    
    func getBalanceInfo(_ req: Request) throws -> EventLoopFuture<String> {
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer " + authToken)
        let url = sandboxURL + "portfolio/currencies"
        print(URI(string: url))
        return req.client.post(URI(string: url), headers: headers).flatMapThrowing { (clientResponse) -> String in
            
            print(clientResponse.content)
            return "OK"
        }
    }
    
    
    
}
