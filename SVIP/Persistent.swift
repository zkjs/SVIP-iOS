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
    
    if persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) == nil {
      abort()
    }
    
    // Initialize the managed object context
    var managedObjectContext = NSManagedObjectContext()
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    
    return managedObjectContext
  }()
  
  func saveContext() {
    var error: NSError? = nil
    if let managedObjectContext = self.managedObjectContext {
      if ((managedObjectContext.hasChanges && !managedObjectContext.save(&error))) {
        abort()
      }
    }
  }
  
  class var applicationDocumentsDirectory: NSURL {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.endIndex - 1] as! NSURL
  }
  
  func deleteAllObjectsForEntityWithName(name: String) {
    println("Deleting all objects in entity \(name)")
    var fetchRequest = NSFetchRequest(entityName: name)
    fetchRequest.resultType = .ManagedObjectIDResultType
    
    if let managedObjectContext = managedObjectContext {
      var error: NSError? = nil
      let objectIDs = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
      for objectID in objectIDs! {
        managedObjectContext.deleteObject(managedObjectContext.objectWithID(objectID as! NSManagedObjectID))
      }
      saveContext()
      println("All objects in entity \(name) deleted")
    }
  }
  
  func saveMessage(chatMessage: XHMessage, shopID: String) {
    let message = NSEntityDescription.insertNewObjectForEntityForName("Message",
      inManagedObjectContext: self.managedObjectContext!) as! Message
    message.shopID = shopID
    message.avatar = NSData(data: UIImagePNGRepresentation(chatMessage.avatar))
    message.sender = chatMessage.senderName
    message.timestamp = chatMessage.timestamp
    message.sended = chatMessage.sended
    message.messageMediaType = NSNumber(integer: chatMessage.messageMediaType.rawValue)
    message.bubbleMessageType = NSNumber(integer: chatMessage.bubbleMessageType.rawValue)
    message.isRead = chatMessage.isRead
    switch chatMessage.messageMediaType.rawValue {
    case XHBubbleMessageMediaType.Photo.rawValue:
      message.photo = NSData(data: UIImagePNGRepresentation(chatMessage.photo))
    case XHBubbleMessageMediaType.Voice.rawValue:
      message.voicePath = chatMessage.voicePath
      message.voiceDuration = chatMessage.voiceDuration
    case XHBubbleMessageMediaType.Text.rawValue:
      message.text = chatMessage.textString
    default:
      break
    }
    saveContext()
  }
  
  func saveMessages(messages: NSMutableArray, shopID: String) {
    for chatMessage in NSArray(array: messages) as! [XHMessage] {
      let message = NSEntityDescription.insertNewObjectForEntityForName("Message",
        inManagedObjectContext: self.managedObjectContext!) as! Message
      message.shopID = shopID
      message.avatar = NSData(data: UIImagePNGRepresentation(chatMessage.avatar))
      message.sender = chatMessage.senderName
      message.timestamp = chatMessage.timestamp
      message.sended = chatMessage.sended
      message.messageMediaType = NSNumber(integer: chatMessage.messageMediaType.rawValue)
      message.bubbleMessageType = NSNumber(integer: chatMessage.bubbleMessageType.rawValue)
      message.isRead = chatMessage.isRead
      switch chatMessage.messageMediaType.rawValue {
      case XHBubbleMessageMediaType.Photo.rawValue:
        message.photo = NSData(data: UIImagePNGRepresentation(chatMessage.photo))
      case XHBubbleMessageMediaType.Voice.rawValue:
        message.voicePath = chatMessage.voicePath
        message.voiceDuration = chatMessage.voiceDuration
      case XHBubbleMessageMediaType.Text.rawValue:
        message.text = chatMessage.textString
      default:
        break
      }
    }
    saveContext()
  }
  
  func fetchMessagesWithShopID(shopID: String) -> NSMutableArray {
    let fetchRequest = NSFetchRequest(entityName: "Message")
    fetchRequest.predicate = NSPredicate(format: "shopID = %@", argumentArray: [shopID])
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
    var error : NSError?
    let messages = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)
    if let error = error {
      println("Something went wrong: \(error.localizedDescription)")
    }
    var chatMessages = NSMutableArray()
    for message in messages as! [Message] {
      let chatMessage = XHMessage()
      chatMessage.avatar = UIImage(data: message.avatar)
      chatMessage.sender = message.sender
      chatMessage.senderName = message.sender
      chatMessage.timestamp = message.timestamp
      chatMessage.sended = message.sended.boolValue
      chatMessage.isRead = message.isRead.boolValue
      switch message.messageMediaType.integerValue {
      case XHBubbleMessageMediaType.Photo.rawValue:
        chatMessage.photo = UIImage(data: message.photo)
        chatMessage.messageMediaType = .Photo
      case XHBubbleMessageMediaType.Voice.rawValue:
        chatMessage.voicePath = message.voicePath
        chatMessage.voiceDuration = message.voiceDuration
        chatMessage.messageMediaType = .Voice
      case XHBubbleMessageMediaType.Text.rawValue:
        chatMessage.text = message.text
        chatMessage.textString = message.text
        chatMessage.messageMediaType = .Text
      default:
        break
      }
      switch message.bubbleMessageType.integerValue {
      case XHBubbleMessageType.Receiving.rawValue:
        chatMessage.bubbleMessageType = .Receiving
      case XHBubbleMessageType.Sending.rawValue:
        chatMessage.bubbleMessageType = .Sending
      default:
        break
      }
      chatMessages.addObject(chatMessage)
    }
    return chatMessages
  }
  
  func fetchLastMessageWithShopID(shopID: String) -> XHMessage? {
    let fetchRequest = NSFetchRequest(entityName: "Message")
    fetchRequest.predicate = NSPredicate(format: "shopID = %@", argumentArray: [shopID])
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
    fetchRequest.fetchLimit = 1
    var error : NSError?
    let messages = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)
    if let error = error {
      println("Something went wrong: \(error.localizedDescription)")
    }
    
    if let message = messages?.first as? Message {
      let chatMessage = XHMessage()
      chatMessage.avatar = UIImage(data: message.avatar)
      chatMessage.sender = message.sender
      chatMessage.senderName = message.sender
      chatMessage.timestamp = message.timestamp
      chatMessage.sended = message.sended.boolValue
      chatMessage.isRead = message.isRead.boolValue
      switch message.messageMediaType.integerValue {
      case XHBubbleMessageMediaType.Photo.rawValue:
        chatMessage.photo = UIImage(data: message.photo)
        chatMessage.messageMediaType = .Photo
      case XHBubbleMessageMediaType.Voice.rawValue:
        chatMessage.voicePath = message.voicePath
        chatMessage.voiceDuration = message.voiceDuration
        chatMessage.messageMediaType = .Voice
      case XHBubbleMessageMediaType.Text.rawValue:
        chatMessage.text = message.text
        chatMessage.textString = message.text
        chatMessage.messageMediaType = .Text
      default:
        break
      }
      switch message.bubbleMessageType.integerValue {
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
