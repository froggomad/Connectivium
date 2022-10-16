import Foundation
public struct Connectivium {

    public init() { }

    @available(macOS 12.0, *)
    static func get(_ endpoint: Endpoint) async throws -> Data {
        try await NetworkManager.get(endpoint)
    }

    static func get(_ endpoint: Endpoint, completion: @escaping (Result<Data, NetworkManager.Error>) -> Void) {
        NetworkManager.get(endpoint, completion: completion)
    }
}
