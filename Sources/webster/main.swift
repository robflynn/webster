import Foundation

print("hi. i'm webster. /\\oo/\\")

/**
 * fetchHTML
 *
 * Fetch the HTML for the given url
 *
 * - parameter from: The URL of the page
 **/
func fetchHTML(from url: URL) -> String {
    let html = "<html></html>"

    return html
}

let websiteURL = "http://thingerly.com/crawler/"

print(websiteURL)

guard let url = URL(string: websiteURL) else {
    exit(0)
}

print(fetchHTML(from: url))
