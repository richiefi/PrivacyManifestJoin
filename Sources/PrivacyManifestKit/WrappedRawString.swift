public protocol WrappedRawString: Codable, Hashable, Comparable, RawRepresentable, ExpressibleByStringLiteral {
    var rawValue: String { get set }

    init(rawValue: String)
}

extension WrappedRawString {
    public static func == (left: Self, right: Self) -> Bool { left.rawValue == right.rawValue }
    public static func < (left: Self, right: Self) -> Bool { left.rawValue < right.rawValue }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(rawValue: try container.decode(String.self))
    }

    public init(stringLiteral value: String) {
        self.init(rawValue: String(stringLiteral: value))
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }

    public func hash(into hasher: inout Hasher) {
        self.rawValue.hash(into: &hasher)
    }
}
