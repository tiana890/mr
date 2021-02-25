//
//  File.swift
//  
//
//  Created by Marina on 25.02.2021.
//

import Vapor
import LeafKit
import Leaf
import Redis
import Queues
import Fluent

final class JobController {
    func deleteJob(_ req: Request) throws -> EventLoopFuture<Response> {
        let param = req.parameters.get("jobid") ?? "unknown"
        /*req.redis.send(command: "DEL", with: [RESPValue(from: "job:\(param)")])
            .map({ (respValue) -> String in
                print(respValue.int)
                return "OK"
            })*/
        return JobEntity.query(on: req.db).all().flatMap { (jobEntities) -> EventLoopFuture<Response> in
            if let el = jobEntities.first(where: { $0.id!.uuidString == param }) {
                return el.delete(on: req.db).flatMap { () -> EventLoopFuture<Response> in
                    return req.eventLoop.future(req.redirect(to: "/jobs"))
                }
            } else {
                return req.eventLoop.future(req.redirect(to: "/index"))
            }
        }
        
    }
}
