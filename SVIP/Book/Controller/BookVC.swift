//
//  BookVC.swift
//  SVIP
//
//  Created by dai.fengyi on 15/6/30.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

typealias RoomSelectionBlock = (RoomGoods) -> ()

class BookVC: UIViewController , UITableViewDelegate, UITableViewDataSource{

  @IBOutlet weak var confirmButton: UIButton!
  @IBOutlet private var layoutConstaintArray: [NSLayoutConstraint]!
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var selectionView: UIView!
  @IBOutlet private weak var selectionViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet private var leftSelectButtonArray: [BookItemButton]!
  @IBOutlet private var rightSelectButtonArray: [BookItemButton]!
  @IBOutlet weak var okButton: UIButton!
  var hotel = Hotel()
  var headerView = BookHeaderView!()
  
  //Data
  var shopid: NSNumber!
  var dataArray = NSMutableArray()
  var roomTypes = NSMutableArray()
  var selection: RoomSelectionBlock?  // Hanton
  private var filtedArray = NSMutableArray()
  private var selectedRow : Int = 0
  
  //MARK:- FUNCTION
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: "BookVC", bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setUI()
    loadData()
    loadRoomTypes()
  }
  
  override func viewWillAppear(animated: Bool) {
     super.viewWillAppear(animated)
    self.navigationController?.navigationBarHidden = true
    
    
  }
  
  override func viewWillDisappear(animated: Bool) {
  super.viewWillDisappear(animated)
   self.navigationController?.navigationBarHidden = false
   
  }
  
  func loadRoomTypes() {
    ZKJSHTTPSessionManager.sharedInstance().getShopGoodsListWithShopID(String(shopid), success: { [unowned self] (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      print(responseObject)
      if let arr = responseObject as? NSArray {
        for dict in arr {
          if let myDict = dict as? NSDictionary {
            let goods = RoomGoods(dic: myDict)
            self.roomTypes.addObject(goods)
          }
        }
        self.tableView.reloadData()
    }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  private func setUI() {
    title = NSLocalizedString("ROOM_TYPE", comment: "")
    
    automaticallyAdjustsScrollViewInsets = false
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 135, 0)
    

  }
  
  private func loadData() {
    ZKJSJavaHTTPSessionManager.sharedInstance().accordingMerchantNumberInquiryMerchantWithShopID(String(shopid), success: { (task:NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      let dic = responsObject as! NSDictionary
      self.hotel = Hotel(dic: dic as! [String:AnyObject])
      self.tableView.reloadData()
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        
    }
    

  }
  

  
  //MARK:- TABLEVIEW
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.roomTypes.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 160+8*2
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 387
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView .dequeueReusableCellWithIdentifier("BookVC") as? BookRoomCell
    if cell == nil {
      let arr = NSBundle .mainBundle() .loadNibNamed("BookRoomCell", owner: nil, options: nil) as Array
      cell = (arr[0] as! BookRoomCell)
    }
    cell!.goods = (roomTypes[indexPath.row] as! RoomGoods)
    return cell!
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    headerView = NSBundle.mainBundle().loadNibNamed("BookHeaderView", owner: self, options: nil).first as! BookHeaderView
    if hotel.shopid != nil {
      headerView.backButton.addTarget(self, action: "pop:", forControlEvents: UIControlEvents.TouchUpInside)
      headerView.hotelNameLabel.text = hotel.shopname
      let placeholderImage = UIImage(named: "img_hotel_zhanwei")
      headerView.addressLabel.text = hotel.shopaddress
      let logoURL = NSURL(string: hotel.bgImgUrl)
      headerView.backImageView.sd_setImageWithURL(logoURL, placeholderImage: placeholderImage)
      headerView.explainLabel.text = hotel.shopbusiness
      headerView.introducesLabel.text = hotel.shopdesc
      headerView.addressLabel.text = hotel.shopaddress
    }
    return headerView
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
    let oldCell = tableView .cellForRowAtIndexPath(NSIndexPath(forRow: selectedRow, inSection: 0))
    oldCell?.selected = false
    let newCell = tableView .cellForRowAtIndexPath(indexPath)
    newCell?.selected = true
    self.selectedRow = indexPath.row
    
  }
  
  func pop(sender:UIButton) {
    self.navigationController?.popViewControllerAnimated(true)
  }
  @IBAction func confirm(sender: AnyObject) {
    let storyboard = UIStoryboard(name: "BookingOrder", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("BookingOrderTVC") as! BookingOrderTVC
    let goods = roomTypes[self.selectedRow] as! RoomGoods
    vc.goods = goods
    vc.shopID = String(shopid)
    navigationController?.pushViewController(vc, animated: true)
  }
}