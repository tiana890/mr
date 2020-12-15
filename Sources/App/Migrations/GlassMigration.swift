//
//  File.swift
//  
//
//  Created by Marina on 11.12.2020.
//

import Fluent

struct CreateGlass: Migration {
    // Prepares the database for storing Galaxy models.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("glass")
            .id()
            .field("share_id", .uuid, .required, .references("shares", "id"))
            .field("json_string", .string)
            .field("date", .date)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
       database.schema("glass").delete()
    }

}

struct DeleteGlass: Migration {
    // Prepares the database for storing Galaxy models.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("glass").delete()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
       database.schema("glass").delete()
    }
}
