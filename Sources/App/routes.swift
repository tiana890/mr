import Vapor

func routes(_ app: Application) throws {
    var msc = MarketServiceController()
    var websocketClient = WebSocketClient()
    
    app.get { req in
        return "It works!"
    }
//
    app.get("register") { req -> EventLoopFuture<String>  in
        return try msc.registerInMarketAPI(req)
    }
    
    app.get("orders") { req -> EventLoopFuture<[String]>  in
        return try msc.getOrderList(req)
    }
    
    app.get("socket") { (req) -> EventLoopFuture<String>  in
        websocketClient.connect(req)
        return  req.eventLoop.future("OK")
    }
    
    app.get("shares") { req -> EventLoopFuture<[Share]> in
        //let profile = try req.content.decode(Profile.self)
        var share = Share(name: "ET", figi: "BBG000BM2FL9")
        share.create(on: req.db)
        return Share.query(on: req.db).all()
    }
    
    
    
}


