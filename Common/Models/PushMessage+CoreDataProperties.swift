//
//  PushMessage+CoreDataProperties.swift
//  
//
//  Created by Qin Yejun on 6/25/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PushMessage {

    @NSManaged var alert: String?
    @NSManaged var content: String?
    @NSManaged var imgUrl: String?
    @NSManaged var link: String?
    @NSManaged var linkTitle: String?
    @NSManaged var locid: String?
    @NSManaged var shopid: String?
    @NSManaged var timestamp: NSDate
    @NSManaged var title: String?
    @NSManaged var userid: String?
    @NSManaged var read: NSNumber?

}
