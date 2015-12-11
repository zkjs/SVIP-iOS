//
//  FindListTVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/12.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class FindListTVC: UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "发现"
    
    let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_fanhui"), style: UIBarButtonItemStyle.Plain, target: self, action: "dismissSelf")
    self.navigationItem.leftBarButtonItem = leftBarButtonItem
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
//  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//    super.init(nibName: "FindListTVC", bundle: nil)
//  }
//  
//  required init?(coder aDecoder: NSCoder) {
//    super.init(coder: aDecoder)
//    
//  }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("FindListTVC", owner:self, options:nil)
  }
  
  func dismissSelf() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 0
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return 0
  }
  
  /*
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
  
  // Configure the cell...
  
  return cell
  }
  */
  

  
}

