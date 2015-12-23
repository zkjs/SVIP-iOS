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

class CityVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
  var myView:CityHeaderView!
  let locationManager:CLLocationManager = CLLocationManager()
  var longitude: double_t!
  var latution: double_t!
  var cityArray = [String]()
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
      let leftBarBtn = UIBarButtonItem(title: "想去哪里", style: .Plain, target: self,
        action:nil)
      leftBarBtn.tintColor = UIColor.ZKJS_navegationTextColor()
      self.navigationItem.leftBarButtonItems = [item1,leftBarBtn]
      let nibName = UINib(nibName: HotCityCell.nibName(), bundle: nil)
      tableView.registerNib(nibName, forCellReuseIdentifier: HotCityCell.reuseIdentifier())                                                            
      tableView.tableFooterView = UIView()
      self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("CityVC", owner:self, options:nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    getCityListData()
    setupCoreLocationService()
    tableView.reloadData()
  }
  
  func miss(sender:UIBarButtonItem) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  func getCityListData() {
    ZKJSHTTPSessionManager.sharedInstance().getCityListSuccess({ (task: NSURLSessionDataTask!, responsObject: AnyObject!) -> Void in
      if let array = responsObject as? NSArray {
//        print(array)
        self.cityArray.removeAll()
        for dic in array {
          let string = dic["city"] as! String
          self.cityArray.append(string)
        }
//        print(self.cityArray.count)
        self.tableView.reloadData()
      }
      }) { (task:NSURLSessionDataTask!, error: NSError!) -> Void in
        print(error.description)
    }
  }
  
  
  //MARK -TableView Data Source
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cityArray.count
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
    
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 50
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier(HotCityCell.reuseIdentifier(), forIndexPath: indexPath) as! HotCityCell
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      cell.textLabel?.text = cityArray[indexPath.row]
      return cell
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    myView = NSBundle.mainBundle().loadNibNamed("CityHeaderView", owner: self, options: nil).first as! CityHeaderView
    return myView
    }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let vc = MerchantsVC()
    vc.city = cityArray[indexPath.row]
    print(vc.city)
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