import Foundation

struct Settings {
    static var threads: Int = 1
    static var batchSize: Int = 5
    static var identifier: String = UUID().uuidString
    static var crawlDelay = 2.5
}