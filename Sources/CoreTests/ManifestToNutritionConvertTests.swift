import CustomDump
import PrivacyManifestUtilCore
import XCTest

final class ManifestToNutritionConvertTests: XCTestCase {
    func test() throws {
        let manifest = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>NSPrivacyCollectedDataTypes</key>
            <array>
                <dict>
                    <key>NSPrivacyCollectedDataType</key>
                    <string>NSPrivacyCollectedDataTypeUserID</string>
                    <key>NSPrivacyCollectedDataTypeLinked</key>
                    <true/>
                    <key>NSPrivacyCollectedDataTypeTracking</key>
                    <false/>
                    <key>NSPrivacyCollectedDataTypePurposes</key>
                    <array>
                        <string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
                    </array>
                </dict>
                <dict>
                    <key>NSPrivacyCollectedDataType</key>
                    <string>NSPrivacyCollectedDataTypeProductInteraction</string>
                    <key>NSPrivacyCollectedDataTypeLinked</key>
                    <true/>
                    <key>NSPrivacyCollectedDataTypeTracking</key>
                    <false/>
                    <key>NSPrivacyCollectedDataTypePurposes</key>
                    <array>
                        <string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
                        <string>NSPrivacyCollectedDataTypePurposeProductPersonalization</string>
                    </array>
                </dict>
                <dict>
                    <key>NSPrivacyCollectedDataType</key>
                    <string>NSPrivacyCollectedDataTypeOtherDataTypes</string>
                    <key>NSPrivacyCollectedDataTypeLinked</key>
                    <false/>
                    <key>NSPrivacyCollectedDataTypeTracking</key>
                    <true/>
                    <key>NSPrivacyCollectedDataTypePurposes</key>
                    <array>
                        <string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
                    </array>
                </dict>
                <dict>
                    <key>NSPrivacyCollectedDataType</key>
                    <string>NSPrivacyCollectedDataTypeCoarseLocation</string>
                    <key>NSPrivacyCollectedDataTypeLinked</key>
                    <true/>
                    <key>NSPrivacyCollectedDataTypeTracking</key>
                    <false/>
                    <key>NSPrivacyCollectedDataTypePurposes</key>
                    <array>
                        <string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
                    </array>
                </dict>
            </array>
            <key>NSPrivacyAccessedAPITypes</key>
            <array>
                <dict>
                    <key>NSPrivacyAccessedAPIType</key>
                    <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
                    <key>NSPrivacyAccessedAPITypeReasons</key>
                    <array>
                        <string>CA92.1</string>
                    </array>
                </dict>
            </array>
            <key>NSPrivacyTrackingDomains</key>
            <array/>
            <key>NSPrivacyTracking</key>
            <false/>
        </dict>
        </plist>
        """
        let nutrition = try ManifestConvert.manifestToNutritionPrivacyDetails(data: Data(manifest.utf8))
        XCTAssertNoDifference(
            nutrition,
            NutritionPrivacyDetails(details: [
                NutritionPrivacyDetail(
                    category: .userID,
                    purposes: [.analytics],
                    protections: NutritionDataProtections(linked: true, tracked: false)
                ),
                NutritionPrivacyDetail(
                    category: .productInteraction,
                    purposes: [.analytics, .productPersonalization],
                    protections: NutritionDataProtections(linked: true, tracked: false)
                ),
                NutritionPrivacyDetail(
                    category: .otherData,
                    purposes: [.analytics],
                    protections: NutritionDataProtections(linked: false, tracked: true)
                ),
                NutritionPrivacyDetail(
                    category: .coarseLocation,
                    purposes: [.analytics],
                    protections: NutritionDataProtections(linked: true, tracked: false)
                ),
            ])
        )
    }
}
