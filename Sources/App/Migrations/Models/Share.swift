//
//  File.swift
//  
//
//  Created by Marina on 10.12.2020.
//

import Fluent
import Vapor

final class Share: Model, Content {
    // Name of the table or collection.
    static let schema = "shares"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "figi")
    var figi: String

    init() { }

    init(id: UUID? = nil, name: String, figi: String) {
        self.id = id
        self.name = name
        self.figi = figi
    }
    
    
}
