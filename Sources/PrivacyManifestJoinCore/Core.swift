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
        guard let firstURL = locations.first else {
            throw Failure.emptyManifestList
        }
        var joined = try manifest(from: firstURL)

        for location in locations.dropFirst() {
            let manifest = try manifest(from: location)
            joined.update(with: manifest)
        }

        let outputData = try encoder.encode(joined)
        try output.write(data: outputData)
    }
}

private func manifest(from url: URL) throws -> Manifest {
    let data = try Data(contentsOf: url)
    let manifest = try decoder.decode(Manifest.self, from: data)
    return manifest
}

let decoder = PropertyListDecoder()

let encoder: PropertyListEncoder = {
    let enc = PropertyListEncoder()
    enc.outputFormat = .xml
    return enc
}()
