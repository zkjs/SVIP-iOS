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
    self.navigationController!.navigationBar.translucent = true
    self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
    self.navigationController!.navigationBar.shadowImage = UIImage()
    let image = UIImage(named: "ic_fanhui_orange")
    let item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: "pop:")
    navigationController?.navigationBar.translucent = true
    self.navigationItem.leftBarButtonItem = item1
    //title = shopName
   
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
     navigationController?.navigationBar.translucent = false
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
    //title = NSLocalizedString("ROOM_TYPE", comment: "")
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
    }
    cell.setData(roomTypes[indexPath.row] as! RoomGoods)
    return cell
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    headerView = NSBundle.mainBundle().loadNibNamed("BookHeaderView", owner: self, options: nil).first as! BookHeaderView
    if hotel.shopid != nil {
      headerView.hotelNameLabel.text = hotel.shopname
      let placeholderImage = UIImage(named: "img_hotel_zhanwei")
      headerView.addressLabel.text = hotel.shopaddress
      let logoURL = NSURL(string: hotel.bgImgUrl)
//      print("这是\(hotel.bgImgUrl)")
      headerView.backImageView.sd_setImageWithURL(logoURL, placeholderImage: placeholderImage)
      headerView.explainLabel.text = hotel.shopbusiness
      headerView.introducesLabel.text = hotel.shopdesc
      headerView.addressLabel.text = hotel.shopaddress
//      let  dtext = headerView.introducesLabel.text
//      headerView.introducesLabel.font = UIFont.systemFontOfSize(14)
//      headerView.introducesLabel.numberOfLines = 0          //设置无限换行
//      headerView.introducesLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping  //自动折行
//      //根据detailText文字长度调节topView高度
//      let constraint = CGSize(width: headerView.introducesLabel.frame.size.width,height:0)
//      let size = dtext!.boundingRectWithSize(constraint,options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:headerView.introducesLabel.font],context: nil)
//      headerView.introducesLabel.sizeToFit()
//      headerView.introducesLabel.frame.size.height += size.height//CGRectMake(10,260, size.width, size.height)
//      headerView.frame.size.height += size.height
//      print(headerView.introducesLabel.frame)
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
  
  func pop(sender:UIBarButtonItem) {
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