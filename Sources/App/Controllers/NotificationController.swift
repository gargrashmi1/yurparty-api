//
//  HireNow.swift
//  App
//
//  Created by MAC001 on 05/04/19.
//

import Foundation
final class NotificationController: Controlling {
    fileprivate let log: LogProtocol
    
    init(log: LogProtocol) throws {
        self.log = log
    }
    
    func addOpenRoutes(drop: Droplet) {
        drop.get("notifications") { req in return try self.get(req) }
    }
    
    
    
    func addGroupedRoutes(group: RouteBuilder) {
        group.post("notifications") { req in return try self.post(req) }
        group.patch("notifications") { req in return try self.patch(req) }
        group.delete("notifications") { req in return try self.delete(req) }
        
        group.get("notifications/lookup", String.parameter) { req in
            print("============\n\(req)")
            let lookupid = try req.parameters.next(String.self)
            guard let notif = try Notification.makeQuery()
                .filter(Notification.DB.id.ⓡ, lookupid)
                .first()
                else {
                    throw Abort(.badRequest, reason: "Notification: \(lookupid) does not exist")
            }
            return notif
        }
    }
    fileprivate func get(_ req: Request) throws -> JSON {
        
        let NotificationQuery = try Notification.makeQuery()
        
        var json = JSON()
        try json.set("status", "ok")
        
        try json.set("notifications", NotificationQuery.all())
        return json
    }
    
    /*
     fileprivate func get(_ req: Request) throws -> JSON {
     guard let offer = req.data["offer"]?.string else {
     throw Abort(.badRequest, reason: "VFAIL: Bad Parameters")
     }
     let eventQuery = try Event.makeQuery()
     switch offer.lowercased() {
     case "food": try vendingQuery.filter(Vending.DB.offersFood.ⓡ, true)
     case "entertainment": try vendingQuery.filter(Vending.DB.offersEntertainment.ⓡ, true)
     case "music": try vendingQuery.filter(Vending.DB.offersMusic.ⓡ, true)
     case "rentals": try vendingQuery.filter(Vending.DB.offersRentals.ⓡ, true)
     case "services": try vendingQuery.filter(Vending.DB.offersServices.ⓡ, true)
     case "partypacks": try vendingQuery.filter(Vending.DB.offersPartyPacks.ⓡ, true)
     case "venue": try vendingQuery.filter(Vending.DB.offersVenue.ⓡ, true)
     case "all": try vendingQuery
     default:
     throw Abort(.badRequest, reason: "VFAIL: Bad Parameter")
     }
     var json = JSON()
     try json.set("status", "ok")
     try json.set("offer", "\(offer)")
     try json.set("vendings", vendingQuery.all())
     return json
     }
     */
    fileprivate func post(_ req: Request) throws -> JSON {
        //log.error("• in vendings.post()\n\(req)")
        guard let json = req.json else { throw Abort(.badRequest, reason: "No JSON in notification post") }
        
        var notificationTry: Notification?
        do {
            notificationTry = try Notification(json: json)
        } catch let error as Debuggable {
            notificationTry = nil
            throw Abort(.badRequest, reason: error.reason, identifier: error.identifier)
        }
        guard let notification = notificationTry else {
            throw Abort(.badRequest, reason: "Could not construct notification")
        }
        
        do {
            try notification.save()
        } catch let error as Debuggable {
            throw Abort(.badRequest, reason: error.reason, identifier: error.identifier)
        }
        var notificationJSON = JSON()
        try notificationJSON.set("status", "ok")
        try notificationJSON.set("notification", notification)
        return notificationJSON
    }
    
    fileprivate func getNotification(from req: Request) throws -> Notification {
        guard let json = req.json else { throw Abort(.badRequest, reason: "Missing JSON") }
        let notificationID: String = try json.get(Notification.DB.id.ⓡ)
        guard let notification = try Notification.makeQuery()
            .filter(Notification.DB.id.ⓡ, notificationID)
            .first()
            else {
                throw Abort(.badRequest, reason: "Notification: \(notificationID) does not exist")
        }
        return notification
    }
    
    // PATCH one
    fileprivate func patch(_ req: Request) throws -> JSON {
        // See `extension Event: Updateable`
        let notification = try getNotification(from: req)
        /*try notification.update(for: req)*/
        try notification.save()
        
        var notificationJSON = JSON()
        try notificationJSON.set("status", "ok")
        try notificationJSON.set("notification", notification)
        return notificationJSON
    }
    
    // DELETE one
    fileprivate func delete(_ req: Request) throws -> JSON {
        let notification = try getNotification(from: req)
        try notification.delete()
        var okJSON = JSON()
        try okJSON.set("status", "ok")
        return okJSON
    }
}
