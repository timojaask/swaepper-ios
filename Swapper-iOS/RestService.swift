import Foundation

class RestService {
    static let sharedInstance = RestService()
    
    typealias RestClientCompletionHandler = (_ success: Bool, _ response: Data?, _ statusCode: Int?) -> Void
    
    fileprivate lazy var session: URLSession = {
        return URLSession.init(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
    }()
    
    func postRequest(_ fullPath: String, headers: [String: String], params: [String:Any], completion: @escaping RestClientCompletionHandler) {
        guard let postData = paramsToData(params) else {
            completion(false, nil, nil)
            return
        }
        
        let url = URL.init(string: fullPath)!
        let request = NSMutableURLRequest.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5)
        request.httpMethod = "POST";
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { (field, value) in
            request.setValue(value, forHTTPHeaderField: field)
        }
        request.httpBody = postData
        
        sendRequest(request as URLRequest, completion: completion)
    }
    
    func getRequest(_ fullPath: String, headers: [String: String], completion: @escaping RestClientCompletionHandler) {
        let url = URL.init(string: fullPath)!
        let request = NSMutableURLRequest.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5)
        request.httpMethod = "GET";
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { (field, value) in
            request.setValue(value, forHTTPHeaderField: field)
        }
        sendRequest(request as URLRequest, completion: completion)
    }
    
    func deleteRequest(_ fullPath: String, headers: [String: String], completion: @escaping RestClientCompletionHandler) {
        let url = URL.init(string: fullPath)!
        let request = NSMutableURLRequest.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5)
        request.httpMethod = "DELETE";
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { (field, value) in
            request.setValue(value, forHTTPHeaderField: field)
        }
        sendRequest(request as URLRequest, completion: completion)
    }
    
    // MARK: - private helper functions
    
    fileprivate func paramsToData(_ params: [String:Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
    }
    
    fileprivate func sendRequest(_ request: URLRequest, completion: @escaping RestClientCompletionHandler) {
        session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                debugPrint("ERROR: \(error)")
            }
            self.handleResponse(data, response: response, error: error as! NSError, completion: completion)
        }) .resume()
    }
    
    fileprivate func handleResponse(_ data: Data?, response: URLResponse?, error: NSError?, completion: @escaping RestClientCompletionHandler) {
        var success = false
        var statusCode: Int? = nil
        if let httpResponse = response as? HTTPURLResponse {
            statusCode = httpResponse.statusCode
            success = statusCode == 200
        }
        DispatchQueue.main.async {
            completion(success, data, statusCode)
        }
    }
}
