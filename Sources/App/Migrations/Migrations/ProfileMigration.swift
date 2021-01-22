//
//  File.swift
//  
//
//  Created by Marina on 10.12.2020.
//
import Fluent

struct CreateProfile: Migration {
    // Prepares the database for storing Galaxy models.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("profiles")
            .id()
            .field("name", .string)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("profiles").delete()
    }
}
