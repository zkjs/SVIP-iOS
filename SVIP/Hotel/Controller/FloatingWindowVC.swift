//
//  FloatingWindowVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/12.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

protocol refreshHomeVCDelegate{
  func refreshHomeVC(set:Bool)
}

class FloatingWindowVC: UIViewController, XLPagerTabStripViewControllerDelegate {
  
  var delegate:refreshHomeVCDelegate?
  var privilegeArray = [PrivilegeModel]()
  
  @IBOutlet weak var tableView: UITableView!

  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("FloatingWindowVC", owner: self, options: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.frame = UIScreen.mainScreen().bounds
    tableView.tableFooterView = UIView()
    tableView .registerNib(UINib(nibName: FloatCell.nibName(), bundle: nil), forCellReuseIdentifier: FloatCell.reuseIdentifier())
    
    view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
  }
 
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
    view.endEditing(true)
    super.touchesBegan(touches, withEvent: event)
    self.delegate?.refreshHomeVC(true)
    self.view.removeFromSuperview()
  }

}

extension FloatingWindowVC: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return privilegeArray.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return FloatCell.height()
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 100
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(FloatCell.reuseIdentifier(), forIndexPath: indexPath) as! FloatCell
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    let privilege = privilegeArray[indexPath.row]
    cell.setData(privilege)
    return cell
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = NSBundle.mainBundle().loadNibNamed("FloatHeaderView", owner: self, options: nil).first as! FloatHeaderView
    return view
  }
  
}
