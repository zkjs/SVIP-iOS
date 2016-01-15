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
    let footer = tableView.mj_footer
    footer.automaticallyHidden = false
    
    let image = UIImage(named: "ic_search_orange")
    let item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: "choiceCity:")
    item2 = UIBarButtonItem(title: "想去哪里,享受尊贵服务", style: UIBarButtonItemStyle.Done, target: self, action: "choiceCity:")
    item2.tintColor = UIColor.ZKJS_navegationTextColor()
    super.navigationItem.leftBarButtonItems = [item1,item2]
    super.navigationController?.navigationBar.tintColor = UIColor.ZKJS_mainColor()
   // setupCoreLocationService()
  }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("ComprehensiveVC", owner:self, options:nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    loadShopListData(orderPage)
    self.navigationController?.navigationBar.translucent = false
    self.hidesBottomBarWhenPushed = false
    navigationController?.navigationBarHidden = false
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  func loadMore() {
    loadShopListData(orderPage)
  }
  
  func refreshData() {
    orderPage = 1
    loadShopListData(orderPage)
   // setupCoreLocationService()
  }
  
  func choiceCity(sender:UIBarButtonItem) {
    let vc = CityVC()
    let nav = BaseNC(rootViewController: vc)
    navigationController?.presentViewController(nav, animated: true, completion: nil)
  }
  
  private func loadShopListData(page: Int) {
    let stats = AccountManager.sharedInstance().isLogin()
    if stats == true {
      //获取所有商家列表(登陆时的数据)
      ZKJSJavaHTTPSessionManager.sharedInstance().getShopListWithPage(String(orderPage),size:"10", success: { (task:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
        self.hideHUD()
        if let array = responseObject as? NSArray {
          if self.orderPage == 1 {
            self.dataArray.removeAll()
          }
          if array.count == 0 {
            self.tableView.mj_footer.hidden = true
          }
          for dic in array {
            let hotel = Hotel(dic: dic as! [String:AnyObject])
            self.dataArray.append(hotel)
          }
          print(self.dataArray.count)
          self.orderPage++
          self.tableView.reloadData()
        }
        self.tableView.mj_footer.endRefreshing()
        self.tableView.mj_header.endRefreshing()
        }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
          
      }

    } else {
      //获取所有商家列表(未登陆时的数据)
      ZKJSJavaHTTPSessionManager.sharedInstance().getLoginOutShopListWithPage(String(orderPage),size:"10", success: { (task:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
        self.hideHUD()
        if let array = responseObject as? NSArray {
          if self.orderPage == 1 {
            self.dataArray.removeAll()
          }
          for dic in array {
            let hotel = Hotel(dic: dic as! [String:AnyObject])
            self.dataArray.append(hotel)
          }
          self.orderPage++
          self.tableView.reloadData()
        }
        self.tableView.mj_footer.endRefreshing()
        self.tableView.mj_header.endRefreshing()
        }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
          
      }

    }
      }
  
  // MARK: - Table view data source
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return dataArray.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.row == 0 {
      return RecommandCell.height()
    }
    else {
      return HotelCell.height()
    }
    
    }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(RecommandCell.reuseIdentifier(), forIndexPath: indexPath) as! RecommandCell
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      let recommand = self.dataArray[0]
      cell.setdata(recommand)
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(HotelCell.reuseIdentifier(), forIndexPath: indexPath) as! HotelCell
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      cell.userImageButton.tag = indexPath.row
      let shop = dataArray[indexPath.row]
      cell.setData(shop)
      return cell
}
  }
  
  func pushToDetail(sender:UIButton) {
    let vc = SalesDetailVC()
    let hotel = dataArray[sender.tag]
    vc.salesid = hotel.salesid
    vc.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
    let hotel = dataArray[indexPath.row]
    if indexPath.row == 0 {
      let web = WebViewVC()
      web.url = hotel.shopaddress
      web.hidesBottomBarWhenPushed = true
      self.navigationController?.pushViewController(web, animated: true)
    } else {
      let storyboard = UIStoryboard(name: "BusinessDetailVC", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("BusinessDetailVC") as! BusinessDetailVC
      let hotel = self.dataArray[indexPath.row]
      if hotel.shopid == "" {
        return
      }
      vc.shopid = NSNumber(integer: Int(hotel.shopid)!)
      vc.shopName = hotel.shopname
      vc.saleid = hotel.salesid
      vc.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(vc, animated: true)
    }
  }
}
