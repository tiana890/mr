import Vapor
import Leaf
import LeafKit
/*
      {
        "figi": "BBG000BM2FL9",
        "ticker": "ET",
        "isin": "US29273V1008",
        "instrumentType": "Stock",
        "balance": 1,
        "blocked": 0,
        "lots": 1,
        "name": "Energy Transfer LP"
      },
      {
        "figi": "BBG0013HGFT4",
        "ticker": "USD000UTSTOM",
        "instrumentType": "Currency",
        "balance": 900,
        "blocked": 0,
        "lots": 0,
        "name": "Доллар США"
      }
*/

final public class Instrument: Content {
    
    enum InstrumentType: String {
        case stock = "Stock"
        case currency = "Currency"
    }
    
    enum InstrumentKeys: String, CodingKey {
        case figi, ticker, isin, instrumentType, balance, blocked, lots, name
    }
    
    var figi = ""
    var ticker = ""
    var isin = ""
    var lots = 0
    var name = ""
    var balance = 0
    var blocked = 0
    var instrumentType: InstrumentType? = .stock
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: InstrumentKeys.self)

        figi = try container.decode(String.self, forKey: .figi)
        ticker = try container.decode(String.self, forKey: .ticker)
        lots = try container.decode(Int.self, forKey: .lots)
        name = try container.decode(String.self, forKey: .name)
        balance = try container.decode(Int.self, forKey: .balance)
        blocked = try container.decode(Int.self, forKey: .blocked)
        instrumentType = InstrumentType(rawValue: try container.decode(String.self, forKey: .instrumentType))
        if (instrumentType == InstrumentType.stock) {
            isin = try container.decode(String.self, forKey: .isin)
        }
        return

        throw DecodingError.typeMismatch(
            Instrument.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Instrument"))
    }
    
    public func encode(to encoder: Encoder) throws {
        throw EncodingError.invalidValue(Instrument.self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Wrong type for Instrument"))
    }
}

extension Instrument : LeafDataRepresentable {
    public var leafData: LeafData {
        .string("name: \(self.name) balance: \(self.balance) type: \(self.instrumentType?.rawValue)")
    }
}
