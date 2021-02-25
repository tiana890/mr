//
//  File.swift
//  
//
//  Created by Marina on 24.02.2021.
//
import Vapor

struct JobsContext: Encodable {
    var jobs: Jobs
    
    init(jobs: Jobs) {
        self.jobs = jobs
    }
}
