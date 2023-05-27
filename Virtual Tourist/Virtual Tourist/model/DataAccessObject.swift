//
//  DataAccessObject.swift
//  Virtual Tourist
//
//  Created by Matthew Flood on 5/27/23.
//

import Foundation
import CoreData


class DataAccessObject {
    
    class func addNewPin(latitude: Double, longitude: Double) -> Bool {
        
        let existingPins = findPin(latitude: latitude, longitude: longitude)
        guard existingPins.count == 0 else {
            print("Pin already exists")
            return false
            
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
            return true
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
    
    class func selectAllPins() -> [Pin] {
        
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let results = try! context.fetch(fetchRequest)
        
        return results
        
    }
    
    class func deleteAllPins() {

        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(batchDeleteRequest)
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }

    }
}



