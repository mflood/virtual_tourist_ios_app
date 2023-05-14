//
//  FlickrSchema.swift
//  Virtual Tourist
//
//  Created by Matthew Flood on 5/14/23.
//

import Foundation
import UIKit

struct SearchResultPhoto: Codable {
    var id: String
    var owner: String
    var secret: String
    var server: String
    var farm: Int32
    var title: String
    var isPublic: Int32
    var isFriend: Int32
    var isFamily: Int32
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
    
}

struct SearchResultPhotoPage: Codable {
    var page: Int32
    var pages: Int32
    var perPage: Int32
    var total: Int32
    var photo: [SearchResultPhoto]
    
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photo
    }
}

struct PhotoSearchResult: Codable  {
    var stat: String
    var photos: SearchResultPhotoPage
}
