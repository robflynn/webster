// Website.swift
//
// Representation of a website
//
public struct Website: Decodable {
    var id: Int
    var name: String
    var url: String
    var status: String
    var domain: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url
        case status
        case domain
    }
}