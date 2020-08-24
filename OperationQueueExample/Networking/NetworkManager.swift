//
//  NetworkManager.swift
//  OperationQueueExample
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let session = URLSession.shared
    private let baseUrlPath: String = "https://api.punkapi.com/v2"
    
    func fetch<T: Codable>(endpointPath path: String, completion: @escaping (_ json: T) -> Void) {
        let fullUrlPath = "\(baseUrlPath)/\(path)"
        guard let url = URL(string: fullUrlPath) else {
            debugPrint("Wrong url path: \(fullUrlPath)")
            return
        }
        
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            guard let data = data, let _ = response as? HTTPURLResponse else { return
            }
            
            do {
                let json = try JSONDecoder().decode(T.self, from: data)
                completion(json)
            } catch {
                debugPrint(error)
            }
        }
        
        dataTask.resume()
    }
}



