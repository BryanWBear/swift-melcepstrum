import XCTest
@testable import SwiftMelcepstrum

// TODO

final class SwiftMelcepstrumTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let numFilters = 40
        let sampleRate = 44100
        let numFFT = 512
        
        XCTAssertEqual(SwiftMelcepstrum().mel(sampleRate: sampleRate, nFFT: numFFT, nMels: numFilters).count, 40)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
