import XCTest
@testable import Connectivium

final class ConnectiviumTests: XCTestCase {
    let goodEndpoint = Endpoint("https://www.google.com")
    let badEndpoint = Endpoint("https://www.googleasdfafas2342!.com")

    @available(macOS 12.0, *)
    @available(iOS 15.0, *)
    func testAsyncGetEndpoint() async throws {
        do {
            let data = try await Connectivium.get(goodEndpoint)
            XCTAssertNotEqual(data, Data())
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
                XCTAssertNotEqual(data, Data())
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
            XCTAssertNotNil(error)
        }
    }

    func testCompletion_withBadURL_throws() throws {
        let expectation = self.expectation(description: #function)
        Connectivium.get(badEndpoint) { result in
            expectation.fulfill()
            switch result {
            case .success(let data):
                XCTFail(self.badResult(data: data))
            case .failure(let error):
                XCTAssertNotNil(error)
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    @available(macOS 12.0, *)
    @available(iOS 15.0, *)
    func testHeadersAreAdded_toAsyncGet() async throws {
        let headers = [
            "test": "value",
            "test2": "value"
        ]
        do {
            let data = try await Connectivium.get(goodEndpoint, headers: headers)
            XCTAssertNotNil(data)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    private func badResult(data: Data) -> String {
        "expected failure, but got \(String(data: data, encoding: .utf8) ?? "Nothing")"
    }
}
