import ArgumentParser
import Foundation
import PrivacyManifestJoinCore

@main
struct Join: ParsableCommand {
    @Argument(help: "Privacy manifest files to join", transform: FileURL.init(from:))
    var files: [FileURL]

    @Option(help: "Output file. Defaults to standard output", transform: FileURL.init(from:))
    var outputFile: FileURL?

    func run() throws {
        let output: Output = if let url = self.outputFile?.url { .url(url) } else { .stdout }
        try ManifestJoin.joinFiles(
            locations: self.files.map { $0.url },
            output: output
        )
    }

    func validate() throws {
        guard !files.isEmpty else {
            throw ValidationError("Please provide at least one input file.")
        }
    }
}

struct FileURL {
    var url: URL

    init(from string: String) throws {
        // the new URL(filePath:directoryHint:) is not available on Linux
        let url = URL(fileURLWithPath: string, isDirectory: false)
        guard url.isFileURL else {
            throw ValidationError("Could not be parsed as path")
        }
        self.url = url
    }
}
