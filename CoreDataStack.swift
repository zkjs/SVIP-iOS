//
//  CoreDataStack.swift
//  SVIP
//
//  Created by Qin Yejun on 3/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
  static let moduleName = "SVIP"
  static let sharedInstance = CoreDataStack()
  let context:NSManagedObjectContext
  let psc:NSPersistentStoreCoordinator
  let model:NSManagedObjectModel
  let store:NSPersistentStore?
  
  private init() {
    //1
    let bundle = NSBundle.mainBundle()
    let modelURL = bundle.URLForResource(CoreDataStack.moduleName, withExtension:"momd")
    model = NSManagedObjectModel(contentsOfURL: modelURL!)!
    
    //2
    psc = NSPersistentStoreCoordinator(managedObjectModel:model)
    
    //3
    context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    context.persistentStoreCoordinator = psc
    
    //4
    let documentsURL = CoreDataStack.applicationDocumentsDirectory()
    
    let storeURL = documentsURL.URLByAppendingPathComponent("\(CoreDataStack.moduleName).sqlite")
    
    let options = [NSMigratePersistentStoresAutomaticallyOption: true,
      NSInferMappingModelAutomaticallyOption: true]
    
    var error: NSError? = nil
    do {
      store = try psc.addPersistentStoreWithType(NSSQLiteStoreType,
        configuration: nil,
        URL: storeURL,
        options: options)
    } catch let error1 as NSError {
      error = error1
      store = nil
    }
    
    if store == nil {
      print("Error adding persistent store: \(error)")
      abort()
    }
  }
  
  func saveContext() {
    var error: NSError? = nil
    if context.hasChanges {
      do {
        try context.save()
      } catch let error1 as NSError {
        error = error1
        print("Could not save: \(error), \(error?.userInfo)")
      }
    }
  }
  
  class func applicationDocumentsDirectory() -> NSURL {
    let fileManager = NSFileManager.defaultManager()
    
    let urls = fileManager.URLsForDirectory(.DocumentDirectory,
      inDomains: .UserDomainMask)
    
    return urls[0]
  }
}