//
//  APIClient.swift
//
import Foundation

public enum APIRequestMethod: String {
    case get = "GET"
    case patch = "PATCH"
}

public enum JSONResponse {
    case success(Data)
}

/**
 Basic JSON APIClient Protocol
 */
protocol JSONAPIClient {
    var baseURLString: String { get }
    var environment: APIEnvironment { get }
}

extension JSONAPIClient {
    typealias RequestParameters = [String: Any]
    typealias CompletionHandler<T> = (APIResponse<T>) -> Void

    func get<T: Decodable>(as requestedType: T.Type = T.self, from path: String, completion: CompletionHandler<T>?) {
        return request(path: path, using: .get, withParameters: [:], as: requestedType, completion: completion)
    }

    func get<T: Decodable>(as requestedType: T.Type = T.self, from path: String, withParameters parameters: RequestParameters, completion: CompletionHandler<T>?) {
        return request(path: path, using: .get, withParameters: parameters, as: requestedType, completion: completion)
    }

    func patch(path: String, withParameters parameters: RequestParameters, completion: ((JSONResponse) -> Void)?) {
        return request(path: path, using: .patch, withParameters: parameters, completion: completion)
    }

    func request<T: Decodable>(path: String, using method: APIRequestMethod, withParameters parameters: RequestParameters, as: T.Type = T.self, completion: CompletionHandler<T>?) {

        request(path: path, using: method, withParameters: parameters) { response in
            switch response {
            case .success(let data):               
                do {
                    try completion?(.success(JSONDecoder().decode(T.self, from: data)))
                } catch let decodingError {
                    logger.error(decodingError)

                    guard let rawResponse: String = String(data: data, encoding: .utf8) else { return }

                    print(rawResponse)

                    assertionFailure("Error decoding the JSON. Handle it.")

                    return
                }
            }
        }
    }
    
    private func request(path: String, using method: APIRequestMethod, withParameters parameters: RequestParameters, completion: ((JSONResponse) -> Void)?) {
        guard var urlComponents = URLComponents(string: self.baseURLString) else {
            assertionFailure("Error constructing request URL. Handle it!")

            return            
        }

        // append our request path
        urlComponents.path += path

        // and any request parameters that we may have
        if method == .get {
            urlComponents.queryItems = parameters.map {
                URLQueryItem(name: $0.0, value: String(describing: $0.1))
            }
        }

        guard let url = urlComponents.url else { 
            assertionFailure("Error building URL")

            return 
        }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Set up request headers
        // This is a JSON client, after all...
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // set up request body, if needed
        if (method != .get) {
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        }        

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200..<300) ~= httpResponse.statusCode,
                let data = data else {                    
                    assertionFailure("Some kind of network request problem happened!")

                    return
                }

            completion?(.success(data))
        }

        task.resume()
    }
}
