import Vapor
import Fluent
import FluentSQLiteDriver
import QueuesRedisDriver
import Redis

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    // register Redis provider
    
    
    app.migrations.add(CreateProfile())
    app.migrations.add(CreateShare())
    app.migrations.add(CreateGlass())
    
    app.logger.logLevel = .debug
    
    app.redis.configuration = try RedisConfiguration(hostname: "3.15.176.154")
    try app.queues.use(.redis(url: "redis://3.15.176.154:6379"))
    
    app.http.server.configuration.hostname = "3.15.176.154"
    app.http.server.configuration.port = 8080
    
    let orderJob = OrderJob()
    app.queues.add(orderJob)

    try app.queues.startScheduledJobs()
    try app.queues.startInProcessJobs()
    
    // register routes
    try routes(app)
    
    app.views.use(.leaf)

    
}
