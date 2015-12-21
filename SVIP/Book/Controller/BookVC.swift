//
//  BookVC.swift
//  SVIP
//
//  Created by dai.fengyi on 15/6/30.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

typealias RoomSelectionBlock = (RoomGoods) -> ()

class BookVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var confirmButton: UIButton!
  @IBOutlet private weak var tableView: UITableView!
  
  var hotel = Hotel()
  var headerView = BookHeaderView!()
  var shopid: NSNumber!
  var shopName: String!
  var dataArray = NSMutableArray()
  var roomTypes = NSMutableArray()
  var selection: RoomSelectionBlock?
  private var filtedArray = NSMutableArray()
  private var selectedRow : Int = -1  // 默认不选
  
  
  // MARK: - FUNCTION
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("BookVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUI()
    loadData()
    loadRoomTypes()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBarHidden = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.navigationBarHidden = false
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
    
    let nibName = UINib(nibName: BookRoomCell.nibName(), bundle: nil)
    tableView.registerNib(nibName, forCellReuseIdentifier: BookRoomCell.reuseIdentifier())
  }
  
  private func loadData() {
    ZKJSJavaHTTPSessionManager.sharedInstance().accordingMerchantNumberInquiryMerchantWithShopID(String(shopid), success: { (task:NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      let dic = responsObject as! NSDictionary
      self.hotel = Hotel(dic: dic as! [String:AnyObject])
      self.tableView.reloadData()
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        
    }
  }
  
  // MARK: - TABLEVIEW
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.roomTypes.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return BookRoomCell.height()
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return BookHeaderView.height()
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(BookRoomCell.reuseIdentifier()) as! BookRoomCell
    if indexPath.row == selectedRow {
      tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
    } else {
//      cell.backgroundColor = UIColor.clearColor()
    }
    cell.setData(roomTypes[indexPath.row] as! RoomGoods)
    return cell
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
    let oldCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedRow, inSection: 0))
    oldCell?.selected = false
    let newCell = tableView.cellForRowAtIndexPath(indexPath)
    newCell?.selected = true
    selectedRow = indexPath.row
    confirmButton.alpha = 1.0
    confirmButton.enabled = true
  }
  
  func pop(sender:UIButton) {
    navigationController?.popViewControllerAnimated(true)
  }
  
  @IBAction func confirm(sender: AnyObject) {
    let storyboard = UIStoryboard(name: "BookingOrder", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("BookingOrderTVC") as! BookingOrderTVC
    let goods = roomTypes[self.selectedRow] as! RoomGoods
    vc.goods = goods
    vc.shopID = String(shopid)
    vc.shopName = shopName
    navigationController?.pushViewController(vc, animated: true)
  }
  
}