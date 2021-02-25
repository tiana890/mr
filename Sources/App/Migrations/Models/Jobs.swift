//
//  File.swift
//
//
//  Created by Marina on 14.12.2020.
//

import Vapor
import Leaf
import LeafKit

final public class JobItem: Content {

    var jobId: String
    var jobDescription: String = ""

    public init(jobId: String, jobDescription: String) {
        self.jobId = jobId
        self.jobDescription = jobDescription
    }
    
}

extension JobItem: LeafDataRepresentable {
    public var leafData: LeafData {
        .dictionary(["id": LeafData(stringLiteral: self.jobId), "description": LeafData(stringLiteral: self.jobDescription)])
    }
}

final public class Jobs: Content {

    var jobList = [JobItem]()

}

extension Jobs : LeafDataRepresentable {
    public var leafData: LeafData {
        .array(self.jobList.map{ $0.leafData })
    }
}
