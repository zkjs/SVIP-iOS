//
//  Message.swift
//  SVIP
//
//  Created by Hanton on 7/31/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import Foundation
import CoreData

class Message: NSManagedObject {

    @NSManaged var avatar: NSData
    @NSManaged var avatarUrl: String
    @NSManaged var bubbleMessageType: Int16
    @NSManaged var isRead: Bool
    @NSManaged var messageMediaType: Int16
    @NSManaged var originPhotoUrl: String
    @NSManaged var photo: NSData
    @NSManaged var sended: Bool
    @NSManaged var sender: AnyObject
    @NSManaged var shopID: String
    @NSManaged var text: AnyObject
    @NSManaged var thumbnailUrl: String
    @NSManaged var timestamp: Int64
    @NSManaged var userID: String
    @NSManaged var voiceDuration: String
    @NSManaged var voicePath: String
    @NSManaged var voiceUrl: String

}
