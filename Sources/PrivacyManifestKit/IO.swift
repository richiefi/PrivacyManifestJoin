import Foundation

/// A URL that's known to be a file URL.
public struct FileURL: Equatable {
    public let url: URL

    public init?(from string: String) {
        // the new URL(filePath:directoryHint:) is not available on Linux
        let url = URL(fileURLWithPath: string, isDirectory: false)
        guard url.isFileURL else {
            return nil
        }
        self.url = url
    }
}

/// Input source for operations.
public enum Input: Equatable {
    /// Read from standard input.
    case stdin

    /// Read from a file URL.
    case file(FileURL)

    /// Initialize from a string. Recognize "-" as meaning stdin.
    public init?(filePath: String) {
        if filePath == "-" {
            self = .stdin
            return
        }
        guard let fileURL = FileURL(from: filePath) else {
            return nil
        }
        self = .file(fileURL)
    }

    func read() throws -> Data {
        switch self {
        case .stdin:
            try FileHandle.standardInput.readToEnd() ?? Data()
        case let .file(file):
            try Data(contentsOf: file.url)
        }
    }
}

/// Output target for operations.
public enum Output {
    /// Write to standard output.
    case stdout

    /// Write to a file URL.
    case file(FileURL)

    /// Initialize from a string. Recognize "-" as meaning stdout.
    public init?(filePath: String) {
        if filePath == "-" {
            self = .stdout
            return
        }
        guard let fileURL = FileURL(from: filePath) else {
            return nil
        }
        self = .file(fileURL)
    }

    func write(data: Data) throws {
        switch self {
        case .stdout:
            try FileHandle.standardOutput.write(contentsOf: data)
        case let .file(file):
            try data.write(to: file.url, options: .atomic)
        }
    }
}
