//
//  InvoiceTableViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/27.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class InvoiceTableViewController: UITableViewController, InvoiceTableViewCellDelegate {
  let dataArray: NSMutableArray = NSMutableArray()
  override func viewDidLoad() {
    super.viewDidLoad()
    let item2 = UIBarButtonItem(title: "新增", style: UIBarButtonItemStyle.Plain, target: self, action: "addInvoce:")
    navigationItem.rightBarButtonItem = item2
    setUI()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    loadData()
  }
  
  func setUI() {
    self.tableView.backgroundView = UIImageView(image: UIImage(named: "星空_设置"))
    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    self.tableView.backgroundColor = UIColor.redColor()
  }
  
  func loadData() {
    ZKJSHTTPSessionManager.sharedInstance().getInvoiceListWithSuccess({ (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let arr = responseObject as? [AnyObject] {
        self.dataArray.removeAllObjects()
        for dic in arr {
          if let d = dic as? NSDictionary {
            let is_default = d["is_default"]!.boolValue!
            if is_default {//默认
              self.dataArray.insertObject(d, atIndex: 0)
            }else {//未默认
              self.dataArray.addObject(d)
            }
          }
        }
        self.tableView.reloadData()
      }
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      
    })
  }
  
  func addInvoce(sender:UIBarButtonItem) {
    let vc = InvoiceEditViewController()
    navigationController?.pushViewController(vc, animated: true)
  }
  // MARK: - Table view data source
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.row == dataArray.count {
      return 136
    }
    return 167
  }
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("InvoiceTableViewCell") as? InvoiceTableViewCell
    if cell == nil {
      cell = NSBundle.mainBundle().loadNibNamed("InvoiceTableViewCell", owner: self, options: nil).last as? InvoiceTableViewCell
    }
    cell?.tag = indexPath.row
    cell?.delegate = self
    cell?.invoiceTextField.text = dataArray[indexPath.row]["invoice_title"] as? String
    if indexPath.row != 0 && indexPath.row != dataArray.count {
      cell?.title.text = NSLocalizedString("INVOICE", comment: "") + " \(indexPath.row)"
    }
    return cell!
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if indexPath.row == self.dataArray.count {//最后一行
      self.navigationController?.pushViewController(InvoiceEditViewController(), animated: true)
    }
    
  }

  //MARK:- InvoiceTableViewCellDelegate
  func deleteWithIndex(row: Int) {
    ZKJSTool.showLoading()
    let dic = dataArray[row] as! NSDictionary
    let invoiceid = dic["id"] as! String
    ZKJSHTTPSessionManager.sharedInstance().deleteInvoiceWithInvoiceid(invoiceid, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let dic = responseObject as? NSDictionary {
        let set = dic["set"]!.boolValue!
        if set {
          ZKJSTool.showMsg(NSLocalizedString("DELETED", comment: ""))
          self.dataArray.removeObjectAtIndex(row)
          self.tableView.reloadData()
        }
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      
    }
  }
  func modifyWithIndex(row: Int) {
    self.navigationController?.pushViewController(InvoiceEditViewController(dic: (dataArray[row] as! NSDictionary)), animated: true)
  }
  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return NO if you do not want the specified item to be editable.
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
  // Return NO if you do not want the item to be re-orderable.
  return true
  }
  */
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.
  }
  */
  
}
