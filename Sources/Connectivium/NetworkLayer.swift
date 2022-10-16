//
//  File.swift
//  
//
//  Created by Kenneth Dubroff on 10/15/22.
//

import Foundation
import CoreData

/// Url backed by String
/// - Usage:
///  ```extension Endpoint {
///      static let myCustomEndpoint = Endpoint("https://www.google.com")
///    }
///    async let dataResult = Connectivium.get(.myCustomEndpoint)
///    ```
public struct Endpoint {
    public let rawValue: String

    public init(_ urlString: String) {
        self.rawValue = urlString
    }

    public func url() throws -> URL {
        guard let url = URL(string: rawValue) else {
            throw NetworkManager.Error.badURL(string: rawValue)
        }
        return url
    }
}

extension Endpoint: CustomStringConvertible {
    public var description: String {
        "Endpoint.\(rawValue)"
    }
}

public class NetworkManager {
    public enum Error: LocalizedError {
        case badURL(string: String)
        case badResponse(code: Int)
        case swiftError(error: Swift.Error)
        case noData

        /// A localized message describing what error occurred.
        public var errorDescription: String? {
            switch self {
            case .badURL(let url):
                return "The url \(url) is invalid"
            case .badResponse(let responseCode):
                return "The server returned an unexpected response: \(responseCode)"
            case .swiftError(let error):
                return "An unexpected error occurred:\n \(error.localizedDescription)"
            case .noData:
                return "No data was retrieved"
            }
        }

        /// A localized message describing the reason for the failure.
        public var failureReason: String? {
            switch self {
            case .badURL:
                return "The server may be unresponsive or the URL does not exist"
            case .badResponse(let statusCode):
                switch statusCode {
                case 404:
                    return "The server failed to respond (not found error)"
                default:
                    return "The server returned an unexpected response"
                }
            case .swiftError:
                return nil
            case .noData:
                return "The server seems to be malfunctioning"
            }
        }

        /// A localized message describing how one might recover from the failure.
        public var recoverySuggestion: String? {
            return "Please try again later"
        }

        /// A localized message providing "help" text if the user requests help.
        public var helpAnchor: String? {
            nil
        }
    }

    internal static var session: URLSession = .shared

    @available(macOS 12.0, *)
    @available(iOS 15.0, *)
    internal static func get(_ endpoint: Endpoint, headers: [String:String] = [:]) async throws -> Data {
        guard let url = URL(string: endpoint.rawValue) else {
            throw Error.badURL(string: endpoint.rawValue)
        }
        var request = URLRequest(url: url)
        for header in headers {
            request.addValue(header.key, forHTTPHeaderField: header.value)
        }

        do {
            return try await session.data(for: request).0
        } catch let sessionError {
            let error = Error.swiftError(error: sessionError)
            throw error
        }
    }

    internal static func get(_ endpoint: Endpoint, headers: [String:String] = [:], completion: @escaping (Result<Data, Error>) -> Void) {
        do {
            let url = try endpoint.url()
            var request = URLRequest(url: url)
            for header in headers {
                request.addValue(header.key, forHTTPHeaderField: header.value)
            }

            session.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    completion(.failure(.swiftError(error: error ?? Error.noData)))
                    return
                }
                guard let response = response as? HTTPURLResponse,
                      response.statusCode >= 200,
                      response.statusCode < 400
                else {
                    let response = response as? HTTPURLResponse
                    completion(.failure(.badResponse(code: response?.statusCode ?? 99999)))
                    return
                }
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                completion(.success(data))
            }.resume()
        } catch {
            completion(.failure(.badURL(string: endpoint.rawValue)))
            return
        }
    }
}
