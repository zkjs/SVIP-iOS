//
//  MerchantsVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/17.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class MerchantsVC: UIViewController {
  var dataArray = [Hotel]()
  lazy var type = ComprehensiveType.chat
  var item1 = UIBarButtonItem()
  var item2 = UIBarButtonItem()
  var city = String()
  var MerchantsPage = 1
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
      item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: "backToView:")
      item2 = UIBarButtonItem(title: city, style: UIBarButtonItemStyle.Done, target: self, action:nil)
      item2.tintColor = UIColor.ZKJS_navegationTextColor()
      super.navigationItem.leftBarButtonItems = [item1,item2]
      super.navigationController?.navigationBar.tintColor = UIColor.ZKJS_mainColor()
        // Do any additional setup after loading the view.
    }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("MerchantsVC", owner:self, options:nil)
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func backToView(sender:UIBarButtonItem) {
    navigationController?.popViewControllerAnimated(true)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    getDataWithPage(1)
  }
  
  func loadMoreData() {
    MerchantsPage++
    getDataWithPage(MerchantsPage)
  }
  
  func refreshData() {
    getDataWithPage(1)
  }
  
  private func getDataWithPage(page: Int) {
    if AccountManager.sharedInstance().isLogin() {
      ZKJSJavaHTTPSessionManager.sharedInstance().getShopListWithCity(city, page:String(page), size: "10", success: { (task:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
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
    } else {
      ZKJSJavaHTTPSessionManager.sharedInstance().getLoginOutShopListWithCity(city, page:String(page), size: "10", success: { (task:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
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
      cell.userImageButton.addTarget(self, action: "pushToDetail:", forControlEvents: UIControlEvents.TouchUpInside)
      return cell
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
    let hotel = self.dataArray[indexPath.row]
    if type == .chat {
      let storyboard = UIStoryboard(name: "BusinessDetailVC", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("BusinessDetailVC") as! BusinessDetailVC
      if hotel.shopid == "" {
        ZKJSTool.showMsg("暂无商家信息")
        return
      }
      vc.shopid = NSNumber(integer: Int(hotel.shopid)!)
      vc.shopName = hotel.shopname
      vc.saleid = hotel.salesid
      self.navigationController?.pushViewController(vc, animated: true)
    } else if type == .customerService {
      let vc = CustomerServiceTVC()
      vc.shopID = hotel.shopid
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
}
