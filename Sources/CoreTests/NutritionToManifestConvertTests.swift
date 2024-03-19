import CustomDump
import PrivacyManifestKit
import XCTest

final class NutritionToManifestConvertTests: XCTestCase {
    func test() throws {
        let nutrition = """
        [
          {
            "category": "ADVERTISING_DATA",
            "purposes": [
              "ANALYTICS",
              "DEVELOPERS_ADVERTISING"
            ],
            "data_protections": [
              "DATA_NOT_LINKED_TO_YOU"
            ]
          },
          {
            "category": "CRASH_DATA",
            "purposes": [
              "APP_FUNCTIONALITY"
            ],
            "data_protections": [
              "DATA_NOT_LINKED_TO_YOU"
            ]
          },
          {
            "category": "DEVICE_ID",
            "purposes": [
              "APP_FUNCTIONALITY",
              "THIRD_PARTY_ADVERTISING"
            ],
            "data_protections": [
              "DATA_NOT_LINKED_TO_YOU",
              "DATA_USED_TO_TRACK_YOU"
            ]
          },
          {
            "category": "EMAIL_ADDRESS",
            "purposes": [
              "APP_FUNCTIONALITY"
            ],
            "data_protections": [
              "DATA_LINKED_TO_YOU"
            ]
          },
          {
            "category": "OTHER_DIAGNOSTIC_DATA",
            "purposes": [
              "APP_FUNCTIONALITY"
            ],
            "data_protections": [
              "DATA_NOT_LINKED_TO_YOU"
            ]
          },
          {
            "category": "PRODUCT_INTERACTION",
            "purposes": [
              "ANALYTICS"
            ],
            "data_protections": [
              "DATA_NOT_LINKED_TO_YOU"
            ]
          },
          {
            "category": "USER_ID",
            "purposes": [
              "ANALYTICS",
              "APP_FUNCTIONALITY"
            ],
            "data_protections": [
              "DATA_LINKED_TO_YOU"
            ]
          }
        ]
        """
        let manifest = try ManifestConvert.nutritionPrivacyDetailsToManifest(data: Data(nutrition.utf8))
        XCTAssertNoDifference(
            manifest,
            Manifest(
                accessedAPITypes: .empty,
                collectedDataTypes: CollectedDataTypes(
                    dataTypes: [
                        .init(
                            dataType: .advertisingData,
                            linked: false,
                            purposes: [.analytics, .developerAdvertising],
                            tracking: false
                        ),
                        .init(
                            dataType: .crashData,
                            linked: false,
                            purposes: [.appFunctionality],
                            tracking: false
                        ),
                        .init(
                            dataType: .deviceID,
                            linked: false,
                            purposes: [.appFunctionality, .thirdPartyAdvertising],
                            tracking: true
                        ),
                        .init(
                            dataType: .emailAddress,
                            linked: true,
                            purposes: [.appFunctionality],
                            tracking: false
                        ),
                        .init(
                            dataType: .otherDiagnosticData,
                            linked: false,
                            purposes: [.appFunctionality],
                            tracking: false
                        ),
                        .init(
                            dataType: .productInteraction,
                            linked: false,
                            purposes: [.analytics],
                            tracking: false
                        ),
                        .init(
                            dataType: .userID,
                            linked: true,
                            purposes: [.analytics, .appFunctionality],
                            tracking: false
                        ),
                    ]
                ),
                tracking: false,
                trackingDomains: []
            )
        )
    }
}
