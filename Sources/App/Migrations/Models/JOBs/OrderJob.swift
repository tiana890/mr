import Vapor
import Foundation
import Queues

struct OrderInfo: Codable {
    let to: String
    let message: String
}

struct OrderJob: Job {
    typealias Payload = OrderInfo

    func dequeue(_ context: QueueContext, _ payload: OrderInfo) -> EventLoopFuture<Void> {
        // This is where you would send the email
        print("DISPATCH QUEUE")
        return context.eventLoop.future()
    }

    func error(_ context: QueueContext, _ error: Error, _ payload: OrderInfo) -> EventLoopFuture<Void> {
        // If you don't want to handle errors you can simply return a future. You can also omit this function entirely.
        return context.eventLoop.future()
    }
}
