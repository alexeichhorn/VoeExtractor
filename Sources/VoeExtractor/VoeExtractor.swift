import Foundation
import URLSessionWrapper
#if os(Linux)
import FoundationNetworking
#endif

public enum VoeExtractionError: Error {
    case fileNotFound
    case htmlDecodingError
    case unknown
}

public class VoeExtractor {
    
    let urlSession: URLSessionWrapper
    
    #if !os(Linux)
    public static let `default` = VoeExtractor(urlSession: .default)
    #endif
    
    public init(urlSession: URLSessionWrapper) {
        self.urlSession = urlSession
    }
    
    /// extracts direct video url or streaming manifest from raw html of embedded voe page
    /// - parameter html: HTML of video page on voe embedded frame
    /// - throws: VoeExtractionError
    /// - returns: video url when found
    public func extract(fromHTML html: String) throws -> URL {
        
        func extractError() -> VoeExtractionError {
            if html.lowercased().contains("file not found") || html.lowercased().contains("404 - not found") {
                return .fileNotFound
            }
            return .unknown
        }
        
        //let pattern = #"sources\s?=\s?\{[^(};)]*(\"|')(?<url>http\S+.m3u8(\?\S+)?)(\"|')[^(\};)]*\};"#
        let pattern = #"(\"|')(?<url>http\S+.m3u8(\?\S+)?)(\"|')"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        guard let match = regex?.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.count)) else { throw extractError() }
        
        let matchRange = match.range(at: 2)
        guard let range = Range(matchRange, in: html) else { throw extractError() }
        
        if let videoURL = URL(string: String(html[range])) {
            return videoURL
        } else {
            throw VoeExtractionError.unknown
        }
    }
    
    
    /// extracts direct video url or streaming manifest from standard voe url
    /// - parameter url: voe url (e.g.: https://voe.sx/e/8vi96tm5uufc)
    /// - parameter completion: called when result is found. returns video url
    public func extract(fromURL url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        Task {
            do {
                let videoURL = try await extract(fromURL: url)
                completion(.success(videoURL))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    private func loadPageHTML(fromURL url: URL) async throws -> String {
        
        let request = URLSessionWrapper.Request(url: url)
        let response = try await urlSession.handleRequest(request)
        
        if response.statusCode == 404 {
            throw VoeExtractionError.fileNotFound
        }
        
        //print(response.statusCode)
        guard let htmlContent = String(data: response.data, encoding: .utf8) else {
            throw VoeExtractionError.htmlDecodingError
        }
        
        return htmlContent
    }
    
    /// Find javascript `window.location.href`-style redirect
    /// - returns: nil if not found
    private func findRedirectURL(html: String) -> URL? {
        
        let pattern = #"window\.location\.href = ('|")(?<url>https\S+)('|")"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        guard let match = regex?.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.count)) else { return nil }
        
        let matchRange = match.range(at: 2)
        guard let range = Range(matchRange, in: html) else { return nil }
        
        if let redirectURL = URL(string: String(html[range])) {
            return redirectURL
        } else {
            return nil
        }
    }
    
    #if swift(>=5.5)
    
    /// extracts direct video url or streaming manifest from standard voe url
    /// - parameter url: voe url (e.g.: https://voe.sx/e/8vi96tm5uufc)
    /// - returns: video url, if found (else: nil)
    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    public func extract(fromURL url: URL) async throws -> URL {
        
        let htmlContent = try await loadPageHTML(fromURL: url)
        
        do {
            return try extract(fromHTML: htmlContent)
        } catch let error {
            
            // see if there is a redirect inside
            if let redirectURL = findRedirectURL(html: htmlContent) {
                let htmlContent = try await loadPageHTML(fromURL: redirectURL) // redo steps (instead of recursive style) to prevent infinite loop
                return try extract(fromHTML: htmlContent)
            } else {
                throw error
            }
        }
    }
    
    #endif
    
}
