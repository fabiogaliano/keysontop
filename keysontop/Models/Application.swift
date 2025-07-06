import Foundation

struct Application: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let bundleIdentifier: String
    let version: String?
    
    init(id: String = UUID().uuidString, name: String, bundleIdentifier: String, version: String? = nil) {
        self.id = id
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.version = version
    }
}

extension Application {
    static let unknown = Application(
        name: "Unknown Application",
        bundleIdentifier: "com.unknown.application"
    )
}