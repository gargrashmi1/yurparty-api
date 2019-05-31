//
//  Order.swift
//  App
//
//  Created by MAC001 on 05/04/19.
//
import Foundation
import AuthProvider
import FluentProvider

final class Notification: Model, Timestampable {
    static let idType: IdentifierType = .uuid
    static let idKey = DB.id.ⓡ
    static var foreignIdKey = DB.id.ⓡ
    let storage = Storage()
    var log: LogProtocol?
    
    var status: String
    var title: String
    var description: String
    var jobId: Identifier
    var fromUserId: Identifier
    var to: String
    var type: String
    
    
    public enum DB: String {
        case id = "notification_id"
        case jobIdKey = "job_id"
        case title = "title"
        case description = "description"
        case status = "status"
        case fromUserId = "from_user_id"
        case to = "to"
        case type = "type"
    }
    
    init(id: String? = nil, jobId: Identifier, title: String, desc: String, status: String, fromUserId: Identifier, to: String, type: String/*,
         user: User*/) throws {
        
        self.jobId = jobId
        self.title = title
        self.description = desc
        self.status = status
        self.fromUserId = fromUserId
        self.to = to
        self.type = type
        
       /* guard let userId = user.id else { throw Abort(.badRequest, reason: "User id not found in vending init") }
        self.userId = userId*/
        if let id = id { self.id = Identifier(id) }
    }
    
    init(row: Row) throws {
        
        
        jobId = try row.get(DB.jobIdKey.ⓡ)
        title = try row.get(DB.title.ⓡ)
        description = try row.get(DB.description.ⓡ)
        status = try row.get(DB.status.ⓡ)
        fromUserId =   try row.get(DB.fromUserId.ⓡ)
        to = try row.get(DB.to.ⓡ)
        type = try row.get(DB.type.ⓡ)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(DB.jobIdKey.ⓡ, jobId)
        try row.set(DB.title.ⓡ, title)
        try row.set(DB.description.ⓡ, description)
        try row.set(DB.status.ⓡ, status)
        try row.set(DB.fromUserId.ⓡ, fromUserId)
        try row.set(DB.type.ⓡ, type)
        return row
    }
}

//extension Order {
//    var owner: Parent<Order, Event> {
//        return parent(id: eventId)
//    }
//}



/*extension Order {
    var owner: Parent<Order, User> {
        return parent(id: userId)
    }
}
*/

//extension Notification {
//    var owner: Parent<Notification, Job> {
//        return parent(id: jobId)
//    }
//}


extension Notification: ResponseRepresentable { }
//extension Vending: JSONRepresentable {}

extension Notification: Preparation {
    static func prepare(_ database: Database) throws {
      
    }
    
    // "there’s no need to manually create indexes on unique columns; doing so
    // would just duplicate the automatically-created index."
    // https://www.postgresql.org/docs/9.4/static/ddl-constraints.html
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


extension Notification: JSONConvertible {
    
    convenience init(json: JSON) throws {
        
        let id: String?
        var status : String?
        let title: String?
        let description: String?
        let to: String?
        let type: String?
        
        print("Notification json=\(json)")
        do { id = try json.get(DB.id.ⓡ) } catch { id = nil }

        guard let aFromUserId: String = try json.get(DB.fromUserId.ⓡ) else {
            throw Abort(.badRequest, reason: "fromuserid not found for notification")
        }
        
        guard let aJobId: String = try json.get(DB.jobIdKey.ⓡ) else {
            throw Abort(.badRequest, reason: "jobid not found for notification")
        }
        
        do { status = try json.get(DB.status.ⓡ) } catch { status = nil }
        do { title = try json.get(DB.title.ⓡ) } catch { title = nil }
        do { description = try json.get(DB.description.ⓡ) } catch { description = nil }
        do { status = try json.get(DB.status.ⓡ) } catch { status = nil }
        do { to = try json.get(DB.to.ⓡ) } catch { to = nil }
        do { type = try json.get(DB.type.ⓡ) } catch { type = nil }
        
        try self.init(
            id: id,
            jobId: Identifier(aJobId),
            title: title ?? "",
            desc: description ?? "",
            status: status ?? "",
            fromUserId: Identifier(aFromUserId),
            to: to ?? "",
            type: type ?? ""//,
//            user: auser
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(DB.id.ⓡ, id)
        
        
        try json.set(DB.jobIdKey.ⓡ, jobId)
        try json.set(DB.title.ⓡ, title)
        try json.set(DB.description.ⓡ, description)
        try json.set(DB.status.ⓡ, status)
        try json.set(DB.status.ⓡ, status)
        try json.set(DB.to.ⓡ, to)
         try json.set(DB.type.ⓡ, type)
        print("json sent is", json)
        return json
    }
}

extension Notification: TokenAuthenticatable {
    typealias TokenType = Token
}

