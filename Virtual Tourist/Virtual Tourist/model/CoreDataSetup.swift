//
//  CoreDataSetup.swift
//  Virtual Tourist
//
//  Created by Matthew Flood on 5/27/23.
//

import Foundation
import CoreData

// Define the Core Data stack
var persistentContainer: NSPersistentContainer = {
    
    
   
    
    let container = NSPersistentContainer(name: "Virtual_Tourist")
    
    // Load the persistent store
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error {
            fatalError("Could not load persistent store: \(error)")
        }
    })
    
    return container
}()
