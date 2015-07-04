//
//  BookVC.swift
//  SVIP
//
//  Created by dai.fengyi on 15/6/30.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class BookVC: UIViewController , UITableViewDelegate, UITableViewDataSource{

  @IBOutlet var layoutConstaintArray: [NSLayoutConstraint]!
  @IBOutlet weak var searchBar: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var selectionView: UIView!

  @IBOutlet var singleSelectButtonArray: [BookItemButton]!
  @IBOutlet var mutipleSelectButtonArray: [BookItemButton]!
//Data
  var dataArray: Array<BookOrder>?
  
//MARK:- FUNCTION
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    super.init(nibName: "BookVC", bundle: nibBundleOrNil)
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    setUI()
    loadData()
  }
  
  func setUI() {
    let tap = UITapGestureRecognizer(target: self, action: Selector("searchMap:"))
    searchBar .addGestureRecognizer(tap)
    
    for button in singleSelectButtonArray {
      button .addTarget(self, action: NSSelectorFromString("singleSelect:"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    for button in mutipleSelectButtonArray {
      button .addTarget(self, action: Selector("mutipleSelect:"), forControlEvents: UIControlEvents.TouchUpInside)
    }
  }
  
  func loadData() {
    ZKJSHTTPSessionManager .sharedInstance() .getShopGoodsWithShopID("120", page: 1, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
//      if let arr = responseObject as? Array<Dictionary?<String, String>> {
//        for dic in arr {
//          let order = BookOrder(dic: dic)
//          self.dataArray?.append(order)
//        }
//      }
//      let dataDic = responseObject as! NSDictionary
//      for (airportCode, airportName) in dataDic {
//        println("\(airportCode): \(airportName)")
//      }
//        println(dataDic)
//      print("abc")
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
    
    }

  }
  
  override func updateViewConstraints() {
    var buttonCount = layoutConstaintArray.count
    var screenWidth = UIScreen.mainScreen().bounds.size.width
    var marginWidth = (Double(screenWidth) - Double(buttonCount) * 30.0) / Double(layoutConstaintArray.count + 1)
    for constrainst in layoutConstaintArray {
      constrainst.constant = CGFloat(marginWidth)
    }
    super.updateViewConstraints()
  }

//MARK:- BUTTON ACTION
  func singleSelect(sender: UIButton) {
    for button in singleSelectButtonArray {
      button.selected = false
    }
    sender.selected  = true
  }
  
  func mutipleSelect(sender: UIButton) {
    sender.selected = !sender.selected
  }
  
  @IBAction func book(sender: UIButton) {
//    let bookConfirmVC = BookConfirmVC.new()
//    self .presentViewController(bookConfirmVC, animated: true) { () -> Void in
//      
//    }

    self.navigationController! .pushViewController(BookConfirmVC.new(), animated: true)
  }
  
  func searchMap(sender: UIView) {
    //jump
    println("jump to map VC")
  }
//MARK:- TABLEVIEW
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 4
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 230
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView .dequeueReusableCellWithIdentifier("BookVC") as? BookRoomCell
    if cell == nil {
      let arr = NSBundle .mainBundle() .loadNibNamed("BookRoomCell", owner: nil, options: nil) as Array
      cell = arr[0] as? BookRoomCell
    }
    return cell!
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
  }
}