//
//  Job.swift
//  App
//
//  Created by MAC001 on 22/04/19.
//

import Foundation
import VaporAPNS
import FluentProvider
import Fluent

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
        
        //----------------------
        
        /*
 */

     /*   let notificationTry = try Notification(id: UUID().uuidString, jobId: job.id!, title: "New nvent near you!", desc: "Some one posted new event newar you! Express your interest.", status: "default", fromUserId: job.userId, to: "all", type: "1_openJob")

        
//        let notificationTry = try Notification(jobId: Identifier(UUID().uuidString), title: "New nvent near you!", desc: "Some one posted new event newar you! Express your interest.", status: "default", fromUserId: job.userId, to: "all", type: "1_openJob")

        do {
            try notificationTry.save()
        } catch let error as Debuggable {
            throw Abort(.badRequest, reason: error.reason, identifier: error.identifier)
        }*/
        
        print("test0001")
        try sendPushNotification(req)
        print("test0002")
        
        
        //----------------------
        
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
    
    
    fileprivate func sendPushNotification(_ req: Request) throws{
        //--------
        print("test0003")

        let folderPath = #file.components(separatedBy: "/").dropLast().joined(separator: "/")
        let filePath = "\(folderPath)/AuthKey_CNQ574ZKF6.p8"
        
        
        let options = try! Options(topic: Constants.AppBundleIdentifier, teamId: Constants.DeveloperAccount.TeamId, keyId: Constants.DeveloperAccount.APNS_Key_Id, keyPath: filePath)
        let vaporAPNS = try VaporAPNS(options: options)
        print("test0004")
        let payload = Payload(title: "Events near you!", body: "New event posted near you!")
        
        let pushMessage = ApplePushMessage(topic: nil, priority: .immediately, payload: payload, sandbox: true)
        print("test0005")
//        let result = vaporAPNS.send(pushMessage, to: "1BCD7FC189EEB4AB49DDFFA20EBB2FCC67CD5DA86FFF49EA9CE8C92C7943A2BA")
        
//        print("result_sendPushNotification : \(result)")
        
        //---------

        
        guard let tokenQuery : [DeviceToken] = try DeviceToken.makeQuery()
            .join(kind: .inner, Vending.self, baseKey: "user_id", joinedKey: "user_id")
            .all()
            else {
                throw Abort(.badRequest, reason: "tokenQuery does not exist")
        }

        print(tokenQuery)
        
        var array_tokens = [String]()
        for aData in tokenQuery {
            print("aTken >>>>> \(aData.dToken)")
            array_tokens.append(aData.dToken)
        }
        
        print("array_token: \(array_tokens)")
        
        vaporAPNS.send(pushMessage, to: array_tokens) { result in
            print(result)
            if case let .success(messageId,deviceToken,serviceStatus) = result, case .success = serviceStatus {
                print ("Success!")
                print("messageId: \(messageId)  |||  deviceToken: \(deviceToken)  |||  serviceStatus:\(serviceStatus)")
            }
        }
        
        
        
        //---------
        
        
      //  let vendingQuery = try Token.makeQuery()
//        print("<<<<<<<<< \(try vendingQuery.all())")
//        let aaa = try vendingQuery.all()
      /*
        
        let bbb =  try vendingQuery.join(kind: .inner, Token.self, baseKey: "user_id", joinedKey: "user_id")
//        let allvendors = try bbb.all()
        
        let array_DeviceTokens = allvendors.map({ (token: Token) -> String in
            token.deviceToken
        })
        print("array_DeviceTokens: \(array_DeviceTokens)")
        */
        
        /*vaporAPNS.send(pushMessage, to: ["488681b8e30e6722012aeb88f485c823b9be15c42e6cc8db1550a8f1abb590d7", "2d11c1a026a168cee25690f2770993f6068206b1d11d54f88910b8166b23f983"]) { result in
         print(result)
         if case let .success(messageId,deviceToken,serviceStatus) = result, case .success = serviceStatus {
         print ("Success!")
         }
         }*/
        
        
        //----------
    }
    
    /*fileprivate func getBid(from req: Request) throws -> Bid {
        guard let json = req.json else { throw Abort(.badRequest, reason: "Missing JSON") }
        let bidID: String = try json.get(Bid.DB.id.ⓡ)
        guard let bid = try Bid.makeQuery()
            .filter(Bid.DB.id.ⓡ, bidID)
            .first()
            else {
                throw Abort(.badRequest, reason: "Bid: \(bidID) does not exist")
        }
        return bid
    }*/
    
    
}


//VaporAPNS
extension Job {
    
//
//
//    var options = try! Options(topic: Constants.AppBundleIdentifier, teamId: Constants.DeveloperAccount.TeamId, keyId: Constants.DeveloperAccount.APNS_Key_Id, keyPath: "../resources/AuthKey_CNQ574ZKF6.p8")
//    let vaporAPNS = try VaporAPNS(options: options)

    
    
//    let options = try! Options(topic: "<your bundle identifier>", certPath: "/path/to/your/certificate.crt.pem", keyPath: "/path/to/your/certificatekey.key.pem")
//    let vaporAPNS = try VaporAPNS(options: options)
    
}
