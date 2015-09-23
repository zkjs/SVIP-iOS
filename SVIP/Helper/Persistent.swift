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
  
  func saveMessage(chatMessage: XHMessage, shopID: String) {
    let message = NSEntityDescription.insertNewObjectForEntityForName("Message",
      inManagedObjectContext: self.managedObjectContext!) as! Message
    message.userID = JSHAccountManager.sharedJSHAccountManager().userid
    message.shopID = shopID
    message.avatar = NSData(data: UIImageJPEGRepresentation(chatMessage.avatar, 1)!)
    message.sender = chatMessage.senderName
    message.timestamp = Int64(chatMessage.timestamp.timeIntervalSince1970)
    message.sended = chatMessage.sended
    message.messageMediaType = Int16(chatMessage.messageMediaType.rawValue)
    message.bubbleMessageType = Int16(chatMessage.bubbleMessageType.rawValue)
    message.isRead = chatMessage.isRead
    switch chatMessage.messageMediaType.rawValue {
    case XHBubbleMessageMediaType.Photo.rawValue:
//      message.photo = NSData(data: UIImageJPEGRepresentation(chatMessage.photo, 1)!)
      message.originPhotoUrl = chatMessage.originPhotoUrl
      message.thumbnailUrl = chatMessage.thumbnailUrl
    case XHBubbleMessageMediaType.Voice.rawValue:
      message.voicePath = chatMessage.voicePath
      message.voiceDuration = chatMessage.voiceDuration
    case XHBubbleMessageMediaType.Text.rawValue:
      message.text = chatMessage.textString
    case XHBubbleMessageMediaType.Card.rawValue:
      message.cardTitle = chatMessage.cardTitle
      message.cardImage = NSData(data: UIImageJPEGRepresentation(chatMessage.cardImage, 0.8)!)
      message.cardContent = chatMessage.cardContent
    default:
      break
    }
    saveContext()
  }
  
  func fetchMessagesWithShopID(shopID: String, userID: String, beforeTimeStamp: NSDate) -> NSMutableArray {
    let fetchRequest = NSFetchRequest(entityName: "Message")
    fetchRequest.predicate = NSPredicate(format: "shopID = %@ && userID = %@ && timestamp < %lld", argumentArray: [shopID, userID, beforeTimeStamp.timeIntervalSince1970])
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
    fetchRequest.fetchLimit = 7
    var error : NSError?
    let messages: [AnyObject]?
    do {
      messages = try self.managedObjectContext!.executeFetchRequest(fetchRequest)
    } catch let error1 as NSError {
      error = error1
      messages = nil
    }
    if let error = error {
      print("Something went wrong: \(error.localizedDescription)")
    }
    let chatMessages = NSMutableArray()
    for message in messages as! [Message] {
      let chatMessage = XHMessage()
      chatMessage.avatar = UIImage(data: message.avatar)
      chatMessage.sender = message.sender as! String
      chatMessage.senderName = message.sender as! String
      chatMessage.timestamp = NSDate(timeIntervalSince1970: NSTimeInterval(message.timestamp))
      chatMessage.sended = message.sended.boolValue
      chatMessage.isRead = message.isRead.boolValue
      switch Int(message.messageMediaType) {
      case XHBubbleMessageMediaType.Photo.rawValue:
        chatMessage.photo = UIImage(data: message.photo)
        chatMessage.originPhotoUrl = message.originPhotoUrl
        chatMessage.thumbnailUrl = message.thumbnailUrl
        chatMessage.messageMediaType = .Photo
      case XHBubbleMessageMediaType.Voice.rawValue:
        chatMessage.voicePath = message.voicePath
        chatMessage.voiceDuration = message.voiceDuration
        chatMessage.messageMediaType = .Voice
      case XHBubbleMessageMediaType.Text.rawValue:
        chatMessage.text = message.text as! String
        chatMessage.textString = message.text as! String
        chatMessage.messageMediaType = .Text
      case XHBubbleMessageMediaType.Card.rawValue:
        chatMessage.cardTitle = message.cardTitle as String
        chatMessage.cardImage = UIImage(data: message.cardImage)
        chatMessage.cardContent = message.cardContent as String
        chatMessage.messageMediaType = .Card
      default:
        break
      }
      switch Int(message.bubbleMessageType) {
      case XHBubbleMessageType.Receiving.rawValue:
        chatMessage.bubbleMessageType = .Receiving
      case XHBubbleMessageType.Sending.rawValue:
        chatMessage.bubbleMessageType = .Sending
      default:
        break
      }
      chatMessages.addObject(chatMessage)
    }
    let sort = NSSortDescriptor(key: "timestamp", ascending: true)
    chatMessages.sortUsingDescriptors([sort])
    return chatMessages
  }
  
  func fetchLastMessageWithShopID(shopID: String, userID: String) -> XHMessage? {
    let fetchRequest = NSFetchRequest(entityName: "Message")
    fetchRequest.predicate = NSPredicate(format: "shopID = %@ && userID = %@", argumentArray: [shopID, userID])
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
    fetchRequest.fetchLimit = 1
    var error : NSError?
    let messages: [AnyObject]?
    do {
      messages = try self.managedObjectContext!.executeFetchRequest(fetchRequest)
    } catch let error1 as NSError {
      error = error1
      messages = nil
    }
    if let error = error {
      print("Something went wrong: \(error.localizedDescription)")
    }
    
    if let message = messages?.first as? Message {
      let chatMessage = XHMessage()
      chatMessage.avatar = UIImage(data: message.avatar)
      chatMessage.sender = message.sender as! String
      chatMessage.senderName = message.sender as! String
      chatMessage.timestamp = NSDate(timeIntervalSince1970: NSTimeInterval(message.timestamp))
      chatMessage.sended = message.sended.boolValue
      chatMessage.isRead = message.isRead.boolValue
      switch Int(message.messageMediaType) {
      case XHBubbleMessageMediaType.Photo.rawValue:
        chatMessage.photo = UIImage(data: message.photo)
        chatMessage.messageMediaType = .Photo
      case XHBubbleMessageMediaType.Voice.rawValue:
        chatMessage.voicePath = message.voicePath
        chatMessage.voiceDuration = message.voiceDuration
        chatMessage.messageMediaType = .Voice
      case XHBubbleMessageMediaType.Text.rawValue:
        chatMessage.text = message.text as! String
        chatMessage.textString = message.text as! String
        chatMessage.messageMediaType = .Text
      case XHBubbleMessageMediaType.Card.rawValue:
        chatMessage.cardTitle = message.cardTitle as String
        chatMessage.cardImage = UIImage(data: message.cardImage)
        chatMessage.cardContent = message.cardContent as String
        chatMessage.messageMediaType = .Card
      default:
        break
      }
      switch Int(message.bubbleMessageType) {
      case XHBubbleMessageType.Receiving.rawValue:
        chatMessage.bubbleMessageType = .Receiving
      case XHBubbleMessageType.Sending.rawValue:
        chatMessage.bubbleMessageType = .Sending
      default:
        break
      }
      return chatMessage
    }
    return nil
  }
  
}
