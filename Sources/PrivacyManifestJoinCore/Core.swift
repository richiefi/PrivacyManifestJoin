import Foundation

public enum JoinFailure: Error {
    case emptyLocations
}

public enum ManifestJoin {
    public enum Failure: Error {
        case emptyManifestList
    }

    public static func joinFiles(
        locations: [URL],
        output: Output
    ) throws {
        let sources = locations.map { location in { try Data(contentsOf: location) } }
        let joined = try self.joinSources(sources: sources)
        let outputData = try encoder.encode(joined)
        try output.write(data: outputData)
    }

    public static func joinSources(
        sources: [() throws -> Data]
    ) throws -> Manifest {
        guard let firstSource = sources.first else {
            throw Failure.emptyManifestList
        }
        var joined = try decoder.decode(Manifest.self, from: try firstSource())

        for source in sources.dropFirst() {
            let manifest = try decoder.decode(Manifest.self, from: try source())
            joined.update(with: manifest)
        }

        return joined
    }
}

public enum ManifestConvert {
    public static func nutritionPrivacyDetailsToManifest(
        location: URL,
        output: Output
    ) throws {
        let data = try Data(contentsOf: location)
        let manifest = try self.nutritionPrivacyDetailsToManifest(data: data)
        let outputData = try encoder.encode(manifest)
        try output.write(data: outputData)
    }

    public static func nutritionPrivacyDetailsToManifest(
        data: Data
    ) throws -> Manifest {
        let privacyDetails = try JSONDecoder().decode(NutritionPrivacyDetails.self, from: data)
        let manifest = try privacyDetails.toManifest()
        return manifest
    }
}

let decoder = PropertyListDecoder()

let encoder: PropertyListEncoder = {
    let enc = PropertyListEncoder()
    enc.outputFormat = .xml
    return enc
}()
