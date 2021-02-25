import Vapor
import Leaf
import Queues
import Redis
import Fluent

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

    app.get("jobs") { (req) -> EventLoopFuture<View> in
        var keys = [String]()
        return app.redis.send(command: "KEYS", with: [RESPValue(from: "job*")])
            .map({ (respValue) -> [String] in
                keys = respValue.array!.map{ $0.string! }
                return keys
            }).flatMap{ (array) -> EventLoopFuture<[JobEntity]> in
                return JobEntity.query(on: req.db).all()
            }.flatMap { (array) -> EventLoopFuture<View> in
                let jobs = Jobs()
                let reducedKeys = keys.map{ $0.replacingOccurrences(of: "job:", with: "")}
                for el in array {
                    if (reducedKeys.contains(el.id?.uuidString ?? "")) {
                        jobs.jobList.append(JobItem(jobDescription: el.description))
                    }
                }
                return req.leaf.render("jobs", JobsContext(jobs: jobs))
            }
    }
    
    app.get("makejobfinal") { (req) -> EventLoopFuture<String> in
        if let figi = req.query[String.self, at: "figi"], let priceHigh = req.query[Double.self, at: "priceHigh"], let priceLow = req.query[Double.self, at: "priceLow"], let date = req.query[String.self, at: "date"]{
            print(figi)
            let uuid = UUID()
            let orderInfo = OrderInfo(figi: figi, priceHigh: priceHigh, priceLow: priceLow)
            let jobIdentifier = JobIdentifier(string: "\(uuid.uuidString)")
            let d = Date(timeIntervalSince1970: Double(date)!)
            
            let jE = JobEntity(id: uuid, description: "figi: \(orderInfo.figi)")
            jE.save(on: req.db)
            return req.queue.dispatch(OrderJob.self, orderInfo, maxRetryCount: 3, delayUntil: d, id: jobIdentifier).map { "OK" }
        } else {
            return req.eventLoop.future("error")
        }
    }
}


/*return app.redis.send(command: "MGET", with: array.map{ RESPValue(from: $0)}).flatMap { (respValue) -> EventLoopFuture<View> in
 let jobs = Jobs()
 (respValue.array ?? []).forEach { (value) in
     if (value.string != nil) {
         jobs.jobList.append(JobItem(jobDescription: value.string!))
     }
 }
 return req.leaf.render("jobs", JobsContext(jobs: jobs))
}**/
