import Foundation

print("hi. i'm webster. /\\oo/\\")

/**
 * fetchHTML
 *
 * Fetch the HTML for the given url
 *
 * - parameter from: The URL of the page
 **/
func fetchHTML(from url: URL, completion: ((String) -> Void)?) {
    var request = URLRequest(url: url)

    request.httpMethod = "GET"

    // Set our request headers
    request.setValue("text/html; charset=utf-8", forHTTPHeaderField: "Accept")
    request.setValue("text/html; charset=utf-8", forHTTPHeaderField: "Content-Type") 

    print("About to build it")

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200..<300) ~= httpResponse.statusCode,
                let data = data else {
                    print("well the data was wonk")
                    assertionFailure("Some kind of network request problem happened!")

                    return
                }
                guard let html = String(data: data, encoding: .utf8) else {
                    print("well, decoding it was wonk")
                    assertionFailure("We failed on converting the html DATA to STRING.")

                    return
                }

                print("oh, okay, cool, lets callback")
                completion?(html)
    }
    print("about to fire it up! fire it up! fire it up!")
    task.resume()
}

let websiteURL = "http://thingerly.com/crawler/"

print(websiteURL)

guard let url = URL(string: websiteURL) else {
    exit(0)
}

fetchHTML(from: url) { html in
    print("inside the callback")
    print(html)
}

dispatchMain()
