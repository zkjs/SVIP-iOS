//
//  SettingTVC.swift
//  SVIP
//
//  Created by  on 12/14/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class SettingTVC: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "设置"
    
    tableView.tableFooterView = UIView()
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

}
