//
//  Job.swift
//  App
//
//  Created by MAC001 on 22/04/19.
//

import Foundation

final class JobController: Controlling {
    fileprivate let log: LogProtocol
    
    init(log: LogProtocol) throws {
        self.log = log
    }
    
    func addOpenRoutes(drop: Droplet) {
        drop.get("job") { req in return try self.get(req) }
    }
    
    
    func addGroupedRoutes(group: RouteBuilder) {
        group.post("job") { req in return try self.post(req) }
        group.patch("job") { req in return try self.patch(req) }
        group.delete("job") { req in return try self.delete(req) }
        
        group.get("job/lookup", String.parameter) { req in
            print("============\n\(req)")
            let lookupid = try req.parameters.next(String.self)
            guard let aJob = try Job.makeQuery()
                .filter(Job.DB.id.ⓡ, lookupid)
                .first()
                else {
                    throw Abort(.badRequest, reason: "Job: \(lookupid) does not exist")
            }
            return aJob
        }
    }
    fileprivate func get(_ req: Request) throws -> JSON {
        
        let jobQuery = try Job.makeQuery()
        
        var json = JSON()
        try json.set("status", "ok")
        
        try json.set("jobs", jobQuery.all())
        return json
    }
   
    fileprivate func post(_ req: Request) throws -> JSON {
        //log.error("• in vendings.post()\n\(req)")
        guard let json = req.json else { throw Abort(.badRequest, reason: "No JSON in job post") }
        
        var jobTry: Job?
        do {
            jobTry = try Job(json: json)
        } catch let error as Debuggable {
            jobTry = nil
            throw Abort(.badRequest, reason: error.reason, identifier: error.identifier)
        }
        guard let job = jobTry else {
            throw Abort(.badRequest, reason: "Could not construct job")
        }
        
        do {
            try job.save()
        } catch let error as Debuggable {
            throw Abort(.badRequest, reason: error.reason, identifier: error.identifier)
        }
        var jobJSON = JSON()
        try jobJSON.set("status", "ok")
        try jobJSON.set("job", job)
        return jobJSON
    }
    
    fileprivate func getJob(from req: Request) throws -> Job {
        guard let json = req.json else { throw Abort(.badRequest, reason: "Missing JSON") }
        let jobID: String = try json.get(Job.DB.id.ⓡ)
        guard let job = try Job.makeQuery()
            .filter(Job.DB.id.ⓡ, jobID)
            .first()
            else {
                throw Abort(.badRequest, reason: "Job: \(jobID) does not exist")
        }
        return job
    }
    
    // PATCH one
    fileprivate func patch(_ req: Request) throws -> JSON {
        // See `extension Event: Updateable`
        let job = try getJob(from: req)
        
        try job.save()
        
        var jobJSON = JSON()
        try jobJSON.set("status", "ok")
        try jobJSON.set("job", job)
        return jobJSON
    }
    
    // DELETE one
    fileprivate func delete(_ req: Request) throws -> JSON {
        let job = try getJob(from: req)
        try job.delete()
        var okJSON = JSON()
        try okJSON.set("status", "ok")
        return okJSON
    }
}
