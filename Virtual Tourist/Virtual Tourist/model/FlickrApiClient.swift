//
//  FlickrFileDownloader.swift
//  Virtual Tourist
//
//  Created by Matthew Flood on 5/14/23.
//

import Foundation
import UIKit

struct FlickrPhotoRequest{
    let farm: String
    let server: String
    let id: String
    let secret: String
}

class FlickrApiClient {
    
    static var FlickrApiKey: String = API_KEY
    static var searchRadiusKm: Int32 = 5
    
    
    enum Endpoint {
        
        // https://www.flickr.com/services/api/flickr.photos.search.html
        case search(Double, Double, Int32) // lat, lon, page
        case photo(FlickrPhotoRequest)
        
        var url: URL {
            switch self {
            case let .photo(photo):
                let stringValue = "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
                
                return URL(string: stringValue)!
                
            case let .search(lat, lon, page):

                let baseUrl = "https://api.flickr.com/services/rest/"
                let queryItems = [
                    URLQueryItem(name: "method", value: "flickr.photos.search"),
                    URLQueryItem(name: "api_key", value: FlickrApiClient.FlickrApiKey),
                    // URLQueryItem(name: "text", value: text),
                    URLQueryItem(name: "lat", value: "\(lat)"),
                    URLQueryItem(name: "lon", value: "\(lon)"),

                    URLQueryItem(name: "radius", value: "0.2"),
                    URLQueryItem(name: "radius_units", value: "km"),
                    URLQueryItem(name: "page", value: "\(page)"),
                    URLQueryItem(name: "media", value: "photos"), // default photos and videos
                    URLQueryItem(name: "format", value: "json"),
                    URLQueryItem(name: "nojsoncallback", value: "1"),
                    URLQueryItem(name: "per_page", value: "75") // default 100
                    
                ]
                var components = URLComponents(string: baseUrl)!
                components.queryItems = queryItems
                return components.url!
            }
        }
    }
    
    class func downloadPhoto(photoRequest: FlickrPhotoRequest, callback: @escaping (_ photoRequest: FlickrPhotoRequest, _ imageData: Data?, _ errorString: String?) -> Void)
    {
        
        let request = URLRequest(url: FlickrApiClient.Endpoint.photo(photoRequest).url)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            // nothing
            
            if let error = error {
                DispatchQueue.main.async {
                    callback(photoRequest, nil, error.localizedDescription)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    callback(photoRequest, nil, "no data returned")
                }
                return
            }
            
            DispatchQueue.main.async {
                callback(photoRequest, data, nil)
            }
        }
        task.resume()
    }
    
    class func searchPhotos(lat: Double, lon: Double, page: Int32, callback: @escaping (_ photoSearchResult: PhotoSearchResult?, _ errorString: String?) -> Void) {
        
        let request = URLRequest(url: FlickrApiClient.Endpoint.search(lat, lon, page).url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            
            if error != nil { // Handle error…
                DispatchQueue.main.async {
                    if let errorMessage = error?.localizedDescription {
                        callback(nil, errorMessage)
                    } else {
                        callback(nil, "unknown error searching")
                    }
                    
                }
                return
            }
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    callback(nil, "Could not get data from response")
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            
            do {
                var response: PhotoSearchResult
                response = try decoder.decode(PhotoSearchResult.self, from: data)
                
                DispatchQueue.main.async {
                    callback(response, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    callback(nil, "error searching photos")
                }
            }
        }
        task.resume()
    }
}
