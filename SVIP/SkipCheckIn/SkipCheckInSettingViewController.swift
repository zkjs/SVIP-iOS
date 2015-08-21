//
//  SkipCheckInSettingViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/21.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class SkipCheckInSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  let Identifier = "Identifier"
  @IBOutlet weak var tableView: UITableView!
  
  required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName:"SkipCheckInSettingViewController", bundle: nil)
  }
  
  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
 override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //MARK:- UITableView
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 4
  }
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier(Identifier) as? UITableViewCell
    if cell == nil {
      cell = NSBundle.mainBundle().loadNibNamed("SkipCheckInSettingListCell", owner: nil, options: nil).last as! SkipCheckInSettingListCell
    }
    return cell!
  }
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
  }
}
