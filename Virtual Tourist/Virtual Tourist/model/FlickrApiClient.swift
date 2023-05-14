//
//  FlickrFileDownloader.swift
//  Virtual Tourist
//
//  Created by Matthew Flood on 5/14/23.
//

import Foundation
import UIKit

class FlickrApiClient {
    
    static var FlickrApiKey: String! = nil
    static var searchRadiusKm: Int32 = 5
    
    
    enum Endpoint {
        
        case search(Double, Double)
        case photo(SearchResultPhoto)
        
        var url: URL {
            switch self {
            case let .photo(photo):
                let stringValue = "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
                
                return URL(string: stringValue)!
                
            case let .search(lat, lon):
                
                let baseUrl = "https://api.flickr.com/services/rest/"
                let queryItems = [
                    URLQueryItem(name: "method", value: "flickr.photos.search"),
                    URLQueryItem(name: "api_key", value: FlickrApiClient.FlickrApiKey!),
                    // URLQueryItem(name: "text", value: text),
                    URLQueryItem(name: "radius", value: "20"),
                    URLQueryItem(name: "radius_units", value: "km"),
                    URLQueryItem(name: "lat", value: "\(lat)"),
                    URLQueryItem(name: "lon", value: "\(lon)"),
                    URLQueryItem(name: "format", value: "json"),
                    URLQueryItem(name: "nojsoncallback", value: "1")
                ]
                var components = URLComponents(string: baseUrl)!
                components.queryItems = queryItems
                return components.url!
            }
        }
    }
    
    class func searchPhotos(lat: Double, lon: Double, callback: @escaping (_ photoSearchResult: PhotoSearchResult?, _ errorString: String?) -> Void) {
        
        let request = URLRequest(url: FlickrApiClient.Endpoint.search(lat, lon).url)
        let session = URLSession.shared
        
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                callback(nil, error?.localizedDescription)
                return
            }
            
            guard let data = data, error == nil else {
                callback(nil, "Could not get data from response")
                return
            }
            
            let decoder = JSONDecoder()
            var response: PhotoSearchResult
            
            do {
                response = try decoder.decode(PhotoSearchResult.self, from: data)
                
                DispatchQueue.main.async {
                    callback(response, nil)
                }
            } catch {
                callback(nil, "\(error)")
            }
        }
        task.resume()
    }
}
