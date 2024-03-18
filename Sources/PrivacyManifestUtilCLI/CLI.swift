import ArgumentParser
import Foundation
import PrivacyManifestUtilCore

@main
struct PrivacyManifestUtil: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "privacy-manifest-util",
        abstract: "Work with privacy manifest files",
        subcommands: [Join.self, FromNutrition.self, ToNutrition.self]
    )
}

struct Join: ParsableCommand {
    static let configuration
        = CommandConfiguration(abstract: "Join privacy manifest files.")

    @Argument(help: "Privacy manifest files to join", transform: FileURL.init(validating:))
    var files: [FileURL]

    @Option(help: "Output file or - for stdout. Defaults to stdout", transform: Output.init(validating:))
    var output: Output = .stdout

    func run() throws {
        try ManifestJoin.joinFiles(
            locations: self.files.map { $0.url },
            output: self.output
        )
    }

    func validate() throws {
        guard !self.files.isEmpty else {
            throw ValidationError("Please provide at least one input file.")
        }
    }
}

struct FromNutrition: ParsableCommand {
    static let configuration
        = CommandConfiguration(abstract: "Convert nutrition label JSON to manifest.")

    @Argument(
        help: "Nutrition label JSON file to read or - for stdin. Defaults to stdin",
        transform: Input.init(validating:)
    )
    var nutrition: Input = .stdin

    @Argument(help: "Manifest file to write or - for stdout. Defaults to stdout", transform: Output.init(validating:))
    var manifest: Output = .stdout

    func run() throws {
        try ManifestConvert.nutritionPrivacyDetailsToManifest(input: self.nutrition, output: self.manifest)
    }
}

struct ToNutrition: ParsableCommand {
    static let configuration
        = CommandConfiguration(abstract: "Convert manifest to nutrition label JSON.")

    @Argument(
        help: "Manifest property list file to read or - for stdin. Defaults to stdin",
        transform: Input.init(validating:)
    )
    var manifest: Input = .stdin

    @Argument(help: "Nutrition label JSON file to write or - for stdout. Defaults to stdout", transform: Output.init(validating:))
    var nutrition: Output = .stdout

    func run() throws {
        try ManifestConvert.manifestToNutritionPrivacyDetails(input: self.manifest, output: self.nutrition)
    }
}

extension FileURL {
    init(validating string: String) throws {
        // the new URL(filePath:directoryHint:) is not available on Linux
        guard let fileURL = FileURL(from: string) else {
            throw ValidationError("Could not parse as path: \(string)")
        }
        self = fileURL
    }
}

extension Input {
    init(validating string: String) throws {
        guard let input = Input(filePath: string) else {
            throw ValidationError("Could not parse as input source: \(string)")
        }
        self = input
    }
}

extension Output {
    init(validating string: String) throws {
        guard let output = Output(filePath: string) else {
            throw ValidationError("Could not parse as output target: \(string)")
        }
        self = output
    }
}
