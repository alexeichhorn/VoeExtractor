import Foundation
#if os(Linux)
import FoundationNetworking
#endif

public class VoeExtractor {
    
    /// extracts direct video url or streaming manifest from raw html of embedded voe page
    /// - parameter html: HTML of video page on voe embedded frame
    /// - returns: video url when found
    public class func extract(fromHTML html: String) -> URL? {
        
        return nil
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
