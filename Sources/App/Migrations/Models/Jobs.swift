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

    var jobDescription: String = ""

    public init(jobDescription: String) {
        self.jobDescription = jobDescription
    }
}

final public class Jobs: Content {

    var jobList = [JobItem]()

}

extension Jobs : LeafDataRepresentable {
    public var leafData: LeafData {
        .array(self.jobList.map{ LeafData(stringLiteral: "\($0.jobDescription)") })
    }
}
