//
//  RegionComment+CoreDataProperties.swift
//  
//
//  Created by Qin Yejun on 5/7/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension RegionComment {

    @NSManaged var avatarUrl: String?
    @NSManaged var userID: String?
    @NSManaged var userName: String?
    @NSManaged var content: String?
    @NSManaged var timestamp: NSDate?
    @NSManaged var locid: NSNumber?

}
