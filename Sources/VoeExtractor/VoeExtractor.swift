import Foundation

public class VoeExtractor {
    
    /// extracts direct video url or streaming manifest from raw html of embedded voe page
    /// - parameter html: HTML of video page on voe embedded frame
    /// - returns: video url when found
    public class func extract(fromHTML html: String) -> URL? {
        
        return nil
    }
    
    
    public class func extract(fromURL url: URL, completion: @escaping (URL?) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let htmlContent = String(data: data, encoding: .utf8) else {
                      completion(nil)
                      return
                  }
            
            completion(extract(fromHTML: htmlContent))
            
        }.resume()
        
    }
    
}
