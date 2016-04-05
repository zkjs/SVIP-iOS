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
  @IBOutlet weak var loginLabel: UILabel!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView()
    automaticallyAdjustsScrollViewInsets = false
    
    
    if tableView.respondsToSelector(Selector("setSeparatorInset:")) {
      tableView.separatorInset = UIEdgeInsetsZero
    }
    if tableView.respondsToSelector(Selector("setLayoutMargins:")) {
      tableView.layoutMargins = UIEdgeInsetsZero
    }
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBarHidden = false
    navigationController?.navigationBar.translucent = false
    
    setupUI()

  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    if cell.respondsToSelector(Selector("setSeparatorInset:")) {
      cell.separatorInset = UIEdgeInsetsZero
    }
    if cell.respondsToSelector(Selector("setLayoutMargins:")) {
      cell.layoutMargins = UIEdgeInsetsZero
    }
  }
  
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.navigationBarHidden = false
  }
  
  func setupUI() {
    if TokenPayload.sharedInstance.isLogin == true {
      loginLabel.hidden = true
      let avatarURL = AccountManager.sharedInstance().avatarURL
      userImage.sd_setImageWithURL(NSURL(string: avatarURL), placeholderImage: UIImage(named: "logo_white"))
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell.accessoryView = UIImageView(image: UIImage(named: "ic_right_orange"))
    return cell
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if TokenPayload.sharedInstance.isLogin == false {
      let nc = BaseNC(rootViewController: LoginFirstVC())
      presentViewController(nc, animated: true, completion: nil)
      return
    }
    
    let accountIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    let settingIndexPath = NSIndexPath(forRow: 1, inSection: 0)
    
    switch indexPath {
    case accountIndexPath:
      let storyboard = UIStoryboard(name: "AccountTVC", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("AccountTVC") as! AccountTVC
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
  
  //暂时屏蔽订单管理功能 [commented at 2016-03-14]
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    switch indexPath.row {
    case 0: return 80
    case 1: return 44
    default: return 0
    }
  }
  
}
