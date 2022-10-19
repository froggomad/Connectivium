import XCTest
@testable import Connectivium

final class ConnectiviumTests: XCTestCase {
    let goodEndpoint = Endpoint("https://www.google.com")
    let badEndpoint = Endpoint("https://www.googleasdfafas2342!.com")
    let headers = [
        "test": "value",
        "test2": "value"
    ]

    @available(macOS 12.0, *)
    @available(iOS 15.0, *)
    func testAsyncGetEndpoint() async throws {
        do {
            let data = try await Connectivium.get(goodEndpoint)
            XCTAssertNotEqual(data, Data(), "The Data was empty")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testCompletionGetEndpoint() throws {
        let expectation = self.expectation(description: #function)
        Connectivium.get(goodEndpoint) { result in
            expectation.fulfill()
            switch result {
            case .success(let data):
                XCTAssertNotEqual(data, Data(), "The Data was empty")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    @available(macOS 12.0, *)
    @available(iOS 15.0, *)
    func testAsync_withBadURL_throws() async throws {
        do {
            let data = try await Connectivium.get(badEndpoint)
            XCTFail(badResult(data: data))
        } catch {
            XCTAssertNotNil(error.localizedDescription, "Expected an error, but got data")
        }
    }

    func testCompletion_withBadURL_throws() throws {
        let expectation = self.expectation(description: #function)
        Connectivium.get(badEndpoint) { result in
            switch result {
            case .success(let data):
                XCTFail(self.badResult(data: data))
            case .failure(let error):
                XCTAssertNotNil(error, "Expected an error")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testHeadersAreAdded_toRequest() throws {
        do {
            let request = try NetworkManager.composeRequest(using: goodEndpoint, headers: headers)
            XCTAssertEqual(request.allHTTPHeaderFields, headers, "The request's headers do not match")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testURLIsComposed_fromEndpoint() throws {
        do {
            let request = try NetworkManager.composeRequest(using: goodEndpoint, headers: [:])
            XCTAssertEqual(request.url, try goodEndpoint.url(), "The request URL doesn't match the endpoint URL")
        }
    }

    private func badResult(data: Data) -> String {
        "expected failure, but got \(String(data: data, encoding: .utf8) ?? "Nothing")"
    }
}
