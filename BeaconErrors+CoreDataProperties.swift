//
//  BeaconErrors+CoreDataProperties.swift
//  SVIP
//
//  Created by Qin Yejun on 3/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BeaconErrors {

    @NSManaged var uuid: String?
    @NSManaged var major: String?
    @NSManaged var minor: String?
    @NSManaged var timestamp: NSDate?
    @NSManaged var error: String?
    @NSManaged var connectionType: String?

}
