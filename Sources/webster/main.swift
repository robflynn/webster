import Foundation
import SwiftyBeaver

let logger = SwiftyBeaver.self
logger.addDestination(ConsoleDestination())    

var _website: Website?

let client = WebsterClient()

var pageQueue = 0

func fetchBatch(completion: @escaping ([Page]) -> Void) {
    guard let website = _website else { 
        assertionFailure("Make sure the crawler is initialized first. Fix me.")

        return 
    }

    client.getBatch(of: Settings.batchSize, from: website) { 
        if $0.isEmpty {
            print($0)
            // We have no more pages
            print("No more pages to crawl, shutting down...")

            exit(0)
        }

        completion($0)
    }
}

func pageCompleted() {
    print("<===== LEAVING")

    DispatchQueue.main.async {
        pageQueue -= 1

        print("Pages remaining in queue: \(pageQueue)")

        // If we're down to zero then it's time to get more
        if pageQueue == 0 {
            // Fire off another batch of requests after a bit of a delay
            print("Fetching another batch in \(Settings.crawlDelay) seconds... ")
            DispatchQueue.main.asyncAfter(deadline: .now() + Settings.crawlDelay) {
                crawlBatch()
            }
        }
    }
}

func crawlBatch() {
    let pageDispatchQueue = DispatchQueue(label: "websterPageQueue", attributes: .concurrent)

    fetchBatch { pages in 
        // loop through each page and crawl it
        pageQueue = pages.count

        for page in pages {
            print("ENTERING ===> ")

            pageDispatchQueue.async {
                do {
                    try fetch(from: page.url) { response in
                        DispatchQueue.main.async {
                            client.store(page: page, response: response) {
                                pageCompleted()                            
                            }
                        }
                    }
                } catch FetchError.InvalidURL(_) {
                    DispatchQueue.main.async {
                        client.storeError(for: page, message: "Invalid URL") {
                            pageCompleted()                        
                        }
                    }

                    print("<=== LEAVING")
                } catch {
                    // unknown error                
                    assertionFailure("Some kind of uncaught error")

                    print("<=== LEAVING")
                    pageCompleted()
                }
            }
        }
    }
}

func crawl(website: Website) {
    _website = website

    crawlBatch()
}

func initialize() {
    // say hello, it's the polite thing to do
    print("hi. i'm webster. /\\oo/\\")    

    client.crawl("Demo Site", startingWith: "https://thingerly.com/crawler") {
        crawl(website: $0)
    }
}

// Initialize our app
DispatchQueue.main.async {
    initialize()
}

dispatchMain()