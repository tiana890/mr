//
//  File.swift
//  
//
//  Created by Marina on 10.12.2020.
//

import Fluent

struct CreateShare: Migration {
    // Prepares the database for storing Galaxy models.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("shares")
            .id()
            .field("name", .string)
            .field("figi", .string)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("shares").delete()
    }
}
