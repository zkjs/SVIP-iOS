//
//  MeTVC.swift
//  SVIP
//
//  Created by  on 12/14/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class MeTVC: UITableViewController {
  
  @IBOutlet weak var userImage: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBarHidden = true
    setupUI()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.navigationBarHidden = false
  }
  
  func setupUI() {
    userImage.image = AccountManager.sharedInstance().avatarImage
    usernameLabel.text = AccountManager.sharedInstance().userName
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let accountIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    let orderIndexPath = NSIndexPath(forRow: 1, inSection: 0)
    let settingIndexPath = NSIndexPath(forRow: 2, inSection: 0)
    
    switch indexPath {
    case accountIndexPath:
      let storyboard = UIStoryboard(name: "AccountTVC", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("AccountTVC") as! AccountTVC
      vc.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(vc, animated: true)
    case orderIndexPath:
      let vc = OrderListTVC()
      vc.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(vc, animated: true)
    case settingIndexPath:
      let storyboard = UIStoryboard(name: "SettingTVC", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("SettingTVC") as! SettingTVC
      vc.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(vc, animated: true)
    default:
      print("还没实现呢")
    }
  }
  
}
