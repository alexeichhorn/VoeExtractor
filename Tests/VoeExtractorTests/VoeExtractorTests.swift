import XCTest
@testable import VoeExtractor

final class VoeExtractorTests: XCTestCase {
    
    func testSourceURLResult(_ videoURL: URL) -> Result<URL, Error> {
        
        let expectation = self.expectation(description: "extraction")
        var url: Result<URL, Error>?
        
        VoeExtractor.extract(fromURL: videoURL) { videoURL in
            url = videoURL
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 20.0, handler: nil)
        
        return url ?? .failure(URLError(.unknown))
    }
    
    func testSourceURL(_ videoURL: URL) throws -> URL {
        try testSourceURLResult(videoURL).get()
    }
    
    func testUnavailableURL() {
        XCTAssertThrowsError(try testSourceURL(URL(string: "https://voe.sx/e/8vi96tm5uufd")!)) { error in
            XCTAssertEqual(error as? VoeExtractionError, .fileNotFound)
        }
    }
    
    func testIncorrectURL() {
        XCTAssertThrowsError(try testSourceURL(URL(string: "https://fakevoe.sx/e/8vi96tm5uufd")!)) { error in
            #if os(Linux)
            XCTAssertFalse(error is VoeExtractionError)
            #else
            XCTAssert(error is URLError)
            #endif
        }
    }
    
    func testBunnyVideo() throws {
        let url = try testSourceURL(URL(string: "https://voe.sx/e/2k9f4j2lxqpq")!) // TODO: upload own video
        
        XCTAssertEqual(url.pathExtension, "m3u8")
        
        print("extracted \(String(describing: url)) for bunny video")
    }
    
    func testHTMLExtraction() throws {
        let html = """
        const video = document.querySelector('#voe-player');
        const VOEPlayer = new Plyr(video, {
            captions: {
                active: false,
                update: true,
                language: 'auto'
            },
            controls: ['play-large', 'play', 'progress', 'current-time', 'duration', 'mute', 'volume', 'captions', 'airplay', 'pip', 'settings', 'fullscreen'],
            fullscreen: {
                iosNative: true
            },
            tooltips: {
                controls: true,
                seek: true
            },
        });
        const sources = {
            "hls": "https://delivery-node-bahiyy.voe-network.net/hls/,6oarmxtkqq33cszcr3ynbyrqwhpq52k5seu4zo3fhorj3gwt5vesb4jmmrra,.urlset/master.m3u8",
            "video_height": 720,
        };
        var hls_config = {
            maxMaxBufferLength: 600,
            maxBufferSize: 30000000,
            debug: false,
        };

        // Please use the HLS format, as it allows us to stream more smoothly over the infrastructure.

        sources["mp4"] = uttf0(['0A', 'Xb', 'uY', '3L', 'hJ', 'nc', 't1', 'ma', '0I', '2c', 'lZ', 'XN', '0d', '3Z', 'zo', 'mc', 'vh', 'mZ', 'z8', 'me', '0U', 'XZ', 'zV', 'za', 'yU', 'Tc', 'wh', '2d', 'xJ', 'Xe', 'i5', 'We', 'zI', '3Y', '6N', '3Y', 'zM', 'Tc', 'xt', 'Gd', '41', 'mc', 'h9', 'mN', 'vQ', 'XZ', 'u5', 'ya', 'y9', '2d', '0V', 'mb', 'tU', '2b', '25', 'Se', '5l', 'Ga', 'hJ', 'WL', 'lR', '2b', 'u1', 'Se', 'yV', 'md', 'px', 'WZ', 'k9', 'yL', '6M', 'Hc', '0R', 'Ha']);
        """
        
        let url = try VoeExtractor.extract(fromHTML: html)
        
        XCTAssertEqual(url, URL(string: "https://delivery-node-bahiyy.voe-network.net/hls/,6oarmxtkqq33cszcr3ynbyrqwhpq52k5seu4zo3fhorj3gwt5vesb4jmmrra,.urlset/master.m3u8")!)
    }
    
    
    
    static var allTests = [
        ("testUnavailableURL", testUnavailableURL),
        ("testIncorrectURL", testIncorrectURL),
        ("testBunnyVideo", testBunnyVideo),
        ("testHTMLExtraction", testHTMLExtraction)
    ]
}
