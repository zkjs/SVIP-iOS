//
//  ServiceListTVC.swift
//  SVIP
//
//  Created by Qin Yejun on 6/22/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class ServiceListTVC: UITableViewController {

  var locid = ""
  var bluetoothOn = false
  
  @IBOutlet weak var locationButton: UIButton!
  
  private var services = [ServiceLoc]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let btn = UIBarButtonItem(image: UIImage(named: "ic_nav_more"), style: .Plain, target: self, action: #selector(showOrders));
    self.navigationItem.rightBarButtonItem = btn;
    
    if !bluetoothOn {
      locationUnavailableAlert()
    } else {
      loadData()
    }
    /*for i in 0..<2 {
      var loc = ServiceLoc()
      loc.locdesc = "loc:\(i)"
      loc.locid = "\(i)"
      
      for j in 0..<3 {
        var cat = SerivceCategory()
        cat.id = "c\(j)"
        cat.name =  "loc:\(i),cat:\(j)"
        
        for k in 0..<4 {
          var s = ServiceTag()
          s.id = "t\(k)"
          s.name = "loc:\(i),cat:\(j),tag:\(k)"
          cat.services.append(s)
        }
        
        loc.categories.append(cat)
      }
      
      services.append(loc)
    }
    services[0].categories[1].collapse = true*/
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if !locid.isEmpty {
      loadData()
    }
  }
  
  private func loadData() {
    showHUDInView(view, withLoading: "")
    HttpService.sharedInstance.getServiceTag(locid) { (services, err) in
      self.hideHUD()
      if let err = err {
        self.showErrorHint(err)
      } else {
        self.locid = ""
        if services.count > 0 {
          self.services = services
          self.expandFirstSection()
          self.tableView.reloadData()
          self.locationButton.setTitle(services[0].locdesc, forState: .Normal)
        } else {
          self.nodataAlert()
        }
      }
    }
  }
  
  func expandFirstSection() {
    var first = true
    for (idx,s) in services.enumerate() {
      for (idx2,_) in s.categories.enumerate() {
        services[idx].categories[idx2].collapse = !first
      }
      first = false;
    }
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return services.count
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let cnt = services[section].categories.reduce(0) { (t, c) -> Int in
      //print("\(c.id) => \(c.name) => \(c.services.count) => \(c.collapse)")
      return c.collapse ? (t + 1) : (t + c.services.count + 1)
    }
    //print("section:\(section), count:\(cnt)")
    return cnt
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return services[section].locdesc
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    var cell:UITableViewCell
    var reuseIdentifier = "ServiceTag"
    let isFirst = isFirstRow(indexPath)
    if isFirst {
      reuseIdentifier = "ServiceCategory"
    }
    cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
    let titleLabel = cell.viewWithTag(1) as! UILabel
    if isFirst {
      let icon = cell.viewWithTag(2) as! UIImageView
      icon.image = UIImage(named: "ic_show")
      if let cat = categoryForRow(indexPath) {
        titleLabel.text = cat.name
        if cat.collapse {
          icon.image = UIImage(named: "ic_collapse")
        }
      }
    } else {
      if let tag = tagForRow(indexPath) {
        titleLabel.text = tag.name
      }
    }
    
    return cell
  }
  
  func tagForRow(indexPath:NSIndexPath) -> ServiceTag? {
    let cats = services[indexPath.section].categories
    
    var cnt = 0
    for cat in cats {
      var curGroupCount = 0
      if cat.collapse {
        curGroupCount = 1
      } else {
        curGroupCount = 1 + cat.services.count
      }
      cnt += curGroupCount
      if indexPath.row == cnt {
        return nil
      }
      if indexPath.row < cnt {
        let row = indexPath.row - (cnt - curGroupCount) - 1
        //print("\(cat.services.count),\(row)")
        return cat.services[row]
      }
    }
    return nil
  }
  
  func categoryForRow(indexPath:NSIndexPath) -> SerivceCategory? {
    let cats = services[indexPath.section].categories
    
    var cnt = 0
    for cat in cats {
      var curGroupCount = 0
      if cat.collapse {
        curGroupCount = 1
      } else {
        curGroupCount = 1 + cat.services.count
      }
      cnt += curGroupCount
      if indexPath.row == cnt - curGroupCount {
        return cat
      }
    }
    return nil
  }
  
  func isFirstRow(indexPath:NSIndexPath) -> Bool {
    let cats = services[indexPath.section].categories
    var cnt = 0
    for cat in cats {
      if indexPath.row == cnt {
        return true
      }
      if indexPath.row < cnt {
        return false
      }
      if cat.collapse {
        cnt += 1
      } else {
        cnt += 1 + cat.services.count
      }
    }
    
    return false
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if isFirstRow(indexPath) {
      toggleCategory(indexPath)
    } else if let _ = tagForRow(indexPath){
      chooseService(indexPath)
    }
  }
  
  func chooseService(indexPath:NSIndexPath) {
    performSegueWithIdentifier("SegueSubmitService", sender: indexPath)
  }
  
  func toggleCategory(indexPath:NSIndexPath) -> Bool {
    let cats = services[indexPath.section].categories
    var cnt = 0
    for (index, cat) in cats.enumerate() {
      if indexPath.row == cnt {
        services[indexPath.section].categories[index].collapse = !cat.collapse
        tableView.reloadData()
        return true
      }
      if indexPath.row < cnt {
        return false
      }
      if cat.collapse {
        cnt += 1
      } else {
        cnt += 1 + cat.services.count
      }
    }
    
    return false
  }

  // MARK: - Navigation
  
  func showOrders() {
    performSegueWithIdentifier("SegueOrders", sender: nil)
  }
  
  func locationUnavailableAlert() {
    var msg = "请手动选择您所在的商家和服务"
    if !bluetoothOn {
      msg = "请点击设置，打开蓝牙以便我们更好的为您提供服务"
    }
    let alertVC = UIAlertController(title: "无法获取您所在的区域", message: msg, preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "确认", style: .Default) { _ in
      self.openMerchantList()
    }
    let setupAction = UIAlertAction(title: "设置", style: .Cancel) { _ in
      self.openSettings()
    }
    if !bluetoothOn {
      alertVC.addAction(setupAction)
    }
    alertVC.addAction(okAction)
    
    presentViewController(alertVC, animated: true, completion: nil)
    
  }
  
  func openSettings() {
    if #available(iOS 9, *) {
      let url = NSURL(string: "prefs:root=Bluetooth")
      UIApplication.sharedApplication().openURL(url!)
    } else {
      let url = NSURL(string: "prefs:root=General&path=Bluetooth")
      UIApplication.sharedApplication().openURL(url!)
    }
  }
  
  func openMerchantList() {
    performSegueWithIdentifier("SegueMerchant", sender: nil)
  }
  
  func nodataAlert() {
    showHint("没有获取到商家服务数据")
  }

  @IBAction func selectArea(sender: AnyObject) {
    if services.isEmpty {
      performSegueWithIdentifier("SegueMerchant", sender: nil)
    } else {
      performSegueWithIdentifier("SegueBeaconArea", sender: nil)
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "SegueBeaconArea" {
      let vc = segue.destinationViewController as! BeaconAreaListTVC
      let areas = services.map{ $0.locdesc }
      vc.areasList = areas
      vc.delegate = self
    }
    else if segue.identifier == "SegueSubmitService" {
      if let tag = tagForRow(sender as! NSIndexPath) {
        let vc = segue.destinationViewController as! SubmitOrderVC
        vc.delegate = self
        vc.srvid = String(tag.id)
        vc.locid = services[0].locid
      }
    }
  }
  
}

extension ServiceListTVC:BeaconAreaSelectDelegate {
  func selectArea(area: BeaconArea) {
    sortLoc(area)
  }
  
  func sortLoc(area:BeaconArea) {
    var idx = 0
    for (index, loc) in services.enumerate() {
      if loc.locdesc == area.area {// selected area
        idx = index
        break
      }
    }
    if idx > 0 {
      var locs = services
      let loc = locs.removeAtIndex(idx)
      locs.insert(loc, atIndex: 0)
      services = locs
      locationButton.setTitle(loc.locdesc, forState: .Normal)
      expandFirstSection()
      tableView.reloadData()
    }
  }
}

extension ServiceListTVC:SubmitOrderDelegate {
  func SubmitSuccess() {
    showOrders()
  }
  
  func submitFail() {
    
  }
}
