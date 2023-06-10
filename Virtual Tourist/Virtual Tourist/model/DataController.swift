//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Matthew Flood on 6/4/23.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)?) {
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Could not load persistent store: \(error)")
            }
        })
    }
    
    func addNewPin(latitude: Double, longitude: Double) -> Pin? {
        
        let existingPins = findPin(latitude: latitude, longitude: longitude)
        
        guard existingPins.count == 0 else {
            print("Pin already exists")
            return nil
        }
        
        let pin = Pin(context: viewContext)
        pin.hasDownloaded = false
        pin.latitude = latitude
        pin.longitude = longitude
        pin.title = "new pin"
        pin.timestamp = Date()
        pin.uuid = UUID().uuidString
        
        do {
            try viewContext.save()
            return pin
        } catch {
            fatalError("Could not save context: \(error)")
        }
    }
    
    func findPin(latitude: Double, longitude: Double) -> [Pin] {
        
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        let latitudeToFind: Double = latitude // your latitude
        let longitudeToFind: Double = longitude // your longitude

        // Set a predicate to find the pin with the matching coordinates
        fetchRequest.predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [latitudeToFind, longitudeToFind])

        do {
            let matchingPins = try viewContext.fetch(fetchRequest)
            return matchingPins
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return []
    }
    
    func setPhotoImageData(id: String, imageData: Data) {
       
        
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        let idToFind: String = id

        // Set a predicate to find the pin with the matching coordinates
        fetchRequest.predicate = NSPredicate(format: "flickr_id == %@", argumentArray: [idToFind])

        do {
            let matchingPhotos = try viewContext.fetch(fetchRequest)
            matchingPhotos.forEach( {photo in
                photo.imageData = imageData
            })

            try viewContext.save()
                                    
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func deletePhotoById(id: String) {
       
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        let idToFind: String = id

        // Set a predicate to find the pin with the matching coordinates
        fetchRequest.predicate = NSPredicate(format: "flickr_id == %@", argumentArray: [idToFind])

        do {
            let matchingPhotos = try viewContext.fetch(fetchRequest)
            for photo in matchingPhotos {
                viewContext.delete(photo)
            }
            try viewContext.save()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    func findPhotoById(id: String) -> Photo? {
        
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        let idToFind: String = id

        // Set a predicate to find the pin with the matching coordinates
        fetchRequest.predicate = NSPredicate(format: "flickr_id == %@", argumentArray: [idToFind])

        do {
            let matchingPhotos = try viewContext.fetch(fetchRequest)
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
    
    func findPin(uuid: String) -> Pin? {
        
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")

        // Set a predicate to find the pin with the matching coordinates
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", argumentArray: [uuid])

        do {
            let matchingPins = try viewContext.fetch(fetchRequest)
            if matchingPins.count > 0 {
                return matchingPins[0]
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    
    func selectAllPins() -> [Pin] {
        
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let results = try! viewContext.fetch(fetchRequest)
        
        return results
        
    }
    
    func updatePinData(pinUuid: String, result: PhotoSearchResult, callback: @escaping () -> Void) {
        
        guard let pin = findPin(uuid: pinUuid) else {
            return
        }
            
        pin.flickr_download_page_number = result.photos.page
        pin.flickr_per_page = result.photos.perPage
        pin.flickr_num_pages = result.photos.pages
        pin.flickr_total_photos = result.photos.total
        pin.hasDownloaded = true
        
        for photo in result.photos.photo {
            addPhoto(pin: pin, searchResultPhoto: photo)
        }
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Could not save context: \(error)")
        }
        
        callback()
    }
    
    
    func addPhoto(pin: Pin, searchResultPhoto: SearchResultPhoto) {
        
        print("adding photo: \(searchResultPhoto)")
        let photo = Photo(context: viewContext)
        
        photo.flickr_id = searchResultPhoto.id
        photo.flickr_farm = searchResultPhoto.farm
        photo.flickr_owner = searchResultPhoto.owner
        photo.flickr_title = searchResultPhoto.title
        photo.flickr_secret = searchResultPhoto.secret
        photo.flickr_server = searchResultPhoto.server
        photo.timestamp = Date()
        
        pin.addToPhotos(photo)

    }
    
    func deletePhotos(forPinUuid pinUuid: String) {

        guard let pin = findPin(uuid: pinUuid) else {
            return
        }

        if let photos = pin.photos {
            photos.forEach {(photoObject) in
    
                if let photo = photoObject as? Photo {
                    // pin.removeFromPhotos(photo)
                    viewContext.delete(photo)
                } else {
                    print("Photo was not there??")
                }
            }
        }
        
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Could not save context. \(error), \(error.userInfo)")
        }
        
    }
    
    
    func deleteAllPins() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try viewContext.execute(batchDeleteRequest)
            try viewContext.save()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
}



// Define the Core Data stack
var deprecatedDersistentContainer: NSPersistentContainer = {
    
    let container = NSPersistentContainer(name: "Virtual_Tourist")
    
    // Load the persistent store
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error {
            fatalError("Could not load persistent store: \(error)")
        }
    })
    
    return container
}()

