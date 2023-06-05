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
        pin.hasDownloaded = false
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
    
    class func setPhotoImageData(id: String, imageData: Data) {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        let idToFind: String = id

        // Set a predicate to find the pin with the matching coordinates
        fetchRequest.predicate = NSPredicate(format: "flickr_id == %@", argumentArray: [idToFind])

        do {
            let matchingPhotos = try context.fetch(fetchRequest)
            matchingPhotos.forEach( {photo in
                photo.imageData = imageData
            })

            try context.save()
                                    
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    class func deletePhotoById(id: String) {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        let idToFind: String = id

        // Set a predicate to find the pin with the matching coordinates
        fetchRequest.predicate = NSPredicate(format: "flickr_id == %@", argumentArray: [idToFind])

        do {
            let matchingPhotos = try context.fetch(fetchRequest)
            for photo in matchingPhotos {
                context.delete(photo)
            }
            try context.save()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    class func findPhotoById(id: String) -> Photo? {
        
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        let idToFind: String = id

        // Set a predicate to find the pin with the matching coordinates
        fetchRequest.predicate = NSPredicate(format: "flickr_id == %@", argumentArray: [idToFind])

        do {
            let matchingPhotos = try context.fetch(fetchRequest)
            if matchingPhotos.count > 0 {
                return matchingPhotos[0]
            } else {
                return nil
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    class func findPin(uuid: String, context: NSManagedObjectContext) -> Pin? {
        
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")

        // Set a predicate to find the pin with the matching coordinates
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", argumentArray: [uuid])

        do {
            let matchingPins = try context.fetch(fetchRequest)
            if matchingPins.count > 0 {
                return matchingPins[0]
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    
    class func selectAllPins() -> [Pin] {
        
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let results = try! context.fetch(fetchRequest)
        
        return results
        
    }
    
    class func updatePinData(pinUuid: String, result: PhotoSearchResult, callback: @escaping () -> Void) {
        
        let context = persistentContainer.viewContext
        
        guard let pin = findPin(uuid: pinUuid, context: context) else {
            return
        }
            
        pin.flickr_download_page_number = result.photos.page
        pin.flickr_per_page = result.photos.perPage
        pin.flickr_num_pages = result.photos.pages
        pin.flickr_total_photos = result.photos.total
        pin.hasDownloaded = true
        
        for photo in result.photos.photo {
            addPhoto(pin: pin, searchResultPhoto: photo, context: context)
        }
        
        do {
            try context.save()
        } catch {
            fatalError("Could not save context: \(error)")
        }
        
        callback()
    }
    
    
    class func addPhoto(pin: Pin, searchResultPhoto: SearchResultPhoto, context: NSManagedObjectContext) {
        
        print("adding photo: \(searchResultPhoto)")
        let photo = Photo(context: context)
        
        photo.flickr_id = searchResultPhoto.id
        photo.flickr_farm = searchResultPhoto.farm
        photo.flickr_owner = searchResultPhoto.owner
        photo.flickr_title = searchResultPhoto.title
        photo.flickr_secret = searchResultPhoto.secret
        photo.flickr_server = searchResultPhoto.server
        photo.timestamp = Date()
        
        pin.addToPhotos(photo)

    }
    
    class func deletePhotos(forPinUuid pinUuid: String) {
        let context = persistentContainer.viewContext
    
        guard let pin = findPin(uuid: pinUuid, context: context) else {
            return
        }

        if let photos = pin.photos {
            photos.forEach {(photoObject) in
    
                if let photo = photoObject as? Photo {
                    // pin.removeFromPhotos(photo)
                    context.delete(photo)
                } else {
                    print("Photo was not there??")
                }
            }
        }
        
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save context. \(error), \(error.userInfo)")
        }
        
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



