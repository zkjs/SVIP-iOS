//
//  RegionComment.swift
//  
//
//  Created by Qin Yejun on 5/7/16.
//
//

import Foundation
import CoreData


class RegionComment: NSManagedObject {

  static func commentsForRegion(locid:Int) -> [RegionComment] {
    if let comments = RegionComment.query("locid == \(locid)", order: ["timestamp":"DESC"], limit: nil) as? [RegionComment] {
      return comments
    }
    return []
  }

}
