//
//  File.swift
//  
//
//  Created by Marina on 25.02.2021.
//

import Fluent

struct CreateJob: Migration {
    // Prepares the database for storing Galaxy models.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("jobs")
            .id()
            .field("job_id", .string)
            .field("description", .string)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("jobs").delete()
    }
}
