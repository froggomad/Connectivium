import Foundation
public struct Connectivium {

    public init() { }

    @available(macOS 12.0, *)
    @available(iOS 15.0, *)
    public static func get(_ endpoint: Endpoint, headers: [String: String] = [:]) async throws -> Data {
        try await NetworkManager.get(endpoint, headers: headers)
    }

    public static func get(_ endpoint: Endpoint, headers: [String:String] = [:], completion: @escaping (Result<Data, NetworkManager.Error>) -> Void) {
        NetworkManager.get(endpoint, headers: headers, completion: completion)
    }

    public static func set(session: URLSession) {
        NetworkManager.session = session
    }
}
