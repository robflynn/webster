// Page.swift
//
// Representation of a webpage
//
public struct Page: Decodable {
    var id: Int    
    var websiteID: Int
    var url: String
    var title: String?
    var contentType: String?
    var content: String?
    var responseCode: Int?
    var message: String?

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case websiteID = "website_id"
        case title
        case contentType = "content_type"
        case content
        case responseCode = "response_code"
        case message
    }
}