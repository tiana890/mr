//
//  File.swift
//  
//
//  Created by Marina on 01.12.2020.
//
import Vapor

open class WebSocketClient {
    let authToken  = "t.kvibl5piK_kk9pIk4OGNmAxUyd4gybhiVvYr2DN1xeJr9XGJOVQyUBKY02RRq4Pi8vKfj1m296g1TbkmNxltuA"
    let sandboxURL = "https://api-invest.tinkoff.ru/openapi/sandbox/sandbox/"
    let websocketURL = "wss://api-invest.tinkoff.ru/openapi/md/v1/md-openapi/ws"
    
    var figi: String

    public init (figi: String){
        self.figi = figi
    }
    
    func connect(eventLoop: EventLoop, callback: @escaping (Glass?) -> (EventLoopFuture<Void>)) -> EventLoopFuture<Void> {
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer " + authToken)
 
        return WebSocket.connect(to: websocketURL, headers: headers, on: eventLoop) { (ws) in
            let payload = "{\"event\": \"orderbook:subscribe\", \"figi\": \"\(self.figi)\", \"depth\": 2}"
            
            ws.send(payload)
            ws.onText { ws, text in
                do {
                    let data = text.data(using: .utf8)!
                    let glass = try JSONDecoder().decode(Glass.self, from: data)
                    callback(glass)
                    ws.close()
                } catch let error {
                    callback(nil)
                }
            }
        }.flatMap { () -> EventLoopFuture<Void> in
            return eventLoop.future()
        }
    }
}


//        Share.query(on: req.db).first().map({ (share) -> () in
//            WebSocket.connect(to: "wss://api-invest.tinkoff.ru/openapi/md/v1/md-openapi/ws", headers: headers, on: req.eventLoop) { (ws) in
//                var dict = Dictionary<String, String>()
//                dict["event"] = "orderbook:subscribe"
//                dict["figi"] = "BBG000BM2FL9"
//                dict["depth"] = "10"
//
//                ws.send("{\"event\": \"orderbook:subscribe\", \"figi\": \"BBG000BM2FL9\", \"depth\": 10}")
//                ws.onText { ws, text in
//                    print("text")
//                    do {
//                        let data = text.data(using: .utf8)!
//                        let glassEntity = GlassEntity(share: share!.id!, jsonString: text)
//                        glassEntity.save(on: req.db)
//                        //let glass = try JSONDecoder().decode(Glass.self, from: data)
//                        //glass.jsonString = text
//                        //print("\(encoder)"
//
//                    } catch let error {
//                        print(error.localizedDescription)
//                    }
//                }
//            }
//        })

//WebSocket.connect(to: "wss://api-invest.tinkoff.ru/openapi/md/v1/md-openapi/ws", headers: headers, on: req.eventLoop) { (ws) in
//    var dict = Dictionary<String, String>()
//    dict["event"] = "orderbook:subscribe"
//    dict["figi"] = self.figi//"BBG000BM2FL9"
//    dict["depth"] = "2"
//
//    ws.send("{\"event\": \"orderbook:subscribe\", \"figi\": \"\(self.figi)\", \"depth\": 10}")
//    ws.onText { ws, text in
//        print("text")
//        do {
//            let data = text.data(using: .utf8)!
//
//            let glassTime = try JSONDecoder().decode(GlassTime.self, from: data)
//            let glassEntity = GlassEntity(share: UUID(uuidString: "A7FC1531-7754-4048-8912-4DEA56E010E9")!, jsonString: text, date: glassTime.date)
//            glassEntity.save(on: req.db)
//            //glass.jsonString = text
//            //print("\(encoder)"
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
//}
