import Vapor

struct MakeOrderForm: Content {
    var date: String?
    var figi: String
    var highPrice: String
    var lowPrice: String
}
