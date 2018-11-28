//
//  APIClient.swift
//
import Foundation

public enum APIRequestMethod: String {
    case get = "GET"
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

    func request<T: Decodable>(path: String, using method: APIRequestMethod, withParameters parameters: RequestParameters, as: T.Type = T.self, completion: CompletionHandler<T>?) {

        request(path: path, using: method, withParameters: parameters) { response in
            switch response {
            case .success(let data):
                do {
                    try completion?(.success(JSONDecoder().decode(T.self, from: data)))
                } catch let decodingError {
              //    logger.debug(decodingError)
                    //assertionFailure("Error decoding the JSON. Handle it.")

                    return
                }
            }
        }
    }
    
    private func request(path: String, using method: APIRequestMethod, withParameters parameters: RequestParameters, completion: ((JSONResponse) -> Void)?) {
        guard let url = URL(string: "\(baseURLString)\(path)") else {
            assertionFailure("Error constructing request URL. Handle it!")

            return
        }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // This is a JSON client, after all...
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
