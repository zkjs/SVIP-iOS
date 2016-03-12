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
  
  var btnChooseCity = UIBarButtonItem()
  let locationManager:CLLocationManager = CLLocationManager()
  var longitude: double_t!
  var latution: double_t!
  var cityArray = [String]()
  lazy var type = ComprehensiveType.chat
  var currentCity: String!
  var viewModel = ShopViewModel(city: nil, strategy: nil)

 
  
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
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    
    tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: "refreshData")  // 下拉刷新
    tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "loadMore")  // 上拉加载
    let footer = tableView.mj_footer
    footer.automaticallyHidden = false
    
    let image = UIImage(named: "ic_dingwei_orange")
    let item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: "choiceCity:")
//    item1.backgroundImageForState(UIControlState.Disabled, style: .Done, barMetrics: UIBarMetrics.Default) //以后打开搜索删掉这行
    btnChooseCity = UIBarButtonItem(title: "长沙本地服务", style: UIBarButtonItemStyle.Done, target: self, action:"choiceCity:")
    btnChooseCity.tintColor = UIColor.ZKJS_navTitleColor()
//    btnChooseCity.enabled = false //以后打开搜索删掉这行
    super.navigationItem.leftBarButtonItems = [item1,btnChooseCity]
    super.navigationController?.navigationBar.tintColor = UIColor.ZKJS_mainColor()
   // setupCoreLocationService()
    
    viewModel.load { (hasMore, error) -> Void in
      self.hideHUD()
      self.handlerResult(hasMore, error: error)
    }
  }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("ComprehensiveVC", owner:self, options:nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    self.navigationController?.navigationBar.translucent = false
    self.hidesBottomBarWhenPushed = false
    navigationController?.navigationBarHidden = false
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  func handlerResult(hasMore:Bool, error:NSError?) {
    if let _ = error {
      self.showHint("访问服务器失败")
    } else {
      if !hasMore {
        self.tableView.mj_footer.hidden = true
      }
      self.tableView.mj_footer.endRefreshing()
      self.tableView.mj_header.endRefreshing()
      self.tableView.reloadData()
    }
  }
  
  func loadMore() {
    viewModel.next { (hasMore, error) -> Void in
      self.handlerResult(hasMore, error: error)
    }
  }
  
  func refreshData() {
    self.tableView.mj_footer.hidden = false
    viewModel.load(0) { (hasMore, error) -> Void in
      self.handlerResult(hasMore, error: error)
    }
  }
  
  func choiceCity(sender:UIBarButtonItem) {
    let vc = CityVC()
    let nav = BaseNC(rootViewController: vc)
    navigationController?.presentViewController(nav, animated: true, completion: nil)
  }
  
  // MARK: - Table view data source
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return viewModel.data.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return HotelCell.height()
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(HotelCell.reuseIdentifier(), forIndexPath: indexPath) as! HotelCell
    cell.configCell(viewModel.data[indexPath.row]) {[weak self] () -> Void in
      if let strongSelf = self {
        strongSelf.pushToSalesmanDetail(indexPath)
      }
    }
    return cell
  }
  
  func pushToSalesmanDetail(indexPath:NSIndexPath) {
    if viewModel.data.count <= indexPath.row { return }
    let shop = viewModel.data[indexPath.row]
    if shop.salesid.isEmpty { return }
    let vc = SalesDetailVC()
    vc.salesid = shop.salesid
    vc.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
    let shop = viewModel.data[indexPath.row]
    if shop.shopid.isEmpty { return }
    guard let shopid = Int(shop.shopid) else { return }
    
    let storyboard = UIStoryboard(name: "BusinessDetailVC", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("BusinessDetailVC") as! BusinessDetailVC
    
    vc.shopid = shopid
    vc.shopName = shop.shopname
    vc.saleid = shop.salesid
    vc.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(vc, animated: true)

  }
}
