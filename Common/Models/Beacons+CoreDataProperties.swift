//
//  Beacons+CoreDataProperties.swift
//  SVIP
//
//  Created by Qin Yejun on 4/19/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Beacons {

    @NSManaged var accuracy: NSNumber
    @NSManaged var rssi: NSNumber
    @NSManaged var major: String
    @NSManaged var minor: String
    @NSManaged var timestamp: NSDate
    @NSManaged var uuid: String
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var altitude: NSNumber?

}
