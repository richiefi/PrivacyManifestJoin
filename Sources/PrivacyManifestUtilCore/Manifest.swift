/// Top-level type representing a complete privacy manifest.
public struct Manifest: Codable, Equatable {
    /// Accessed API types.
    /// `NSPrivacyAccessedAPITypes` in the manifest file.
    public var accessedAPITypes: APITypes
    /// Collected data types.
    /// `NSPrivacyCollectedDataTypes` in the manifest file.
    public var collectedDataTypes: CollectedDataTypes
    /// Indicates whether the package uses data for tracking.
    /// `NSPrivacyTracking` in the manifest file.
    public var tracking: Bool
    /// Lists the internet domains the package connects to that engage in tracking.
    /// `NSPrivacyTrackingDomains` in the manifest file.
    public var trackingDomains: [String]

    enum CodingKeys: String, CodingKey {
        case accessedAPITypes = "NSPrivacyAccessedAPITypes"
        case collectedDataTypes = "NSPrivacyCollectedDataTypes"
        case tracking = "NSPrivacyTracking"
        case trackingDomains = "NSPrivacyTrackingDomains"
    }

    public init(
        accessedAPITypes: APITypes,
        collectedDataTypes: CollectedDataTypes,
        tracking: Bool,
        trackingDomains: [String]
    ) {
        self.accessedAPITypes = accessedAPITypes
        self.collectedDataTypes = collectedDataTypes
        self.tracking = tracking
        self.trackingDomains = trackingDomains
    }

    public init(from decoder: any Decoder) throws {
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

/// Describes the data types the package collects.
public struct CollectedDataTypes: Codable, Equatable {
    public var dataTypes: [CollectedDataType]

    public init(dataTypes: [CollectedDataType]) {
        self.dataTypes = dataTypes
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.dataTypes = try container.decode([CollectedDataType].self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.dataTypes)
    }

    public static let empty = CollectedDataTypes(dataTypes: [])
}

/// Name of a collected data type.
public struct PrivacyDataType: WrappedRawString {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Name of a collection purpose.
public struct CollectionPurpose: WrappedRawString {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Describes a single data types the package collects.
public struct CollectedDataType: Codable, Equatable {
    /// The collected data type. `NSPrivacyCollectedDataType` in the manifest file.
    public var dataType: PrivacyDataType
    /// Indicates whether the package links this data type to the user’s identity.
    /// `NSPrivacyCollectedDataTypeLinked` in the manifest file.
    public var linked: Bool
    /// Lists the reasons the package collects the data.
    /// `NSPrivacyCollectedDataTypePurposes` in the manifest file.
    public var purposes: [CollectionPurpose]
    /// Indicates whether the package uses this data type to track.
    /// `NSPrivacyCollectedDataTypeTracking` in the manifest file.
    public var tracking: Bool

    enum CodingKeys: String, CodingKey {
        case dataType = "NSPrivacyCollectedDataType"
        case linked = "NSPrivacyCollectedDataTypeLinked"
        case purposes = "NSPrivacyCollectedDataTypePurposes"
        case tracking = "NSPrivacyCollectedDataTypeTracking"
    }

    public init(
        dataType: PrivacyDataType,
        linked: Bool,
        purposes: [CollectionPurpose],
        tracking: Bool
    ) {
        self.dataType = dataType
        self.linked = linked
        self.purposes = purposes
        self.tracking = tracking
    }
}

/// Describes the API types the package uses.
public struct APITypes: Codable, Equatable {
    var apiTypes: [APIType]

    public init(apiTypes: [APIType]) {
        self.apiTypes = apiTypes
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.apiTypes = try container.decode([APIType].self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.apiTypes)
    }

    public static let empty = APITypes(apiTypes: [])
}

/// Name of an API the package uses.
public struct APIName: WrappedRawString {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Name of a reason for API usage.
public struct APIReason: WrappedRawString {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// A single API being used and the reasons for the usage.
public struct APIType: Codable, Equatable {
    public var apiTypeName: APIName
    public var apiTypeReasons: [APIReason]

    enum CodingKeys: String, CodingKey {
        case apiTypeName = "NSPrivacyAccessedAPIType"
        case apiTypeReasons = "NSPrivacyAccessedAPITypeReasons"
    }

    public init(apiTypeName: APIName, apiTypeReasons: [APIReason]) {
        self.apiTypeName = apiTypeName
        self.apiTypeReasons = apiTypeReasons
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
