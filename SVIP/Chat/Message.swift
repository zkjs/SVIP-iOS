//
//  Message.swift
//  SVIP
//
//  Created by Hanton on 7/20/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import Foundation
import CoreData

class Message: NSManagedObject {

    @NSManaged var avatar: NSData
    @NSManaged var avatarUrl: String
    @NSManaged var bubbleMessageType: NSNumber
    @NSManaged var isRead: NSNumber
    @NSManaged var messageMediaType: NSNumber
    @NSManaged var originPhotoUrl: String
    @NSManaged var photo: NSData
    @NSManaged var sended: NSNumber
    @NSManaged var sender: String
    @NSManaged var text: String
    @NSManaged var thumbnailUrl: String
    @NSManaged var timestamp: NSDate
    @NSManaged var voiceDuration: String
    @NSManaged var voicePath: String
    @NSManaged var voiceUrl: String
    @NSManaged var shopID: String

}
