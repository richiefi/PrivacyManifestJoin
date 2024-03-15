struct Manifest: Codable {
    var accessedAPITypes: APITypes
    var collectedDataTypes: CollectedDataTypes
    var tracking: Bool
    var trackingDomains: [String]

    enum CodingKeys: String, CodingKey {
        case accessedAPITypes = "NSPrivacyAccessedAPITypes"
        case collectedDataTypes = "NSPrivacyCollectedDataTypes"
        case tracking = "NSPrivacyTracking"
        case trackingDomains = "NSPrivacyTrackingDomains"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessedAPITypes = try container.decodeIfPresent(
            APITypes.self, forKey: .accessedAPITypes
        ) ?? APITypes(apiTypes: [])
        self.collectedDataTypes = try container.decodeIfPresent(
            CollectedDataTypes.self, forKey: .collectedDataTypes
        ) ?? CollectedDataTypes(dataTypes: [])
        self.tracking = try container.decodeIfPresent(Bool.self, forKey: .tracking) ?? false
        self.trackingDomains = try container.decodeIfPresent([String].self, forKey: .trackingDomains) ?? []
    }
}

struct CollectedDataTypes: Codable {
    var dataTypes: [CollectedDataType]

    init(dataTypes: [CollectedDataType]) {
        self.dataTypes = dataTypes
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.dataTypes = try container.decode([CollectedDataType].self)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.dataTypes)
    }
}

struct PrivacyDataType: Codable, Hashable {
    var rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

extension PrivacyDataType: Comparable {
    static func < (lhs: PrivacyDataType, rhs: PrivacyDataType) -> Bool { lhs.rawValue < rhs.rawValue }
}

struct CollectedDataType: Codable {
    var dataType: PrivacyDataType
    var linked: Bool
    var purposes: [String]
    var tracking: Bool

    enum CodingKeys: String, CodingKey {
        case dataType = "NSPrivacyCollectedDataType"
        case linked = "NSPrivacyCollectedDataTypeLinked"
        case purposes = "NSPrivacyCollectedDataTypePurposes"
        case tracking = "NSPrivacyCollectedDataTypeTracking"
    }
}

struct APITypes: Codable {
    var apiTypes: [APIType]

    init(apiTypes: [APIType]) {
        self.apiTypes = apiTypes
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.apiTypes = try container.decode([APIType].self)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.apiTypes)
    }
}

struct APIName: Codable, Hashable {
    var rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

extension APIName: Comparable {
    static func < (lhs: APIName, rhs: APIName) -> Bool { lhs.rawValue < rhs.rawValue }
}

struct APIReason: Codable, Hashable {
    var rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

extension APIReason: Comparable {
    static func < (lhs: APIReason, rhs: APIReason) -> Bool { lhs.rawValue < rhs.rawValue }
}

struct APIType: Codable {
    var apiTypeName: APIName
    var apiTypeReasons: [APIReason]

    enum CodingKeys: String, CodingKey {
        case apiTypeName = "NSPrivacyAccessedAPIType"
        case apiTypeReasons = "NSPrivacyAccessedAPITypeReasons"
    }
}

// MARK: -

protocol Updatable {
    mutating func update(with other: Self)
}

extension Manifest: Updatable {
    mutating func update(with other: Manifest) {
        self.tracking = self.tracking || other.tracking
        self.trackingDomains = Set(self.trackingDomains).union(other.trackingDomains).sorted()
        self.accessedAPITypes.update(with: other.accessedAPITypes)
        self.collectedDataTypes.update(with: other.collectedDataTypes)
    }
}

extension CollectedDataTypes: Updatable {
    mutating func update(with other: CollectedDataTypes) {
        var currentDataTypesByType = Dictionary(
            self.dataTypes.map { ($0.dataType, $0) },
            uniquingKeysWith: { $1 }
        )
        for otherDataType in other.dataTypes {
            if var current = currentDataTypesByType[otherDataType.dataType] {
                current.update(with: otherDataType)
                currentDataTypesByType[otherDataType.dataType] = current
            } else {
                currentDataTypesByType[otherDataType.dataType] = otherDataType
            }
        }
        self.dataTypes = currentDataTypesByType.values.sorted(by: { $0.dataType < $1.dataType })
    }
}

extension CollectedDataType: Updatable {
    mutating func update(with other: CollectedDataType) {
        guard other.dataType == self.dataType else { return }
        self.linked = self.linked || other.linked
        self.tracking = self.tracking || other.tracking
        self.purposes = Set(self.purposes).union(other.purposes).sorted()
    }
}

extension APITypes: Updatable {
    mutating func update(with other: APITypes) {
        var currentAPITypesByType = Dictionary(
            self.apiTypes.map { ($0.apiTypeName, $0) },
            uniquingKeysWith: { $1 }
        )
        for otherAPIType in other.apiTypes {
            if var current = currentAPITypesByType[otherAPIType.apiTypeName] {
                current.update(with: otherAPIType)
                currentAPITypesByType[otherAPIType.apiTypeName] = current
            } else {
                currentAPITypesByType[otherAPIType.apiTypeName] = otherAPIType
            }
        }
        self.apiTypes = currentAPITypesByType.values.sorted(by: { $0.apiTypeName < $1.apiTypeName })
    }
}

extension APIType: Updatable {
    mutating func update(with other: APIType) {
        guard other.apiTypeName == self.apiTypeName else { return }
        self.apiTypeReasons = Set(self.apiTypeReasons).union(other.apiTypeReasons).sorted()
    }
}
