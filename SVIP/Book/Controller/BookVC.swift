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

  @IBOutlet var leftSelectButtonArray: [BookItemButton]!
  @IBOutlet var rightSelectButtonArray: [BookItemButton]!
//Data
  var dataArray = NSMutableArray()
  var filtedArray = NSMutableArray()
  var selectedRow : Int = 0
  
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
    
    // Hanton
    title = "预订"
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.Plain, target: self, action: "dismissSelf")
    
    let tap = UITapGestureRecognizer(target: self, action: Selector("searchMap:"))
    searchBar .addGestureRecognizer(tap)
    
    for button in leftSelectButtonArray {
      button .addTarget(self, action: NSSelectorFromString("categorySelect:"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    for button in rightSelectButtonArray {
      button .addTarget(self, action: Selector("breakfastSelect:"), forControlEvents: UIControlEvents.TouchUpInside)
    }
  }
  
  func loadData() {
    ZKJSHTTPSessionManager .sharedInstance() .getShopGoodsPage(1, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let arr = responseObject as? Array<AnyObject> {
        for dict in arr {
//        let aDic = dict as! NSDictionary
//          let goods = RoomGoods(dic: dict as? Dictionary)
          let goods = RoomGoods(dic: dict as? NSDictionary)
          self.dataArray.addObject(goods)
        }
        
        let button = self.leftSelectButtonArray.last
        self .categorySelect(button!)
        

      }
//      let dataDic = responseObject as! NSDictionary
//      for (airportCode, airportName) in dataDic {
//        println("\(airportCode): \(airportName)")
//      }
//        println(dataDic)
//      print("abc")
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
    }
  }
  
  func filtArray(keyString: String?)->NSMutableArray {
    if keyString == "全部" {
      return NSMutableArray(array: dataArray)
    }
    var mutArr = NSMutableArray()
    for tempObject in dataArray {
      let goods = tempObject as! RoomGoods
      if goods.room == keyString {
        mutArr .addObject(goods)

      }
    }
    return mutArr
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
  
  // Hanton
  func dismissSelf() -> Void {
    dismissViewControllerAnimated(true, completion: nil)
  }

//MARK:- BUTTON ACTION
  func categorySelect(sender: UIButton) {
    for button in leftSelectButtonArray {
      button.selected = false
    }
    sender.selected  = true
    
    filtedArray = self .filtArray(sender.titleLabel?.text)
    tableView .reloadData()
    self.selectedRow = 0
    self.tableView .selectRowAtIndexPath(NSIndexPath(forRow: self.selectedRow, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Top)
  }
  
  func breakfastSelect(sender: UIButton) {
    for button in rightSelectButtonArray {
      button.selected = false
    }
    sender.selected  = true
  }
  /*
  var goodsid: String?
  var name: String?
  var unit: String?
  var goods_brief: String?
  var goods_desc: String?
  var cat_id: String?
  var goods_img: String?
  var market_price: String?
  var cat_name: String?
  */
  /*  
  var userid: String!
  var token: String!
  var shopid: String!
  var room_typeid: String!
  var guest: String!
  var guesttel: String!
  var rooms: String!
  var room_type: String!
  var room_rate: String!
  var arrival_date: String!
  var departure_date: String!
  */
  @IBAction func book(sender: UIButton) {
    if self.filtedArray.count == 0 {
      return
    }
    let goods = self.filtedArray[selectedRow] as? RoomGoods
    for button in rightSelectButtonArray {
      if button.selected == true {
        goods?.meat = button.titleLabel?.text
      }
    }
    let bookConfirmVC = BookConfirmVC.new()
    bookConfirmVC.goods = goods
    self.navigationController! .pushViewController(bookConfirmVC, animated: true)
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
    return self.filtedArray.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 235
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView .dequeueReusableCellWithIdentifier("BookVC") as? BookRoomCell
    if cell == nil {
      let arr = NSBundle .mainBundle() .loadNibNamed("BookRoomCell", owner: nil, options: nil) as Array
      cell = arr[0] as? BookRoomCell
    }
//    if let order = filtedArray?[indexPath.row] as? RoomGoods{
//      cell?.order = order as RoomGoods
//    }

    cell?.goods = (filtedArray[indexPath.row] as! RoomGoods)
//    cell?.frame = CGRectMake(5, 5, tableView.frame.width - 10, 230)
//    cell?.backgroundColor = UIColor.blueColor()
//    cell?.contentView.backgroundColor = UIColor.yellowColor()
    return cell!
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
    let oldCell = tableView .cellForRowAtIndexPath(NSIndexPath(forRow: selectedRow, inSection: 0))
    oldCell?.selected = false
    let newCell = tableView .cellForRowAtIndexPath(indexPath)
    newCell?.selected = true
    self.selectedRow = indexPath.row
  }

}