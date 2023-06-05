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
    
}
