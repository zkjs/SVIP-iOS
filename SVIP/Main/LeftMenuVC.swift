//
//  LeftMenuVC.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/7.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit
let LeftMenuProportion = 0.75
class LeftMenuVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
  let Identifier = "LeftMenuCell"
  var dataArray: NSArray?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var widthConstraint: NSLayoutConstraint!
  @IBOutlet weak var avatar: UIButton!
  @IBOutlet weak var name: UILabel!
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("LeftMenuVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUI()
    loadData()
    tableView?.reloadData()
  }

  func loadData() {
    let path = NSBundle.mainBundle().pathForResource("LeftMenu", ofType: "plist")
    dataArray = NSArray(contentsOfFile:path!)
  }
  
  func setUI() {
    tableView .registerClass(UITableViewCell.self, forCellReuseIdentifier: Identifier)
    widthConstraint.constant = UIScreen.mainScreen().bounds.width * 0.75
  }
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    setUI()
  }
  
  // MARK: - Table view data source
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.dataArray == nil {
      return 0
    }else {
      return self.dataArray!.count
    }
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 60
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as? UITableViewCell
    if cell == nil {
      cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: Identifier)
    }
    // Configure the cell...
    cell?.backgroundColor = UIColor.clearColor()
    if let dic = dataArray![indexPath.row] as? Dictionary<String, String> {
      cell!.textLabel?.text = dic["text"]
      cell?.textLabel?.textColor = UIColor.whiteColor()
    }
    
    return cell!
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
//    let vc = BookVC()
//    vc.shopid = (dataArray[indexPath.row] as? Hotel)!.shopid
//    if let navi = self.sideMenuViewController.contentViewController as? UINavigationController {
//      self.sideMenuViewController.hideMenuViewController()
//      navi.pushViewController(vc, animated: true)
//    }

  }


}
