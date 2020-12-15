//
//  File.swift
//  
//
//  Created by Marina on 14.12.2020.
//

import Fluent
import Vapor

final public class GlassEntity: Model {

    public static let schema = "glass"
    
    @Field(key: "share_id")
    var shareId: UUID

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "json_string")
    var jsonString: String
    
    @Field(key: "date")
    var date: Date

    public init() {
        
    }
    
    init(id: UUID? = nil, share: UUID, jsonString: String, date: Date) {
        self.id = id
        self.jsonString = jsonString
        self.shareId = share
        self.date = date
    }
}
