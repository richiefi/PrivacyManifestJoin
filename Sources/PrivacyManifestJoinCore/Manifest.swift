struct Manifest: Codable {
    var accessedAPITypes: [APIType]
    var collectedDataTypes: [CollectedDataType]
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
        self.accessedAPITypes = try container.decodeIfPresent([APIType].self, forKey: .accessedAPITypes) ?? []
        self.collectedDataTypes = try container.decodeIfPresent([CollectedDataType].self, forKey: .collectedDataTypes) ?? []
        self.tracking = try container.decodeIfPresent(Bool.self, forKey: .tracking) ?? false
        self.trackingDomains = try container.decodeIfPresent([String].self, forKey: .trackingDomains) ?? []
    }
}

struct CollectedDataType: Codable {
    var dataType: String
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

struct APIType: Codable {
    var apiTypeName: String
    var apiTypeReasons: [String]

    enum CodingKeys: String, CodingKey {
        case apiTypeName = "NSPrivacyAccessedAPIType"
        case apiTypeReasons = "NSPrivacyAccessedAPITypeReasons"
    }
}

protocol Updatable {
    mutating func update(with other: Self)
}

extension Manifest: Updatable {
    mutating func update(with other: Manifest) {
        self.tracking = self.tracking || other.tracking
        self.trackingDomains = Set(self.trackingDomains).union(other.trackingDomains).sorted()

        var currentAPITypesByType = Dictionary(
            self.accessedAPITypes.map { ($0.apiTypeName, $0) },
            uniquingKeysWith: { $1 }
        )
        for otherAPIType in other.accessedAPITypes {
            if var current = currentAPITypesByType[otherAPIType.apiTypeName] {
                current.update(with: otherAPIType)
                currentAPITypesByType[otherAPIType.apiTypeName] = current
            } else {
                currentAPITypesByType[otherAPIType.apiTypeName] = otherAPIType
            }
        }
        self.accessedAPITypes = currentAPITypesByType.values.sorted(by: { $0.apiTypeName < $1.apiTypeName })

        var currentDataTypesByType = Dictionary(
            self.collectedDataTypes.map { ($0.dataType, $0) },
            uniquingKeysWith: { $1 }
        )
        for otherDataType in other.collectedDataTypes {
            if var current = currentDataTypesByType[otherDataType.dataType] {
                current.update(with: otherDataType)
                currentDataTypesByType[otherDataType.dataType] = current
            } else {
                currentDataTypesByType[otherDataType.dataType] = otherDataType
            }
        }
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

extension APIType: Updatable {
    mutating func update(with other: APIType) {
        guard other.apiTypeName == self.apiTypeName else { return }
        self.apiTypeReasons = Set(self.apiTypeReasons).union(other.apiTypeReasons).sorted()
    }
}
