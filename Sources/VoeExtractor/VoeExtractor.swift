import Foundation
#if os(Linux)
import FoundationNetworking
#endif

public enum VoeExtractionError: Error {
    case fileNotFound
    case unknown
}

public class VoeExtractor {
    
    /// extracts direct video url or streaming manifest from raw html of embedded voe page
    /// - parameter html: HTML of video page on voe embedded frame
    /// - throws: VoeExtractionError
    /// - returns: video url when found
    public class func extract(fromHTML html: String) throws -> URL {
        
        func extractError() -> VoeExtractionError {
            if html.lowercased().contains("file not found") {
                return .fileNotFound
            }
            return .unknown
        }
        
        let pattern = #"sources\s?=\s?\{[^(};)]*\"(?<url>http\S+.m3u8)\"[^(\};)]*\};"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        guard let match = regex?.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.count)) else { throw extractError() }
        
        let matchRange = match.range(at: 1)
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
    public class func extract(fromURL url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        
        #if os(Linux)
        
        DispatchQueue.global(qos: .background).async {
            do {
                let htmlContent = try String(contentsOf: url, encoding: .utf8)
                let videoURL = try extract(fromHTML: htmlContent)
                completion(.success(videoURL))
            } catch let error {
                completion(.failure(error))
            }
        }
        
        #else
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let htmlContent = String(data: data, encoding: .utf8) else {
                        completion(.failure(error ?? URLError(.unknown)))
                        return
                  }
            
            completion(Result {
                try extract(fromHTML: htmlContent)
            })
            
        }.resume()
        
        #endif
    }
    
    
    #if swift(>=5.5)
    
    /// extracts direct video url or streaming manifest from standard voe url
    /// - parameter url: voe url (e.g.: https://voe.sx/e/8vi96tm5uufc)
    /// - returns: video url, if found (else: nil)
    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    public class func extract(fromURL url: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            extract(fromURL: url) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    #endif
    
}
