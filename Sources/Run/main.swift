import App

import Vapor
import PostgreSQLProvider
import AuthProvider
import VaporS3Signer
import VaporAPNS

/// We have isolated all of our App's logic into
/// the App module because it makes our app
/// more testable.
///
/// In general, the executable portion of our App
/// shouldn't include much more code than is presented
/// here.
///
/// We simply initialize our Droplet, optionally
/// passing in values if necessary
/// Then, we pass it to our App's setup function
/// this should setup all the routes and special
/// features of our app
///
/// .run() runs the Droplet's commands,
/// if no command is given, it will default to "serve"


setenv("DATABASE_URL", "postgres://hygziviienbche:90c60426363db158e435caf81ef5748070a8654874cd18150b1b4f9aeca4c7b2@ec2-107-21-233-72.compute-1.amazonaws.com/d8sug7gqkae4om", 1)

setenv("SENDBIRD_TOKEN", "582dd7133f22f3f548566b666295ac9b72c1b069", 1)


setenv("TWILIO_FROM", "+12133220623", 1)
setenv("TWILIO_SID", "AC40e82047b23537e9deeda88386a29185", 1)
setenv("TWILIO_TOKEN", "926aa405e467d695138f670f5e278ee9", 1)


//old working
//setenv("TWILIO_FROM", "+12133220623", 1)
//setenv("TWILIO_SID", "AC40e82047b23537e9deeda88386a29185", 1)
//setenv("TWILIO_TOKEN", "ed9278dafdd7bbfa963b3071351260c2", 1)



let config = try Config()
try config.setup()
let drop = try Droplet(config)
try drop.setup()

drop.get { req in
    return try drop.view.make("Welcome",[
        "message": "Welcome"])
}
try drop.run()

/*
 var options = try! Options(topic: "<your topic>", teamId: "<your teamId>", keyId: "<your keyId>", keyPath: "<your path to key>")
 options.forceCurlInstall = true
 
 */


