//
//  CityVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/14.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class CityVC: UIViewController,UITableViewDataSource,UITableViewDelegate {

  @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
      title = "长沙"
      let item1 = UIBarButtonItem(image: UIImage(named: "ic_fanhui"), style: UIBarButtonItemStyle.Plain, target: self, action: "popTotopView:")
      self.navigationItem.leftBarButtonItem = item1
      
      let item2 = UIBarButtonItem(image: UIImage(named: "ic_sousuo"), style: UIBarButtonItemStyle.Plain, target: self, action: "search:")
      let item3 = UIBarButtonItem(image: UIImage(named: "ic_tianjia"), style: UIBarButtonItemStyle.Plain, target: self, action: "more:")
      navigationItem.setRightBarButtonItems([item3,item2], animated: true)
      let nibName = UINib(nibName: HotCityCell.nibName(), bundle: nil)
      tableView.registerNib(nibName, forCellReuseIdentifier: HotCityCell.reuseIdentifier())
      let nibName1 = UINib(nibName: RecentCityCell.nibName(), bundle: nil)
      tableView.registerNib(nibName1, forCellReuseIdentifier: RecentCityCell.reuseIdentifier())
      tableView.tableFooterView = UIView()
      navigationController?.navigationBar.translucent = false
      navigationController?.navigationBar.barStyle = UIBarStyle.Black
      navigationController?.navigationBar.tintColor = UIColor.whiteColor()
      

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("CityVC", owner:self, options:nil)
  }
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  
  func popTotopView(sender:UIBarButtonItem) {
    navigationController?.popViewControllerAnimated(true)
  }
  
  func search(sender:UIBarButtonItem) {
    
  }
  
  func more(sender:UIBarButtonItem) {
    
  }
  
  //MARK -TableView Data Source
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 2 {
      return 10
    }else {
      return 1
    }
  }
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 50
    }else {
     return 20
    }
    
  }
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return HotCityCell.height()
    }
    if indexPath.section == 1 {
      return RecentCityCell.height()
    }
    else
    {
      return 50
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(HotCityCell.reuseIdentifier(), forIndexPath: indexPath) as! HotCityCell
      
      return cell
    }
    if indexPath.section == 1 {
      let cell = tableView.dequeueReusableCellWithIdentifier(RecentCityCell.reuseIdentifier(), forIndexPath: indexPath) as! RecentCityCell
      return cell
    }else {
      let cell = tableView.dequeueReusableCellWithIdentifier(RecentCityCell.reuseIdentifier(), forIndexPath: indexPath) as! RecentCityCell
      return cell
    }
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 {
      let search = UISearchBar()
      search.backgroundColor = UIColor.blackColor()
     
      return search
    }else {
      return nil
    }
    
    
    
    
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "最近访问的城市"
    }
    if section == 1 {
      return "热门城市"
    }
    else {
      return "A"
    }
  }
  
    



}
