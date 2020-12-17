//
//  ListResponse.swift
//  Demo
//
//  Created by Jakov Videkovic on 14/12/2020.
//

import Foundation

struct ListResponse<T: Codable>: Codable {
    let items: [T]
    let nextPageLink: String?
    let count: Int?
    
    enum CodingKeys: String, CodingKey {
        case items
        case count
        case nextPageLink = "next_page_link"
    }
}
