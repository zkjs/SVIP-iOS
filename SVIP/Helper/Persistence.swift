//
//  Persistence.swift
//  SVIP
//
//  Created by Hanton on 7/19/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import Foundation
import CoreData

class Persistence: NSObject {
  
  class func sharedInstance() -> Persistence {
    struct Singleton {
      static let instance = Persistence()
    }
    return Singleton.instance
  }
  
  var managedObjectContext: NSManagedObjectContext? = {
    // Initialize the managed object model
    let modelURL = NSBundle.mainBundle().URLForResource("SVIP", withExtension: "momd")
    let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
    
    // Initialize the persistent store coordinator
    let storeURL = Persistence.applicationDocumentsDirectory.URLByAppendingPathComponent("SVIP.sqlite")
    var error: NSError? = nil
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
    
    do {
      try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
    } catch var error1 as NSError {
      error = error1
      abort()
    } catch {
      fatalError()
    }
    
    // Initialize the managed object context
    var managedObjectContext = NSManagedObjectContext()
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    
    return managedObjectContext
  }()
  
  func saveContext() {
    if let managedObjectContext = self.managedObjectContext {
      if (managedObjectContext.hasChanges) {
        do {
          try managedObjectContext.save()
        } catch {
          abort()
        }
      }
    }
  }
  
  class var applicationDocumentsDirectory: NSURL {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.endIndex - 1] 
  }
  
  func deleteAllObjectsForEntityWithName(name: String) {
    print("Deleting all objects in entity \(name)")
    let fetchRequest = NSFetchRequest(entityName: name)
    fetchRequest.resultType = .ManagedObjectIDResultType
    
    if let managedObjectContext = managedObjectContext {
      let objectIDs: [AnyObject]?
      do {
        objectIDs = try managedObjectContext.executeFetchRequest(fetchRequest)
      } catch {
        objectIDs = nil
      }
      for objectID in objectIDs! {
        managedObjectContext.deleteObject(managedObjectContext.objectWithID(objectID as! NSManagedObjectID))
      }
      saveContext()
      print("All objects in entity \(name) deleted")
    }
  }
  
}
