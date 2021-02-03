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
import Redis
import Queues

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
    
    func getOrders(_ req: Request) throws -> EventLoopFuture<View> {
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer " + authToken)
        let url = sandboxURL + "orders"
        //https://api-invest.tinkoff.ru/openapi/sandbox/orders
        print(URI(string: url))
        return req.client.get(URI(string: url), headers: headers).flatMapThrowing { (clientResponse) -> Orders in
            return try clientResponse.content.decode(Orders.self)
        }.flatMap { (orders) -> EventLoopFuture<View> in
            return req.leaf.render("orders", OrdersContext(orders: orders))
        }
    }
    
    func setOrderInSandbox(_ req: Request) throws -> EventLoopFuture<View> {
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer " + authToken)
        let url = sandboxURL + "orders/market-order?figi=BBG002293PJ4"
        print(URI(string: url))
    
        return req.client.post(URI(string: url), headers: headers, beforeSend: { (clientRequest) in
            print(req.parameters)
            var orderParam = OrderParam(lots: 1, operation: .sell)
            //balanceParam.balance = try req.content.decode(BalanceForm.self).balance ?? 123
            try clientRequest.content.encode(orderParam)
        }).flatMap { (cr) -> EventLoopFuture<View> in
            do {
                return try self.getPortfolio(req)
            } catch {
                return req.view.render("index")
            }
        }
    }
    
    func makeJob(_ req: Request) throws -> EventLoopFuture<Response> {
//        let makeOrderForm = try req.content.decode(MakeOrderForm.self)
//        let orderInfo = OrderInfo(figi: makeOrderForm.figi, priceHigh: Double(makeOrderForm.highPrice)!, priceLow: Double(makeOrderForm.lowPrice)!)
//        let jobIdentifier = JobIdentifier(string: "job:\(UUID.init().uuidString)")
//        let date = Date().addingTimeInterval(10)
//        return req.queue.dispatch(OrderJob.self, orderInfo, maxRetryCount: 3, delayUntil: date, id: jobIdentifier).flatMap { () -> EventLoopFuture<View> in
//            return req.view.render("index")
//        }
        
        let orderInfo = OrderInfo(figi: "BBG000BM2FL9", priceHigh: 7.0, priceLow: 6.0)
        let jobIdentifier = JobIdentifier(string: "job:\(UUID.init().uuidString)")
        let date = Date().addingTimeInterval(5)
        let request = req.redirect(to: "/makejobfinal?figi=\(orderInfo.figi)&priceHigh=\(orderInfo.priceHigh)&priceLow=\(orderInfo.priceLow)&jobIdentifier=\(jobIdentifier)")
        
        return req.eventLoop.makeSucceededFuture(request)
        //return req.queue.dispatch(OrderJob.self, orderInfo, maxRetryCount: 3, delayUntil: date, id: jobIdentifier).map { "OK" }
    }
    
//    func makeJobFinal(_ req: Request) throws -> EventLoopFuture<String> {
//        return req.leaf.render("makeorder")
//    }
    
    func makeOrder(_ req: Request) throws -> EventLoopFuture<View> {
        return req.leaf.render("makeorder")
    }
    
    func getPortfolio(_ req: Request) throws -> EventLoopFuture<View> {
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer " + authToken)
        let url = sandboxURL + "portfolio"
        print(URI(string: url))
        print("Current date is \(Date())")
        return req.client.get(URI(string: url), headers: headers).flatMapThrowing { (clientResponse) -> Portfolio in
            let portfolio = try clientResponse.content.decode(Portfolio.self)
            return portfolio
        }.flatMap { (value) -> EventLoopFuture<View> in
            return req.leaf.render("portfolio", PortfolioContext(instruments: value.instrumentList))
        }
    }
    
    func getStocks(_ req: Request) throws -> EventLoopFuture<Stocks> {
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer " + authToken)
        let url = sandboxURL + "market/stocks"
        print(URI(string: url))
        return req.client.get(URI(string: url), headers: headers).flatMapThrowing { (clientResponse) -> Stocks in
            let stocks = try clientResponse.content.decode(Stocks.self)
            return stocks
        }
    }
    
    func getStocksView(_ req: Request) throws -> EventLoopFuture<View> {
        return try self.getStocks(req).flatMap { (value) -> EventLoopFuture<View> in
            return req.leaf.render("stocks", StockContext(stocks: value))
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
//        return req.client.post(URI(string: url), headers: headers, beforeSend: { (clientRequest) in
//            print(req.parameters)
//            var orderParam = OrderParam(lots: 5, operation: .buy)
//            //balanceParam.balance = try req.content.decode(BalanceForm.self).balance ?? 123
//            try clientRequest.content.encode(orderParam)
//        }).flatMap { (cr) -> EventLoopFuture<View> in
//            do {
//                return try self.getPortfolio(req)
//            } catch {
                //return req.view.render("index")
//            }
//        }
//
//        let orderInfo = OrderInfo(figi: "BBG000BM2FL9", priceHigh: 7.0, priceLow: 6.0)
//        let jobIdentifier = JobIdentifier(string: "job:\(UUID.init().uuidString)")
//        let date = Date().addingTimeInterval(1)
//        return req.queue.dispatch(OrderJob.self, orderInfo, maxRetryCount: 3, delayUntil: date, id: jobIdentifier).map { "OK" }
