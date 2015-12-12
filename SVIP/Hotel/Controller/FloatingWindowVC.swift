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
  var myView:FloatHeaderView!
  var dataArray = Array<[String: String]>()
  @IBOutlet weak var tableView: UITableView!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Identifier)
    tableView.tableFooterView = UIView()
    loadData()
    tableView.scrollEnabled = false
    navigationController?.navigationBarHidden = true
    view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
  }
  
  func loadData() {
    let title1 = NSLocalizedString("专属客服为您服务", comment: "")
    let menu1 = ["logo": "ic_v_orange",
      "text": title1]
    let title2 = NSLocalizedString("免前台入住酒店", comment: "")
    let menu2 = ["logo": "ic_xiuxian_orange",
      "text": title2]
    let title3 = NSLocalizedString("个性化服务,一次定制,次次贴心", comment: "")
    let menu3 = ["logo": "ic_liwu_orange",
      "text": title3]
    
    dataArray.append(menu1)
    dataArray.append(menu2)
    dataArray.append(menu3)
    
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
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
    view.endEditing(true)
    super.touchesBegan(touches, withEvent: event)
    self.view.removeFromSuperview()
  }

  // MARK: - Table view data source
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 200
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
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    return cell
  }
  
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    myView = NSBundle.mainBundle().loadNibNamed("FloatHeaderView", owner: self, options: nil).first as! FloatHeaderView
    return myView
  }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("FloatingWindowVC", owner: self, options: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
}
