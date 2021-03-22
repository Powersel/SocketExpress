import XCTest
@testable import SocketExpress

final class SocketExpressTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SocketExpress().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
