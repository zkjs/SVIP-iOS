//
//  MerchantsVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/17.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class MerchantsVC: UIViewController {
  lazy var type = ComprehensiveType.chat
  var btnGoBack = UIBarButtonItem()
  var btnCityName = UIBarButtonItem()
  var city = ""
  var viewModel = ShopViewModel(city: nil, strategy: nil)

  @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
      tableView.tableFooterView = UIView()
      tableView.showsVerticalScrollIndicator = false
      let nibName = UINib(nibName: HotelCell.nibName(), bundle: nil)
      tableView.registerNib(nibName, forCellReuseIdentifier: HotelCell.reuseIdentifier())
      let nibName1 = UINib(nibName: RecommandCell.nibName(), bundle: nil)
      tableView.registerNib(nibName1, forCellReuseIdentifier: RecommandCell.reuseIdentifier())
      
      tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: "refreshData")  // 下拉刷新
      tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "loadMoreData")  // 上拉加载
      
      let image = UIImage(named: "ic_fanhui_orange")
      btnGoBack = UIBarButtonItem(image: image, style:.Done, target: self, action: "backToView:")
      btnCityName = UIBarButtonItem(title: city, style: UIBarButtonItemStyle.Done, target: self, action:"backToView:")
      btnCityName.tintColor = UIColor.ZKJS_navegationTextColor()
      super.navigationItem.leftBarButtonItems = [btnGoBack,btnCityName]
      super.navigationController?.navigationBar.tintColor = UIColor.ZKJS_mainColor()
        // Do any additional setup after loading the view.
      
      if tableView.respondsToSelector(Selector("setSeparatorInset:")) {
        tableView.separatorInset = UIEdgeInsetsZero
      }
      if tableView.respondsToSelector(Selector("setLayoutMargins:")) {
        tableView.layoutMargins = UIEdgeInsetsZero
      }
      
      viewModel.setCity(city) { (hasMore, error) -> Void in
        self.handlerResult(hasMore, error: error)
      }
    }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("MerchantsVC", owner:self, options:nil)
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
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
  
   func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    if cell.respondsToSelector(Selector("setSeparatorInset:")) {
      cell.separatorInset = UIEdgeInsetsZero
    }
    if cell.respondsToSelector(Selector("setLayoutMargins:")) {
      cell.layoutMargins = UIEdgeInsetsZero
    }
  }
  
  func backToView(sender:UIBarButtonItem) {
    navigationController?.popViewControllerAnimated(true)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  func loadMoreData() {
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
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
    let shop = viewModel.data[indexPath.row]
    if shop.shopid.isEmpty { return }
    if type == .chat {
      guard let shopid = Int(shop.shopid) else { return }
      
      let storyboard = UIStoryboard(name: "BusinessDetailVC", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("BusinessDetailVC") as! BusinessDetailVC
      
      vc.shopid = shopid
      vc.shopName = shop.shopname
      vc.saleid = shop.salesid
      vc.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(vc, animated: true)

    } else if type == .customerService {
      let vc = CustomerServiceTVC()
      vc.shopID = shop.shopid
      self.navigationController?.pushViewController(vc, animated: true)
    }
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
}
