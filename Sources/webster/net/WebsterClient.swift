// 
// WebsterClient
//
// API Client for Webster
//
class WebsterClient: JSONAPIClient {
    var baseURLString: String {
        switch self.environment {
            case .local: return "http://localhost:3000/api/v0"
        }
    }

    var environment: APIEnvironment = .local    

    func crawl(_ name: String, startingWith urlString: String, completion: ((Website)->())?) {
        let parameters: RequestParameters = [
            "url": urlString,
            "name": name
        ]

        get(as: Website.self, from: "/websites", withParameters: parameters) { response in
            switch response {
                case .success(let website):
                    logger.debug("Website registered...")

                    completion?(website)
                case .failure(let error):
                    logger.error(error)

                    assertionFailure("Unhandled failure case.")
            }
        }
    }   

    func getBatch(of size: Int, from website: Website, completion: (([Page]) -> ())?) {        
        let params = [
            "website_id": website.id,
            "batch_size": size
        ]

        get(as: [Page].self, from: "/pages", withParameters: params) { response in 
            switch response {
                case .success(let pages):
                    logger.debug("Retrieved batch of pages")
                    logger.debug(pages)

                    completion?(pages)
                case .failure(let error):
                    logger.error(error)

                    assertionFailure("Unhandled failure case.")
            }
        }
    }

    func store(page: Page, response: FetchResponse, completion: (() -> ())? = nil) {
        let params: RequestParameters = [
            "id": page.id,
            "content_type": response.contentType,
            "content": response.content,
            "response_code": response.responseCode,
            "error": response.error
        ]

        patch(path: "/pages/\(page.id)", withParameters: params) { _ in
            completion?()
        }
    }

    func storeError(for page: Page, message: String, completion: (() -> ())? = nil) {
        let params: RequestParameters = [
            "id": page.id,
            "message": message,
            "error": true
        ]

        patch(path: "/pages/\(page.id)", withParameters: params) { _ in
            completion?()
        }
    }
}