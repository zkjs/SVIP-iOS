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
   let locationManager:CLLocationManager = CLLocationManager()
  var longitude: double_t!
  var latution: double_t!
  var cityArray = [String]()
  lazy var type = ComprehensiveType.chat
  var orderPage = 1
  
  @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
      title = "商家"
      showHUDInView(view, withLoading: "正在加载中...")
      setupCoreLocationService()
      tableView.tableFooterView = UIView()
      tableView.showsVerticalScrollIndicator = false
      let nibName = UINib(nibName: HotelCell.nibName(), bundle: nil)
      tableView.registerNib(nibName, forCellReuseIdentifier: HotelCell.reuseIdentifier())
      tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: "refreshData")  // 下拉刷新
      tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "loadMoreData")  // 上拉加载
      let image = UIImage(named: "ic_dingwei_orange")
      let item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: nil)
      
      
      item2 = UIBarButtonItem(title: "想去哪里,享受尊贵服务", style: UIBarButtonItemStyle.Done, target: self, action: "choiceCity:")
      item2.tintColor = UIColor.ZKJS_navegationTextColor()
      super.navigationItem.leftBarButtonItems = [item1,item2]
      super.navigationController?.navigationBar.tintColor = UIColor.ZKJS_mainColor()
        // Do any additional setup after loading the view.
    }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("ComprehensiveVC", owner:self, options:nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    self.hidesBottomBarWhenPushed = false
    navigationController?.navigationBarHidden = false
    getDataWithPage(orderPage)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    //self.hidesBottomBarWhenPushed = false
  }
  
  func loadMoreData() {
    orderPage++
    getDataWithPage(orderPage)
  }
  func refreshData() {
    orderPage = 1
    getDataWithPage(1)
    
  }
  
  func choiceCity(sender:UIBarButtonItem) {
    let vc = CityVC()
    vc.testClosure = myClosure
    let nav = UINavigationController(rootViewController: vc)
    navigationController?.presentViewController(nav, animated: true, completion: nil)
  }
  
  //定义一个带字符串参数的闭包
  func myClosure(testStr:String)->Void{
    item2.title = testStr
    self.getDataWithPage(1)
  }
  
  private func getDataWithPage(page: Int) {
    ZKJSJavaHTTPSessionManager.sharedInstance().getShopListWithCity(item2.title, page:String(page), size: "10", success: { (task:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
      if let array = responseObject as? NSArray {
        if array.count == 0 {
          self.tableView.mj_footer.endRefreshingWithNoMoreData()
          self.tableView.mj_header.endRefreshing()
        } else {
          if page == 1 {
            self.dataArray.removeAll()
          }
          for dic in array {
            let hotel = Hotel(dic: dic as! [String:AnyObject])
            self.dataArray.append(hotel)
          }
          self.hideHUD()
          self.tableView.reloadData()
          self.tableView.mj_footer.endRefreshing()
        }
        self.tableView.mj_header.endRefreshing()
      }
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        
    }
  }
  
  
  // MARK: - Table view data source
  
   func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return dataArray.count
  }
  
   func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.row == 0 {
      return HotelCell.height()
    } else {
      return 385
    }
    
  }
  
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(HotelCell.reuseIdentifier(), forIndexPath: indexPath) as! HotelCell
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    let shop = dataArray[indexPath.row]
    cell.setData(shop)
    
    return cell
  }
  
   func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
    let hotel = self.dataArray[indexPath.row]
    if type == .chat {
      let storyboard = UIStoryboard(name: "BookingOrder", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("BookingOrderTVC") as! BookingOrderTVC
      
      vc.shopID = hotel.shopid
      self.navigationController?.pushViewController(vc, animated: true)
    }else if type == .customerService {
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
        self.hideHUD()
        self.item2.title = city?.stringByReplacingOccurrencesOfString("市", withString:"")
        self.getDataWithPage(1)
      }
    }
  }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
