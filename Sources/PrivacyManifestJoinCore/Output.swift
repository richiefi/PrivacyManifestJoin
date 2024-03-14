import Foundation

public enum Output {
    case stdout
    case url(URL)

    func write(data: Data) throws {
        switch self {
        case .stdout:
            try FileHandle.standardOutput.write(contentsOf: data)
        case let .url(url):
            try data.write(to: url, options: .atomic)
        }
    }
}
