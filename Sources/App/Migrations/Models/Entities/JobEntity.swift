//
//  File.swift
//
//
//  Created by Marina on 10.12.2020.
//
import Fluent
import Vapor

final class JobEntity: Model, Content {
    // Name of the table or collection.
    static let schema = "jobs"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "description")
    var description: String

    init() { }

    init(id: UUID? = nil, description: String) {
        self.id = id
        self.description = description
    }
}
