//
//  InvoiceVC.swift
//  SVIP
//
//  Created by Hanton on 12/16/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

typealias InvoiceSelectionBlock = (InvoiceModel) -> ()

class InvoiceVC: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  var dataArray = [InvoiceModel]()
  var selection: InvoiceSelectionBlock!
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("InvoiceVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
    title = "发票"
    
    tableView.tableFooterView = UIView()
    
    let nibName = UINib(nibName: InvoiceCell.nibName(), bundle: nil)
    tableView.registerNib(nibName, forCellReuseIdentifier: InvoiceCell.reuseIdentifier())
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    loadData()
  }
  
  func loadData() {
    ZKJSHTTPSessionManager.sharedInstance().getInvoiceListWithSuccess({ (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let array = responseObject as? [[String: AnyObject]] {
        self.dataArray.removeAll()
        for dict in array {
          let invoice = InvoiceModel(dict: dict)
          print(invoice.title)
          print(invoice.isDefault)
          if invoice.isDefault {
            //默认发票置顶
            self.dataArray.insert(invoice, atIndex: 0)
          } else {
            self.dataArray.append(invoice)
          }
        }
        self.tableView.reloadData()
      }
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    })
  }
  
  
  @IBAction func addInvoice(sender: AnyObject) {
    let vc = InvoiceDetailVC()
    vc.type = .Add
    navigationController?.pushViewController(vc, animated: true)
  }
  
}

// MARK: - SWTableViewDelegate

extension InvoiceVC: SWTableViewCellDelegate {
  
  func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
    switch index {
    case 0:
      showHUDInView(view, withLoading: "正在删除发票...")
      let indexPath = tableView.indexPathForCell(cell)!
      let invoice = dataArray[indexPath.section]
      ZKJSHTTPSessionManager.sharedInstance().deleteInvoiceWithInvoiceid(invoice.id, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        if let data = responseObject as? [String: AnyObject] {
          if let set = data["set"] as? NSNumber {
            if set.boolValue {
              self.hideHUD()
              self.showHint("删除成功")
              self.dataArray.removeAtIndex(indexPath.section)
              self.tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
              self.tableView.reloadData()
            }
          }
        }
        }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
          
      }
    default:
      break
    }
  }
  
}

extension InvoiceVC: UITableViewDataSource, UITableViewDelegate {
  
  //MARK -Table View Data Source
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return dataArray.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 2
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView()
    headerView.backgroundColor = UIColor.clearColor()
    return headerView
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return InvoiceCell.height()
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(InvoiceCell.reuseIdentifier(), forIndexPath: indexPath) as! InvoiceCell
    let invoice = dataArray[indexPath.section]
    cell.setData(invoice)
    cell.delegate = self
    return cell
  }
  
  // MARK: - Table View Delegate
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let invoice = dataArray[indexPath.section]
    
    if selection == nil {
      let vc = InvoiceDetailVC()
      vc.type = .Update
      vc.invoice = invoice
      navigationController?.pushViewController(vc, animated: true)
    } else {
      selection(invoice)
      navigationController?.popViewControllerAnimated(true)
    }
  }
  
}
