import Foundation
#if os(Linux)
import FoundationNetworking
#endif

public class VoeExtractor {
    
    /// extracts direct video url or streaming manifest from raw html of embedded voe page
    /// - parameter html: HTML of video page on voe embedded frame
    /// - returns: video url when found
    public class func extract(fromHTML html: String) -> URL? {
        
        let pattern = #"sources\s?=\s?\{[^(};)]*\"(?<url>http\S+.m3u8)\"[^(\};)]*\};"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        guard let match = regex?.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.count)) else { return nil }
        
        let matchRange = match.range(at: 1)
        guard let range = Range(matchRange, in: html) else { return nil }
        
        let videoURL = String(html[range])
        
        return URL(string: videoURL)
    }
    
    
    /// extracts direct video url or streaming manifest from standard voe url
    /// - parameter url: voe url (e.g.: https://voe.sx/e/8vi96tm5uufc)
    /// - parameter completion: called when result is found. returns video url
    public class func extract(fromURL url: URL, completion: @escaping (URL?) -> Void) {
        
        #if os(Linux)
        
        DispatchQueue.global(qos: .background).async {
            guard let htmlContent = try? String(contentsOf: url, encoding: .utf8) else {
                completion(nil)
                return
            }
            
            completion(extract(fromHTML: htmlContent))
        }
        
        #else
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let htmlContent = String(data: data, encoding: .utf8) else {
                      completion(nil)
                      return
                  }
            
            completion(extract(fromHTML: htmlContent))
            
        }.resume()
        
        #endif
    }
    
}
