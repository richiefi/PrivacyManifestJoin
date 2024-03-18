public struct NutritionCategory: WrappedRawString {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let advertisingData = NutritionCategory(rawValue: "ADVERTISING_DATA")
    public static let audio = NutritionCategory(rawValue: "AUDIO")
    public static let browsingHistory = NutritionCategory(rawValue: "BROWSING_HISTORY")
    public static let coarseLocation = NutritionCategory(rawValue: "COARSE_LOCATION")
    public static let contacts = NutritionCategory(rawValue: "CONTACTS")
    public static let crashData = NutritionCategory(rawValue: "CRASH_DATA")
    public static let creditAndFraud = NutritionCategory(rawValue: "CREDIT_AND_FRAUD")
    public static let customerSupport = NutritionCategory(rawValue: "CUSTOMER_SUPPORT")
    public static let deviceID = NutritionCategory(rawValue: "DEVICE_ID")
    public static let emailAddress = NutritionCategory(rawValue: "EMAIL_ADDRESS")
    public static let emailsOrTextMessages = NutritionCategory(rawValue: "EMAILS_OR_TEXT_MESSAGES")
    public static let fitness = NutritionCategory(rawValue: "FITNESS")
    public static let gameplayContent = NutritionCategory(rawValue: "GAMEPLAY_CONTENT")
    public static let health = NutritionCategory(rawValue: "HEALTH")
    public static let name = NutritionCategory(rawValue: "NAME")
    public static let otherContactInfo = NutritionCategory(rawValue: "OTHER_CONTACT_INFO")
    public static let otherData = NutritionCategory(rawValue: "OTHER_DATA")
    public static let otherDiagnosticData = NutritionCategory(rawValue: "OTHER_DIAGNOSTIC_DATA")
    public static let otherFinancialInfo = NutritionCategory(rawValue: "OTHER_FINANCIAL_INFO")
    public static let otherUsageData = NutritionCategory(rawValue: "OTHER_USAGE_DATA")
    public static let otherUserContent = NutritionCategory(rawValue: "OTHER_USER_CONTENT")
    public static let paymentInformation = NutritionCategory(rawValue: "PAYMENT_INFORMATION")
    public static let performanceData = NutritionCategory(rawValue: "PERFORMANCE_DATA")
    public static let phoneNumber = NutritionCategory(rawValue: "PHONE_NUMBER")
    public static let photosOrVideos = NutritionCategory(rawValue: "PHOTOS_OR_VIDEOS")
    public static let physicalAddress = NutritionCategory(rawValue: "PHYSICAL_ADDRESS")
    public static let preciseLocation = NutritionCategory(rawValue: "PRECISE_LOCATION")
    public static let productInteraction = NutritionCategory(rawValue: "PRODUCT_INTERACTION")
    public static let purchaseHistory = NutritionCategory(rawValue: "PURCHASE_HISTORY")
    public static let searchHistory = NutritionCategory(rawValue: "SEARCH_HISTORY")
    public static let sensitiveInfo = NutritionCategory(rawValue: "SENSITIVE_INFO")
    public static let userID = NutritionCategory(rawValue: "USER_ID")
}

public struct NutritionPurpose: WrappedRawString {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let thirdPartyAdvertising = NutritionPurpose(rawValue: "THIRD_PARTY_ADVERTISING")
    public static let developersAdvertising = NutritionPurpose(rawValue: "DEVELOPERS_ADVERTISING")
    public static let analytics = NutritionPurpose(rawValue: "ANALYTICS")
    public static let productPersonalization = NutritionPurpose(rawValue: "PRODUCT_PERSONALIZATION")
    public static let appFunctionality = NutritionPurpose(rawValue: "APP_FUNCTIONALITY")
    public static let otherPurposes = NutritionPurpose(rawValue: "OTHER_PURPOSES")
}

public struct NutritionDataProtections: Codable, Equatable {
    public var linked: Bool
    public var tracked: Bool

    public init(linked: Bool, tracked: Bool) {
        self.linked = linked
        self.tracked = tracked
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values: Set<String> = try container.decode(Set<String>.self)

        if values.contains("DATA_LINKED_TO_YOU") {
            self.linked = true
        } else if values.contains("DATA_NOT_LINKED_TO_YOU") {
            self.linked = false
        } else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "Expected either DATA_LINKED_TO_YOU or DATA_NOT_LINKED_TO_YOU"
            ))
        }
        self.tracked = values.contains("DATA_USED_TO_TRACK_YOU")
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        var strings: [String] = [self.linked ? "DATA_LINKED_TO_YOU" : "DATA_NOT_LINKED_TO_YOU"]
        if self.tracked {
            strings.append("DATA_USED_TO_TRACK_YOU")
        }

        try container.encode(strings)
    }
}

public struct NutritionPrivacyDetail: Equatable, Codable {
    public var category: NutritionCategory
    public var purposes: [NutritionPurpose]
    public var protections: NutritionDataProtections

    public init(category: NutritionCategory, purposes: [NutritionPurpose], protections: NutritionDataProtections) {
        self.category = category
        self.purposes = purposes
        self.protections = protections
    }

    enum CodingKeys: String, CodingKey {
        case category
        case purposes
        case protections = "data_protections"
    }
}

public struct NutritionPrivacyDetails: Equatable, Codable {
    public var details: [NutritionPrivacyDetail]

    public init(details: [NutritionPrivacyDetail]) {
        self.details = details
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.details = try container.decode([NutritionPrivacyDetail].self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.details)
    }
}

extension NutritionPrivacyDetails {
    public init(manifest: Manifest) throws {
        self.init(
            details: try manifest.collectedDataTypes.dataTypes.map {
                try NutritionPrivacyDetail(collectedDataType: $0)
            }
        )
    }

    func toManifest() throws -> Manifest {
        Manifest(
            accessedAPITypes: .empty,
            collectedDataTypes: CollectedDataTypes(dataTypes: try self.details.map { try $0.toCollectedDataType() }),
            tracking: false,
            trackingDomains: []
        )
    }
}

public enum ConversionFailure: Error {
    case unknownCollectionPurpose(CollectionPurpose)
    case unknownNutritionCategory(NutritionCategory)
    case unknownNutritionPurpose(NutritionPurpose)
    case unknownPrivacyDataType(PrivacyDataType)
}

extension NutritionPrivacyDetail {
    public init(collectedDataType: CollectedDataType) throws {
        guard let category = NutritionMapping.privacyDataTypeToNutritionCategory[collectedDataType.dataType] else {
            throw ConversionFailure.unknownPrivacyDataType(collectedDataType.dataType)
        }
        let purposes = try collectedDataType.purposes.map {
            guard let np = NutritionMapping.collectionPurposeToNutritionPurpose[$0] else {
                throw ConversionFailure.unknownCollectionPurpose($0)
            }
            return np
        }
        let protections = NutritionDataProtections(
            linked: collectedDataType.linked,
            tracked: collectedDataType.tracking
        )
        self.init(category: category, purposes: purposes, protections: protections)
    }

    public func toCollectedDataType() throws -> CollectedDataType {
        guard let dataType = NutritionMapping.nutritionCategoryToPrivacyDataType[self.category] else {
            throw ConversionFailure.unknownNutritionCategory(self.category)
        }
        let purposes = try self.purposes.map {
            guard let cp = NutritionMapping.nutritionPurposeToCollectionPurpose[$0] else {
                throw ConversionFailure.unknownNutritionPurpose($0)
            }
            return cp
        }
        return CollectedDataType(
            dataType: dataType,
            linked: self.protections.linked,
            purposes: purposes,
            tracking: self.protections.tracked
        )
    }
}

public enum NutritionMapping {
    public static let privacyDataTypeToNutritionCategory: [PrivacyDataType: NutritionCategory] = [
        .advertisingData: .advertisingData,
        .audioData: .audio,
        .browsingHistory: .browsingHistory,
        .coarseLocation: .coarseLocation,
        .contacts: .contacts,
        .crashData: .crashData,
        .creditInfo: .creditAndFraud,
        .customerSupport: .customerSupport,
        .deviceID: .deviceID,
        .emailAddress: .emailAddress,
        .emailsOrTextMessages: .emailsOrTextMessages,
        //    .environmentScanning:
        .fitness: .fitness,
        .gameplayContent: .gameplayContent,
        //    .hands:
        //    .head:
        .health: .health,
        .name: .name,
        .otherDataTypes: .otherData,
        .otherDiagnosticData: .otherDiagnosticData,
        .otherFinancialInfo: .otherFinancialInfo,
        .otherUsageData: .otherUsageData,
        .otherUserContactInfo: .otherContactInfo,
        .otherUserContent: .otherUserContent,
        .paymentInfo: .paymentInformation,
        .performanceData: .performanceData,
        .phoneNumber: .phoneNumber,
        .photosorVideos: .photosOrVideos,
        .physicalAddress: .physicalAddress,
        .preciseLocation: .preciseLocation,
        .productInteraction: .productInteraction,
        .purchaseHistory: .purchaseHistory,
        .searchHistory: .searchHistory,
        .sensitiveInfo: .sensitiveInfo,
        .userID: .userID,
    ]

    public static let nutritionCategoryToPrivacyDataType: [NutritionCategory: PrivacyDataType] = {
        Dictionary(Self.privacyDataTypeToNutritionCategory.map { ($1, $0) }, uniquingKeysWith: { $1 })
    }()

    public static let collectionPurposeToNutritionPurpose: [CollectionPurpose: NutritionPurpose] = [
        .thirdPartyAdvertising: .thirdPartyAdvertising,
        .developerAdvertising: .developersAdvertising,
        .analytics: .analytics,
        .productPersonalization: .productPersonalization,
        .appFunctionality: .appFunctionality,
        .other: .otherPurposes,
    ]

    public static let nutritionPurposeToCollectionPurpose: [NutritionPurpose: CollectionPurpose] = {
        Dictionary(Self.collectionPurposeToNutritionPurpose.map { ($1, $0) }, uniquingKeysWith: { $1 })
    }()
}
