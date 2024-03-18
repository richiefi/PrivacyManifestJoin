import Foundation

/// Manifest join functions.
public enum ManifestJoin {
    /// Manifest join failures.
    public enum Failure: Error {
        /// Thrown when trying to join an empty manifest list.
        case emptyManifestList
    }

    /// Join manifest files from `locations` and output the result into `output`.
    public static func joinFiles(
        locations: [URL],
        output: Output
    ) throws {
        let sources = locations.map { location in { try Data(contentsOf: location) } }
        let joined = try self.joinSources(sources: sources)
        let outputData = try encoder.encode(joined)
        try output.write(data: outputData)
    }

    /// Join manifest files from `sources` and return the combined manifest.
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

/// Manifest conversion functions.
public enum ManifestConvert {
    /// Convert a nutrition privacy details file from `input` into a manifest and save the result in `output.`
    public static func nutritionPrivacyDetailsToManifest(
        input: Input,
        output: Output
    ) throws {
        let data = try input.read()
        let manifest = try self.nutritionPrivacyDetailsToManifest(data: data)
        let outputData = try encoder.encode(manifest)
        try output.write(data: outputData)
    }

    /// Convert nutrition privacy details file contents into a manifest.
    public static func nutritionPrivacyDetailsToManifest(
        data: Data
    ) throws -> Manifest {
        let privacyDetails = try JSONDecoder().decode(NutritionPrivacyDetails.self, from: data)
        let manifest = try privacyDetails.toManifest()
        return manifest
    }

    /// Convert a manifest file from `input` into a nutrition privacy details file and save the result in `output.`
    public static func manifestToNutritionPrivacyDetails(
        input: Input,
        output: Output,
        pretty: Bool
    ) throws {
        let data = try input.read()
        let nutrition = try self.manifestToNutritionPrivacyDetails(data: data)
        let encoder = JSONEncoder()
        if pretty {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }
        let outputData = try encoder.encode(nutrition)
        try output.write(data: outputData)
    }

    /// Convert manifest file contents into nutrition privacy details.
    public static func manifestToNutritionPrivacyDetails(
        data: Data
    ) throws -> NutritionPrivacyDetails {
        let manifest = try decoder.decode(Manifest.self, from: data)
        let nutrition = try NutritionPrivacyDetails(manifest: manifest)
        return nutrition
    }
}

let decoder = PropertyListDecoder()

let encoder: PropertyListEncoder = {
    let enc = PropertyListEncoder()
    enc.outputFormat = .xml
    return enc
}()
