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
import LeafKit
import Leaf

final class MarketServiceController {
    let authToken  = "t.kvibl5piK_kk9pIk4OGNmAxUyd4gybhiVvYr2DN1xeJr9XGJOVQyUBKY02RRq4Pi8vKfj1m296g1TbkmNxltuA"
    let sandboxURL = "https://api-invest.tinkoff.ru/openapi/sandbox/"
    let mainURL = "https://api-invest.tinkoff.ru/openapi/"
    
    var accountInfo: AccountInfo?
    
    func getInformationAboutClient(_ req: Request) throws -> EventLoopFuture<String> {
        if let accInfo = accountInfo {
            return req.eventLoop.future("Client with brokerID \(accInfo.brokerAccountId) and trackingID \(accInfo.trackingId) was registered")
        }
        return req.eventLoop.future("Client is not registered")
    }
    
    func registerInMarketAPI(_ req: Request) throws -> EventLoopFuture<View> {
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer " + authToken)
        let url = sandboxURL + "sandbox/register"
        print(URI(string: url))
        return try req.client.post(URI(string: url), headers: headers).flatMap({ (cr) -> EventLoopFuture<View> in
            do {
                if let trackingId =  try? cr.content.decode(TrackingID.self).trackingId {
                    let brokerId = try? cr.content.decode(TrackingID.self).payload["brokerAccountId"] ?? "c"
                    let accInfo = AccountInfo(bId: brokerId!, tId: trackingId)
                    self.accountInfo = accInfo
                    return try req.view.render("register", ["result": "client with brokerid \(self.accountInfo?.brokerAccountId) registered successfully"])
                } else {
                    return try req.view.render("register", ["result": "register error"])
                }
            } catch let error {
                return req.view.render("register", ["result": "register error"])
            }
        })
    }
    
    func setBalanceInSandbox(_ req: Request) throws -> EventLoopFuture<View> {
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer " + authToken)
        let url = sandboxURL + "sandbox/currencies/balance"
        print(URI(string: url))
    
        return req.client.post(URI(string: url), headers: headers, beforeSend: { (clientRequest) in
            print(req.parameters)
            var balanceParam = BalanceParam(currency: "RUB", balance: 0)
            balanceParam.balance = try req.content.decode(BalanceForm.self).balance ?? 123
            try clientRequest.content.encode(balanceParam)
        }).flatMap { (cr) -> EventLoopFuture<View> in
            do {
                return try self.getBalanceInfo(req)
            } catch {
                return req.view.render("balance")
            }
        }
    }
    
    func getBalanceInfo(_ req: Request) throws -> EventLoopFuture<View> {
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer " + authToken)
        let url = sandboxURL + "portfolio/currencies"
        //https://api-invest.tinkoff.ru/openapi/sandbox/portfolio/currencies
        print(URI(string: url))
        return req.client.get(URI(string: url), headers: headers).flatMapThrowing { (clientResponse) -> Currencies in
            let currencies = try clientResponse.content.decode(Currencies.self)
            return currencies
        }.flatMap { (value) -> EventLoopFuture<View> in
            var balanceParam = BalanceParam(currency: "RUB", balance: value.getRUBBalance() ?? 0)
            return req.leaf.render("balance", BalanceContext(currencies: value, balanceParam: balanceParam))
        }
    }
    
    func indexHandler(_ req: Request) throws -> EventLoopFuture<View> {
        if let accInfo = self.accountInfo {
            return try req.view.render("index", ["accountInfo": accInfo.brokerAccountId])
        } else {
            return try req.view.render("index")
        }
    }
    
}

struct BalanceForm: Content {
  var balance: Int
}
