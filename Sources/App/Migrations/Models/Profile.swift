//
//  File.swift
//  
//
//  Created by Marina on 10.12.2020.
//
import Fluent
import Vapor

final class Profile: Model, Content {
    // Name of the table or collection.
    static let schema = "profiles"

    // Unique identifier for this Planet.
    @ID(key: .id)
    var id: UUID?

    // The Planet's name.
    @Field(key: "name")
    var name: String

    // Creates a new, empty Profile.
    init() { }

    // Creates a new Planet with all properties set.
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
