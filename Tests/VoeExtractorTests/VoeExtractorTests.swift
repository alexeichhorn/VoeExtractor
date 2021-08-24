import XCTest
@testable import VoeExtractor

final class VoeExtractorTests: XCTestCase {
    
    func testSourceURL(_ videoURL: URL) -> URL? {
        
        let expectation = self.expectation(description: "extraction")
        var url: URL?
        
        VoeExtractor.extract(fromURL: videoURL) { videoURL in
            url = videoURL
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 20.0, handler: nil)
        
        return url
    }
    
    func testUnavailableURL() {
        let url = testSourceURL(URL(string: "https://voe.sx/e/8vi96tm5uufc")!)
        
        XCTAssertNil(url)
    }
    
    func testBunnyVideo() {
        let url = testSourceURL(URL(string: "https://voe.sx/e/2k9f4j2lxqpq")!) // TODO: upload own video
        
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.pathExtension, "m3u8")
        
        print("extracted \(String(describing: url)) for bunny video")
    }
    
    func testSourceDecoder() {
        
    }
    
    
    
    static var allTests = [
        ("testUnavailableURL", testUnavailableURL),
        ("testBunnyVideo", testBunnyVideo),
        ("testSourceDecoder", testSourceDecoder)
    ]
}
