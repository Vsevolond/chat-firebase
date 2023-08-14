import Foundation


enum CheckStatus {
    case valid
    case invalid
    case error
}

enum NetworkError: Error {
    case noData
    case other(String)
}

struct ResponseAPI: Codable {
    let status: String
    let text: String
    let error: String?
}

protocol NetworkManagerDescription {
    func checkApiKey(apikey: String, completion: @escaping (CheckStatus) -> Void)
    func getAnswer(text: String, completion: @escaping (Result<String, NetworkError>) -> Void)
}

final class NetworkManager: NetworkManagerDescription {
    static let shared: NetworkManagerDescription = NetworkManager()
    
    private init() {}
    
    func checkApiKey(apikey: String, completion: @escaping (CheckStatus) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/models") else {
            completion(.error)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apikey)", forHTTPHeaderField: "Authorization")
        
        let mainThreadCompletion: ((CheckStatus) -> Void) = { checkStatus in
            DispatchQueue.main.async {
                completion(checkStatus)
            }
        }
        
        DispatchQueue.global().async {
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                guard let httpResponse = response as? HTTPURLResponse else {
                    mainThreadCompletion(.error)
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    mainThreadCompletion(.valid)
                } else {
                    mainThreadCompletion(.invalid)
                }
            }
            
            task.resume()
        }
    }
    
    func getAnswer(text: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        let sentences = Int.random(in: 1...5)

        guard let url = URL(string: "https://fish-text.ru/get?format=json&number=\(sentences)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let mainThreadCompletion: ((Result<String, NetworkError>) -> Void) = { result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                completion(result)
            }
        }
        
        DispatchQueue.global().async {
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error {
                    mainThreadCompletion(.failure(.other(error.localizedDescription)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    mainThreadCompletion(.failure(.other("Http status is not 200")))
                    return
                }
                
                guard let data else {
                    mainThreadCompletion(.failure(.noData))
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let responseApi = try decoder.decode(ResponseAPI.self, from: data)
                    mainThreadCompletion(.success(responseApi.text))
                } catch let error {
                    mainThreadCompletion(.failure(.other(error.localizedDescription)))
                }
            }
            
            task.resume()
        }
    }
}

