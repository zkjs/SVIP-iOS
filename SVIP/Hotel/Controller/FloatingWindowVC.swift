//
//  FloatingWindowVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/12.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class FloatingWindowVC: UIViewController, XLPagerTabStripViewControllerDelegate {
  let Identifier = "SettingVCCell"
  var myView:MainHeaderView!
  var dataArray = Array<[String: String]>()
  @IBOutlet weak var tableView: UITableView!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Identifier)
    tableView.tableFooterView = UIView()
    loadData()
    navigationController?.navigationBarHidden = true
    view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
  }
  
  func loadData() {
    let title1 = NSLocalizedString("特权", comment: "")
    let menu1 = ["logo": "ic_tequan-1",
      "text": title1]
    let title2 = NSLocalizedString("行程", comment: "")
    let menu2 = ["logo": "ic_xingcheng-1",
      "text": title2]
    let title3 = NSLocalizedString("已消费", comment: "")
    let menu3 = ["logo": "ic_yixiaofei-1",
      "text": title3]
    let title4 = NSLocalizedString("设置", comment: "")
    let menu4 = ["logo": "ic_shezhi-1",
      "text": title4]
    dataArray.append(menu1)
    dataArray.append(menu2)
    dataArray.append(menu3)
    dataArray.append(menu4)
    //分割线往左移
    if tableView.respondsToSelector("setSeparatorInset:") {
      self.tableView.separatorInset = UIEdgeInsetsZero
    }
    if tableView.respondsToSelector("setLayoutMargins:") {
      self.tableView.layoutMargins = UIEdgeInsetsZero
    }
    NSNotificationCenter.defaultCenter().addObserver(self, selector:"downloadImage:",
      name: "DownloadImageNotification", object: nil)
    
  }

  // MARK: - Table view data source
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 100
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 48
  }
  
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(Identifier, forIndexPath: indexPath)
    let dic = dataArray[indexPath.row]
    cell.textLabel?.text = dic["text"]
    cell.imageView?.image = UIImage(named:dic["logo"]!)
    cell.textLabel?.textColor = UIColor.lightGrayColor()
    return cell
  }
  
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    myView = NSBundle.mainBundle().loadNibNamed("MainHeaderView", owner: self, options: nil).first as! MainHeaderView
    myView.userImageButton.addTarget(self, action: "setInfo:", forControlEvents: UIControlEvents.TouchUpInside)
    
    return myView
  }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("FloatingWindowVC", owner: self, options: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
}
