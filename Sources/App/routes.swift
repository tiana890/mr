import Vapor
import Leaf
import Queues
import Redis

func routes(_ app: Application) throws {
    var msc = MarketServiceController()
    var websocketClient = WebSocketClient()
    
//    app.get { req -> EventLoopFuture<String>  in
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
    
    app.get("socket") { (req) -> EventLoopFuture<String>  in
        websocketClient.connect(req)
        return  req.eventLoop.future("OK")
    }
    
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
    
    app.get("portfolio") { req  in
        return try msc.getPortfolio(req)
    }
    
    app.get("job") { req -> EventLoopFuture<String> in
        let orderInfo = OrderInfo(to: "Contact", message: "12345")
        //return req.queue.dispatch(OrderJob.self, orderInfo, delayUntil: ).map{ "OK" }
        let date = Date().addingTimeInterval(10)
        
        return req.queue.dispatch(OrderJob.self, orderInfo, maxRetryCount: 3, delayUntil: date, id: JobIdentifier(string: orderInfo.message)).map { "OK" }
    }
}


