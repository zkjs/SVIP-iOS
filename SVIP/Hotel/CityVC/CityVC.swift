//
//  CityVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/14.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit
import CoreLocation
typealias sendValueClosure=(string:String)->Void

class CityVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
  var myView:CityHeaderView!
  let locationManager:CLLocationManager = CLLocationManager()
  var longitude: double_t!
  var latution: double_t!
  var cityArray = [String]()
  let citySearchBar = UISearchBar()
  
  var historyArray = [String]()
//  //声明一个闭包
//  var testClosure:sendValueClosure?
//  var city:String!
  
  @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
     navigationController?.navigationBarHidden = false
      let image = UIImage(named: "ic_fanhui_orange")
      let item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: "miss:")
      item1.tintColor = UIColor.ZKJS_mainColor()
         self.navigationItem.leftBarButtonItem = item1
      
      let mainViewBounds = self.navigationController?.view.bounds
      citySearchBar.frame = CGRectMake(40, CGRectGetMinY(mainViewBounds!)+20, self.navigationController!.view.bounds.size.width-70, 40)
      citySearchBar.barTintColor = UIColor.ZKJS_whiteColor()
      citySearchBar.placeholder = "搜索"
      citySearchBar.searchBarStyle = UISearchBarStyle.Minimal
      citySearchBar.delegate = self
      
      let nibName = UINib(nibName: HotCityCell.nibName(), bundle: nil)
      tableView.registerNib(nibName, forCellReuseIdentifier: HotCityCell.reuseIdentifier())                                                            
      tableView.tableFooterView = UIView()
      self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
      
      
      if tableView.respondsToSelector(Selector("setSeparatorInset:")) {
        tableView.separatorInset = UIEdgeInsetsZero
      }
      if tableView.respondsToSelector(Selector("setLayoutMargins:")) {
        tableView.layoutMargins = UIEdgeInsetsZero
      }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
   func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    if cell.respondsToSelector(Selector("setSeparatorInset:")) {
      cell.separatorInset = UIEdgeInsetsZero
    }
    if cell.respondsToSelector(Selector("setLayoutMargins:")) {
      cell.layoutMargins = UIEdgeInsetsZero
    }
  }
  
  // 搜索代理UISearchBarDelegate方法，点击虚拟键盘上的Search按钮时触发
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    let vc = MerchantsVC()
    vc.city = searchBar.text!
    navigationController?.pushViewController(vc, animated: true)
    searchBar.resignFirstResponder()
    self.historyArray.insert(searchBar.text!, atIndex: 0)
    StorageManager.sharedInstance().saveHistoryArray(self.historyArray)
    self.tableView.reloadData()
  }
  
  
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    view.endEditing(true)
  }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("CityVC", owner:self, options:nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    
    self.navigationController?.view.addSubview(citySearchBar)
    getCityListData()
    setupCoreLocationService()
    tableView.reloadData()
    self.historyArray = StorageManager.sharedInstance().historyArray()
  }
  
  override func viewWillDisappear(animated: Bool) {
    citySearchBar.removeFromSuperview()
  }
  
  func miss(sender:UIBarButtonItem) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  func getCityListData() {
    /*ZKJSHTTPSessionManager.sharedInstance().getCityListSuccess({ (task: NSURLSessionDataTask!, responsObject: AnyObject!) -> Void in
      if let array = responsObject as? NSArray {
        self.cityArray.removeAll()
        for dic in array {
          let string = dic["city"] as! String
          self.cityArray.append(string)
        }
        self.tableView.reloadData()
      }
      }) { (task:NSURLSessionDataTask!, error: NSError!) -> Void in
        print(error.description)
    }*/
  }
  
  
  //MARK -TableView Data Source
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return cityArray.count
    } else {
      let array = StorageManager.sharedInstance().historyArray()
      if array.count > 4 {
        return 4
      } else {
        let array = StorageManager.sharedInstance().historyArray()
        return array.count
      }
      
    }
    
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 50
    } else {
      return 30
    }
    
  }
  
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 50
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier(HotCityCell.reuseIdentifier(), forIndexPath: indexPath) as! HotCityCell
      cell.selectionStyle = UITableViewCellSelectionStyle.None
    if indexPath.section == 0 {
      cell.textLabel?.text = cityArray[indexPath.row]
    }
    if indexPath.section == 1 {
      let array = StorageManager.sharedInstance().historyArray()
      cell.textLabel?.text = array[indexPath.row]
    }
      return cell
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 {
      myView = NSBundle.mainBundle().loadNibNamed("CityHeaderView", owner: self, options: nil).first as! CityHeaderView
      return myView
    } else {
      let label = UILabel()
      label.frame = CGRectMake(20, -10, 100, 20)
      label.text = "     历史记录"
      label.font = UIFont(name: label.font.fontName, size: 12)
      return label
    }
    
    }
  
  func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footerView = UIView()
    return footerView
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 1
  }
  
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let vc = MerchantsVC()
    if indexPath.section == 0 {
     vc.city = cityArray[indexPath.row]
    }
    if indexPath.section == 1 {
      vc.city = historyArray[indexPath.row]
    }
    
    
    navigationController?.pushViewController(vc, animated: true)
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
        self.myView.locationCityLabel.text = city
      }
    }
  }
}

extension CityVC: CLLocationManagerDelegate {
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