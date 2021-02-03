import Vapor
import Leaf
import Queues
import Redis

func routes(_ app: Application) throws {
    var msc = MarketServiceController()
    var websocketClient = WebSocketClient(figi: "")
    
//    app.get { req -> EventLoopFuture<String>  i
//        return try msc.getInformationAboutClient(req)
//    }
    app.get { req in
        try msc.indexHandler(req)
    }

    app.get("register") { req in
        try msc.registerInMarketAPI(req)
    }
    
    app.get("orders") { req   in
        return try msc.getOrders(req)
    }
    
//    app.get("socket") { (req) -> EventLoopFuture<String>  in
//        websocketClient.connect(req)
//        return  req.eventLoop.future("OK")
//    }
    
//    app.get("shares") { req -> EventLoopFuture<[Share]> in
//        //let profile = try req.content.decode(Profile.self)
//        var share = Share(name: "ET", figi: "BBG000BM2FL9")
//        share.create(on: req.db)
//        return Share.query(on: req.db).all()
//    }
    
    app.get("balance") { req  in
        return try msc.getBalanceInfo(req)
    }
    
    app.post("setbalance", use: msc.setBalanceInSandbox(_:))
    
    app.get("stocks") { req  in
        return try msc.getStocksView(req)
    }
    
    app.post("setorder", use: msc.setOrderInSandbox(_:))
    
    app.post("makejob", use: msc.makeJob(_:))
    
    app.get("makeorder") { req in
        return try msc.makeOrder(req)
    }
    
    app.get("portfolio") { req  in
        return try msc.getPortfolio(req)
    }
    
    app.get("job") { req -> EventLoopFuture<String> in
        let orderInfo = OrderInfo(figi: "BBG000BM2FL9", priceHigh: 7.0, priceLow: 6.0)
        let jobIdentifier = JobIdentifier(string: "job:\(UUID.init().uuidString)")
        let date = Date().addingTimeInterval(5)
        return req.queue.dispatch(OrderJob.self, orderInfo, maxRetryCount: 3, delayUntil: date, id: jobIdentifier).map { "OK" }
    }

    app.get("redis") { (req) -> EventLoopFuture<[String]> in
        return try app.redis.send(command: "KEYS", with: [RESPValue(from: "job*")])
            .flatMap({ (respValue) -> EventLoopFuture<[String]> in
                return req.eventLoop.future(respValue.array!.map{ $0.string! })
            })
    }
    
    app.get("makejobfinal") { (req) -> EventLoopFuture<String> in
        if let figi = req.query[String.self, at: "figi"], let priceHigh = req.query[Double.self, at: "priceHigh"], let priceLow = req.query[Double.self, at: "priceLow"] {
            print(figi)
            let orderInfo = OrderInfo(figi: figi, priceHigh: priceHigh, priceLow: priceLow)
            let jobIdentifier = JobIdentifier(string: "job:\(UUID.init().uuidString)")
            let date = Date().addingTimeInterval(5)
            return req.queue.dispatch(OrderJob.self, orderInfo, maxRetryCount: 3, delayUntil: date, id: jobIdentifier).map { "OK" }
        } else {
            return req.eventLoop.future("error")
        }
    }
}


