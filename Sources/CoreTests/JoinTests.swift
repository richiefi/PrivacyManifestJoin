import CustomDump
import PrivacyManifestUtilCore
import XCTest

final class JoinTests: XCTestCase {
    func testSingle() throws {
        let manifest = Manifest(
            accessedAPITypes: .init(apiTypes: [
                .init(apiTypeName: "api1", apiTypeReasons: ["reason1", "reason2"]),
            ]),
            collectedDataTypes: .init(dataTypes: [
                .init(dataType: "datatype1", linked: true, purposes: ["purpose1", "purpose2"], tracking: false),
            ]),
            tracking: true,
            trackingDomains: ["domain1", "domain2"]
        )
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let manifestData = try encoder.encode(manifest)
        let joined = try ManifestJoin.joinSources(sources: [{ manifestData }])
        XCTAssertNoDifference(manifest, joined)
    }

    func testTrackingIsTrueIfTrueInFirst() throws {
        let manifest1 = Manifest(
            accessedAPITypes: .init(apiTypes: [
                .init(apiTypeName: "api1", apiTypeReasons: ["reason1", "reason2"]),
            ]),
            collectedDataTypes: .init(dataTypes: [
                .init(dataType: "datatype1", linked: true, purposes: ["purpose1", "purpose2"], tracking: false),
            ]),
            tracking: true,
            trackingDomains: ["domain1", "domain2"]
        )
        var manifest2 = manifest1
        manifest2.tracking = false
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let sources = [manifest1, manifest2].map { m in { try encoder.encode(m) } }
        let joined = try ManifestJoin.joinSources(sources: sources)
        XCTAssertNoDifference(joined, manifest1)
    }

    func testTrackingIsTrueIfTrueInSecond() throws {
        let manifest1 = Manifest(
            accessedAPITypes: .init(apiTypes: [
                .init(apiTypeName: "api1", apiTypeReasons: ["reason1", "reason2"]),
            ]),
            collectedDataTypes: .init(dataTypes: [
                .init(dataType: "datatype1", linked: true, purposes: ["purpose1", "purpose2"], tracking: false),
            ]),
            tracking: false,
            trackingDomains: ["domain1", "domain2"]
        )
        var manifest2 = manifest1
        manifest2.tracking = true
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let sources = [manifest1, manifest2].map { m in { try encoder.encode(m) } }
        let joined = try ManifestJoin.joinSources(sources: sources)
        XCTAssertNoDifference(joined, manifest2)
    }

    func testNonEqualThingsAreAccumulated() throws {
        let manifest1 = Manifest(
            accessedAPITypes: .init(apiTypes: [
                .init(apiTypeName: "api1", apiTypeReasons: ["reason1", "reason2"]),
            ]),
            collectedDataTypes: .init(dataTypes: [
                .init(dataType: "datatype1", linked: true, purposes: ["purpose1", "purpose2"], tracking: false),
            ]),
            tracking: false,
            trackingDomains: ["domain1", "domain2"]
        )
        let manifest2 = Manifest(
            accessedAPITypes: .init(apiTypes: [
                .init(apiTypeName: "api2", apiTypeReasons: ["reason1", "reason2"]),
            ]),
            collectedDataTypes: .init(dataTypes: [
                .init(dataType: "datatype2", linked: true, purposes: ["purpose1", "purpose2"], tracking: false),
            ]),
            tracking: false,
            trackingDomains: ["domain3", "domain4"]
        )
        let manifest3 = Manifest(
            accessedAPITypes: .init(apiTypes: [
                .init(apiTypeName: "api3", apiTypeReasons: ["reason1", "reason2"]),
            ]),
            collectedDataTypes: .init(dataTypes: [
                .init(dataType: "datatype3", linked: true, purposes: ["purpose1", "purpose2"], tracking: false),
            ]),
            tracking: false,
            trackingDomains: ["domain5", "domain6"]
        )

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let sources = [manifest1, manifest2, manifest3].map { m in { try encoder.encode(m) } }
        let joined = try ManifestJoin.joinSources(sources: sources)
        XCTAssertNoDifference(
            joined,
            Manifest(
                accessedAPITypes: .init(apiTypes: [
                    .init(apiTypeName: "api1", apiTypeReasons: ["reason1", "reason2"]),
                    .init(apiTypeName: "api2", apiTypeReasons: ["reason1", "reason2"]),
                    .init(apiTypeName: "api3", apiTypeReasons: ["reason1", "reason2"]),
                ]),
                collectedDataTypes: .init(dataTypes: [
                    .init(dataType: "datatype1", linked: true, purposes: ["purpose1", "purpose2"], tracking: false),
                    .init(dataType: "datatype2", linked: true, purposes: ["purpose1", "purpose2"], tracking: false),
                    .init(dataType: "datatype3", linked: true, purposes: ["purpose1", "purpose2"], tracking: false),
                ]),
                tracking: false,
                trackingDomains: ["domain1", "domain2", "domain3", "domain4", "domain5", "domain6"]
            )
        )
    }

    func testEqualThingsAreUpdated() throws {
        let manifest1 = Manifest(
            accessedAPITypes: .init(apiTypes: [
                .init(apiTypeName: "api1", apiTypeReasons: ["reason1", "reason2"]),
            ]),
            collectedDataTypes: .init(dataTypes: [
                .init(dataType: "datatype1", linked: true, purposes: ["purpose1", "purpose2"], tracking: false),
            ]),
            tracking: false,
            trackingDomains: ["domain1", "domain2"]
        )
        let manifest2 = Manifest(
            accessedAPITypes: .init(apiTypes: [
                .init(apiTypeName: "api1", apiTypeReasons: ["reason1", "reason3"]),
            ]),
            collectedDataTypes: .init(dataTypes: [
                .init(dataType: "datatype1", linked: false, purposes: ["purpose1", "purpose3"], tracking: true),
            ]),
            tracking: false,
            trackingDomains: ["domain1", "domain3"]
        )
        let manifest3 = Manifest(
            accessedAPITypes: .init(apiTypes: [
                .init(apiTypeName: "api1", apiTypeReasons: ["reason3", "reason4"]),
            ]),
            collectedDataTypes: .init(dataTypes: [
                .init(dataType: "datatype1", linked: true, purposes: ["purpose3", "purpose1"], tracking: false),
            ]),
            tracking: true,
            trackingDomains: ["domain3", "domain2"]
        )

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let sources = [manifest1, manifest2, manifest3].map { m in { try encoder.encode(m) } }
        let joined = try ManifestJoin.joinSources(sources: sources)
        XCTAssertNoDifference(
            joined,
            Manifest(
                accessedAPITypes: .init(apiTypes: [
                    .init(apiTypeName: "api1", apiTypeReasons: ["reason1", "reason2", "reason3", "reason4"]),
                ]),
                collectedDataTypes: .init(
                    dataTypes: [
                        .init(
                            dataType: "datatype1",
                            linked: true,
                            purposes: ["purpose1", "purpose2", "purpose3"],
                            tracking: true
                        ),
                    ]
                ),
                tracking: true,
                trackingDomains: ["domain1", "domain2", "domain3"]
            )
        )
    }
}
