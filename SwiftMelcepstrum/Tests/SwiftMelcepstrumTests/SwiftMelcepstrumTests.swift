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
        
        if #available(OSX 10.15, *) {
            XCTAssertEqual(SwiftMelcepstrum().mel(sampleRate: sampleRate, nFFT: numFFT, nMels: numFilters).count, numFilters * (numFFT / 2 + 1))
        } else {
            // Fallback on earlier versions
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
