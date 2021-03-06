import Vapor
import Foundation
import Queues

struct OrderInfo: Codable {
    let figi: String
    let priceHigh: Double
    let priceLow: Double
}

struct OrderJob: Job {
    let authToken  = "t.kvibl5piK_kk9pIk4OGNmAxUyd4gybhiVvYr2DN1xeJr9XGJOVQyUBKY02RRq4Pi8vKfj1m296g1TbkmNxltuA"
    let sandboxURL = "https://api-invest.tinkoff.ru/openapi/sandbox/"
    let mainURL = "https://api-invest.tinkoff.ru/openapi/"
    
    typealias Payload = OrderInfo

    func dequeue(_ context: QueueContext, _ payload: OrderInfo) -> EventLoopFuture<Void> {
        // This is where you would send the email
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer " + authToken)
        let url = sandboxURL + "orders/market-order?figi=\(payload.figi)"
        print(URI(string: url))
        let wb = WebSocketClient(figi: payload.figi)
        return wb.connect(eventLoop: context.eventLoop) { (glass) -> EventLoopFuture<Void> in
            if let price = glass?.bids.first?.price, price < payload.priceHigh, price > payload.priceLow  {
                return context.application.client.post(URI(string: url), headers: headers, beforeSend: { (clientRequest) in
                    //print(req.parameters)
                    var orderParam = OrderParam(lots: 1, operation: .buy)
                    //balanceParam.balance = try req.content.decode(BalanceForm.self).balance ?? 123
                    try clientRequest.content.encode(orderParam)
                }).flatMap { (cr) -> EventLoopFuture<Void> in
                    return context.eventLoop.future()
                }
            } else {
                return context.eventLoop.future()
            }
        }

    }

    func error(_ context: QueueContext, _ error: Error, _ payload: OrderInfo) -> EventLoopFuture<Void> {
        // If you don't want to handle errors you can simply return a future. You can also omit this function entirely.
        return context.eventLoop.future()
    }
}
