//
//  JSON.swift
//  OperationQueueExample
//

import Foundation

struct JSON {}

extension JSON {
    struct Beer: Codable {
        let id: Int
        let name: String
        let firstBrewed: String?
        let description: String
        let imageUrl: String?
        let abv: Double?
        let ibu: Double?
        
        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case firstBrewed = "first_brewed"
            case description
            case imageUrl = "image_url"
            case abv
            case ibu
        }
    }
}
