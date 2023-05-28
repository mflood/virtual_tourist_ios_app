//
//  DataAccessObject.swift
//  Virtual Tourist
//
//  Created by Matthew Flood on 5/27/23.
//

import Foundation
import CoreData


class DataAccessObject {
    
    class func addNewPin(latitude: Double, longitude: Double) -> Pin? {
        
        let existingPins = findPin(latitude: latitude, longitude: longitude)
        guard existingPins.count == 0 else {
            print("Pin already exists")
            return nil
            
        }

        let context = persistentContainer.viewContext
        
        let pin = Pin(context: context)
        pin.latitude = latitude
        pin.longitude = longitude
        pin.title = "new pin"
        pin.timestamp = Date()
        pin.uuid = UUID().uuidString
        
        do {
            try context.save()
            return pin
        } catch {
            fatalError("Could not save context: \(error)")
        }
    }
    
    class func findPin(latitude: Double, longitude: Double) -> [Pin] {
        
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        let latitudeToFind: Double = latitude // your latitude
        let longitudeToFind: Double = longitude // your longitude

        // Set a predicate to find the pin with the matching coordinates
        fetchRequest.predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [latitudeToFind, longitudeToFind])

        do {
            let matchingPins = try context.fetch(fetchRequest)
            return matchingPins
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return []
    }
    
    class func findPin(uuid: String) -> [Pin] {
        
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        let uuidToFind: String = uuid

        // Set a predicate to find the pin with the matching coordinates
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", argumentArray: [uuidToFind])

        do {
            let matchingPins = try context.fetch(fetchRequest)
            return matchingPins
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return []
    }
    
    
    class func selectAllPins() -> [Pin] {
        
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let results = try! context.fetch(fetchRequest)
        
        return results
        
    }
    
    class func updatePinData(pin: Pin, result: PhotoSearchResult, callback: @escaping () -> Void) {
        
        let context = persistentContainer.viewContext
        
        pin.flickr_download_page_number = result.photos.page
        pin.flickr_per_page = result.photos.perPage
        pin.flickr_num_pages = result.photos.pages
        pin.flickr_total_photos = result.photos.total
        
        do {
            try context.save()
        } catch {
            fatalError("Could not save context: \(error)")
        }
        
        deletePhotosForPin(pin: pin)
        
        for photo in result.photos.photo {
            addPhoto(pin: pin, searchResultPhoto: photo)
        }
        
        callback()
    }
    
    
    class func addPhoto(pin: Pin, searchResultPhoto: SearchResultPhoto) {
        
        let context = persistentContainer.viewContext
        
        let photo = Photo(context: context)
        
        photo.flickr_id = searchResultPhoto.id
        photo.flickr_farm = searchResultPhoto.farm
        photo.flickr_owner = searchResultPhoto.owner
        photo.flickr_title = searchResultPhoto.title
        photo.flickr_secret = searchResultPhoto.secret
        photo.flickr_server = searchResultPhoto.server
        photo.timestamp = Date()
        
        pin.addToPhotos(photo)

        do {
            try context.save()
        } catch {
            fatalError("Could not save context: \(error)")
        }
    }
    
    
    
    class func deletePhotosForPin(pin: Pin) {
        let context = persistentContainer.viewContext
       
       // if let photos = pin.photos? as? [Photo] {
       //     // Iterate over each photo and delete it
       //     for photo in photos {
       //         context.delete(photo)
       //     }
       //  }
    }
    
    
    class func deleteAllPins() {

        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(batchDeleteRequest)
            try context.save()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }

    }
}



