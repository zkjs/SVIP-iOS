//
//  ComprehensiveVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/10.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit
import CoreLocation

@objc enum ComprehensiveType: Int {
  case chat
  case customerService
}

class ComprehensiveVC: UIViewController {
  
  var shops = [NSDictionary]()
  var item2 = UIBarButtonItem()
  var dataArray = [Hotel]()
  var recommendArray = [RecommendModel]()
  let locationManager:CLLocationManager = CLLocationManager()
  var longitude: double_t!
  var latution: double_t!
  var cityArray = [String]()
  lazy var type = ComprehensiveType.chat
  var orderPage = 1
   var currentCity: String!
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    showHUDInView(view, withLoading: "正在加载中...")
    tableView.tableFooterView = UIView()
    tableView.showsVerticalScrollIndicator = false
    let nibName = UINib(nibName: HotelCell.nibName(), bundle: nil)
    tableView.registerNib(nibName, forCellReuseIdentifier: HotelCell.reuseIdentifier())
    let nibName1 = UINib(nibName: RecommandCell.nibName(), bundle: nil)
    tableView.registerNib(nibName1, forCellReuseIdentifier: RecommandCell.reuseIdentifier())
    
    tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: "refreshData")  // 下拉刷新
    tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "loadMore")  // 上拉加载
    let image = UIImage(named: "ic_search_orange")
    let item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: "choiceCity:")
    
    
    item2 = UIBarButtonItem(title: "想去哪里,享受尊贵服务", style: UIBarButtonItemStyle.Done, target: self, action: nil)
    item2.tintColor = UIColor.ZKJS_navegationTextColor()
    super.navigationItem.leftBarButtonItems = [item1,item2]
    super.navigationController?.navigationBar.tintColor = UIColor.ZKJS_mainColor()
    setupCoreLocationService()
    // Do any additional setup after loading the view.
  }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("ComprehensiveVC", owner:self, options:nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    
    self.hidesBottomBarWhenPushed = false
    navigationController?.navigationBarHidden = false
    
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  func loadMore() {
     orderPage++
     loadShopListData(orderPage)
  }
  func refreshData() {
    orderPage = 1
    setupCoreLocationService()
//    loadRecommandData()
//    loadShopListData(orderPage)
    
  }
  
  func choiceCity(sender:UIBarButtonItem) {
    let vc = CityVC()
    let nav = BaseNC(rootViewController: vc)
    navigationController?.presentViewController(nav, animated: true, completion: nil)
  }
  

  func  loadRecommandData() {
    
    ZKJSJavaHTTPSessionManager.sharedInstance().getRecommendShopListWithCity(currentCity, success: { (task:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
      if let array = responseObject as? NSArray {
        self.recommendArray.removeAll()
          for dic in array {
            let recommend = RecommendModel(dic: dic as! [String:AnyObject])
            self.recommendArray.append(recommend)
          }
          self.loadShopListData(self.orderPage)
          self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation:.Automatic)
          self.tableView.mj_header.endRefreshing()
        }
      
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
    }

  }
  
  
  private func loadShopListData(page: Int) {
    //获取所有商家列表
    ZKJSJavaHTTPSessionManager.sharedInstance().getShopListWithPage(String(orderPage),size:"10", success: { (task:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
      if let array = responseObject as? NSArray {
        self.dataArray.removeAll()
          for dic in array {
            let hotel = Hotel(dic: dic as! [String:AnyObject])
            self.dataArray.append(hotel)
          }
          self.hideHUD()
        
          self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation:.Automatic)
        
        }
        //self.tableView.mj_footer.endRefreshing()
        self.tableView.mj_header.endRefreshing()
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        
    }
}
  
  // MARK: - Table view data source
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    if section == 0 {
      return recommendArray.count
    }
    else {
//      print(dataArray.count)
      return dataArray.count
    }
    
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return RecommandCell.height()
    } else {
      return HotelCell.height()
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(RecommandCell.reuseIdentifier(), forIndexPath: indexPath) as! RecommandCell
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      let recommand = self.recommendArray[0]
      cell.setdata(recommand)
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(HotelCell.reuseIdentifier(), forIndexPath: indexPath) as! HotelCell
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      let shop = dataArray[indexPath.row]
      cell.setData(shop)
      return cell
    }
    
    
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
    let hotel = self.dataArray[indexPath.row]
    if type == .chat {
      let storyboard = UIStoryboard(name: "BookingOrder", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("BookingOrderTVC") as! BookingOrderTVC
      
      vc.shopID = hotel.shopid
      vc.shopName = hotel.shopname
      self.navigationController?.pushViewController(vc, animated: true)
    } else if type == .customerService {
      let vc = CustomerServiceTVC()
      vc.shopID = hotel.shopid
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  func setupUI() {
    let loc = CLLocation(latitude: latution, longitude: longitude)
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(loc) { (array:[CLPlacemark]?, error:NSError?) -> Void in
      if array?.count > 0 {
        let placemark = array![0]
        var city = placemark.locality
        if (city == nil) {
          city = placemark.administrativeArea
        }
        self.currentCity = city?.stringByReplacingOccurrencesOfString("市", withString:"")
        self.loadRecommandData()
      }
    }
  }
  
}

extension ComprehensiveVC: CLLocationManagerDelegate {
  
  private func setupCoreLocationService() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    let alertView = UIAlertController(title: "无法定位您所在城市", message: "需要您前往设置中心打开定位服务", preferredStyle: .Alert)
    alertView.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
    presentViewController(alertView, animated: true, completion: nil)
    
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location:CLLocation = locations[locations.count - 1]
    if location.horizontalAccuracy > 0 {
      latution = location.coordinate.latitude
      longitude = location.coordinate.longitude
      locationManager.stopUpdatingLocation()
    }
    setupUI()
  }
  
}
