//
//  MailListTVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/12.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class MailListTVC: UITableViewController {
  var contactArray = [ContactModel]()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "通讯录"
    
    let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_fanhui"), style: UIBarButtonItemStyle.Plain, target: self, action: "dismissSelf")
    self.navigationItem.leftBarButtonItem = leftBarButtonItem
    let nibName = UINib(nibName: MailListCell.nibName(), bundle: nil)
    tableView.registerNib(nibName, forCellReuseIdentifier: MailListCell.reuseIdentifier())
    tableView.tableFooterView = UIView()
   loadFriendListData()
  }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("MailListTVC", owner:self, options:nil)
  }
  
  func loadFriendListData() {
    ZKJSHTTPSessionManager.sharedInstance().managerFreindListWithFuid("", set: "showFriend", success: { (task:NSURLSessionDataTask!, responsObjects: AnyObject!) -> Void in
      if let array = responsObjects as? NSArray {
        for dic in array {
          let contact = ContactModel(dic: dic as! [String: AnyObject])
          self.contactArray.append(contact)
        }
        self.tableView.reloadData()
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  func dismissSelf() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return contactArray.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return MailListCell.height()
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  let cell = tableView.dequeueReusableCellWithIdentifier(MailListCell.reuseIdentifier(), forIndexPath: indexPath) as! MailListCell
    let contact = contactArray[indexPath.row]
    cell.setData(contact)
  return cell
  }
  
  
  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return false if you do not want the specified item to be editable.
  return true
  }
  */
  
  /*
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  if editingStyle == .Delete {
  // Delete the row from the data source
  tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
  } else if editingStyle == .Insert {
  // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }
  }
  */
  
  /*
  // Override to support rearranging the table view.
  override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
  
  }
  */
  
  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return false if you do not want the item to be re-orderable.
  return true
  }
  */
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
