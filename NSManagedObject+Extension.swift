//
//  NSManagedObject+Extension.swift
//  SVIP
//
//  Created by Qin Yejun on 3/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
  static func create() -> NSManagedObject {
    return self.createInContext(CoreDataStack.sharedInstance.context)
  }
  
  static func createInContext(context: NSManagedObjectContext) -> NSManagedObject {
    return NSEntityDescription.insertNewObjectForEntityForName(self.entityName(), inManagedObjectContext: context)
  }
  
  static func entityName() -> String {
    return NSStringFromClass(self).componentsSeparatedByString(".").last!
  }
  
  class func all() -> [AnyObject] {
    return self.allInContext(CoreDataStack.sharedInstance.context)
  }
  
  class func allWithOrder(order: AnyObject) -> [AnyObject] {
    return self.allInContext(CoreDataStack.sharedInstance.context, order: order)
  }
  
  class func allInContext(context: NSManagedObjectContext) -> [AnyObject] {
    return self.allInContext(context, order: nil)
  }
  
  class func allInContext(context: NSManagedObjectContext, order: AnyObject?) -> [AnyObject] {
    return self.fetchWithCondition(nil, inContext: context, withOrder: order, fetchLimit: nil)
  }
  
  static func query(condition: AnyObject) -> [AnyObject] {
    return self.query(condition, inContext: CoreDataStack.sharedInstance.context, order: nil, limit: nil)
  }
  
  static func query(condition: AnyObject, inContext context: NSManagedObjectContext, order: AnyObject) -> [AnyObject] {
    return self.query(condition, inContext: context, order: order, limit: nil)
  }
  
  static func query(condition: AnyObject, inContext context: NSManagedObjectContext, order: AnyObject?, limit: Int?) -> [AnyObject] {
    return self.fetchWithCondition(condition, inContext: context, withOrder: order, fetchLimit: limit)
  }
  
  static func createFetchRequestInContext(context: NSManagedObjectContext) -> NSFetchRequest {
    let request: NSFetchRequest = NSFetchRequest()
    let entity: NSEntityDescription = NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: context)!
    request.entity = entity
    return request
  }
  
  static func predicateFromObject(condition: AnyObject) -> NSPredicate? {
    return self.predicateFromObject(condition,arguments: [])
  }
  
  class func predicateFromDictionary(dict: [String : String]) -> NSPredicate {
    //        var subpredicates: [AnyObject] = dict.map({(key: String, value: AnyObject) -> Void in
    ////            return NSPredicate.predicateWithFormat("%K = %@", key, value)
    //            return NSPredicate(format: "\(key) = \(value)")
    //        })
    let subpredicates = dict.map { (key, value) -> NSPredicate in
      return NSPredicate(format: "\(key) = \(value)")
    }
    return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
  }
  
  class func predicateFromObject(condition: AnyObject, arguments: AnyObject...) -> NSPredicate? {
    if let condition = condition as? NSPredicate{
      return condition
    }
    if let condition = condition as? String {
      return NSPredicate(format: condition)
    }
    if let condition = condition as? [String:String] {
      return self.predicateFromDictionary(condition)
    }
    return nil
  }
  
  static func fetchWithCondition(condition: AnyObject?, inContext context: NSManagedObjectContext, withOrder order: AnyObject?, fetchLimit: Int?) -> [AnyObject] {
    let request: NSFetchRequest = self.createFetchRequestInContext(context)
    if let condition = condition {
      request.predicate = self.predicateFromObject(condition)
    }
    if let order = order {
      request.sortDescriptors = self.sortDescriptorsFromObject(order)
    }
    if let fetchLimit = fetchLimit {
      request.fetchLimit = fetchLimit
    }
    do {
      return try context.executeFetchRequest(request)
    } catch {
      return []
    }
  }
  
  class func sortDescriptorFromDictionary(dict: [String : String]) -> NSSortDescriptor {
    let isAscending = dict.values.first?.uppercaseString == "ASC"
    return NSSortDescriptor(key: dict.keys.first, ascending: isAscending)
  }
  
  class func sortDescriptorFromString(order: String) -> NSSortDescriptor? {
    var components = order.componentsSeparatedByCharactersInSet(.whitespaceAndNewlineCharacterSet())
    guard let key = components.first else {
      return nil
    }
    let value: String = components.count > 1 ? components[1] : "ASC"
    return self.sortDescriptorFromDictionary([key: value])
  }
  
  class func sortDescriptorFromObject(order: AnyObject) -> NSSortDescriptor? {
    if let order = order as? NSSortDescriptor {
      return order
    }
    if let order = order as? String {
      return self.sortDescriptorFromString(order)
    }
    if let order = order as? [String : String] {
      return self.sortDescriptorFromDictionary(order)
    }
    return nil
  }
  
  class func sortDescriptorsFromObject(order: AnyObject) -> [NSSortDescriptor] {
    if let order = order as? String {
      //order = order.componentsSeparatedByString(",")
      self.sortDescriptorFromString(order)
    }
    if let order = order as? [String:String] {
      return [self.sortDescriptorFromDictionary(order)]
    }
    if let order = order as? [[String:String]] {
      return order.map{ self.sortDescriptorFromDictionary($0)}
    }
    return []
  }
  
  // **********************************************************************
  
  func save () -> Bool {
    return self.saveTheContext()
  }
  
  func saveTheContext () -> Bool {
    if (self.managedObjectContext == nil || !self.managedObjectContext!.hasChanges) {
      return true
    }
    do {
      try self.managedObjectContext?.save()
    } catch {
      return false
    }
    
    return true
  }
  
  func remove() {
    self.managedObjectContext?.deleteObject(self)
  }
}