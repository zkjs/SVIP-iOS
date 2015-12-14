//
//  ComprehensiveVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/10.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit
@objc enum ComprehensiveType: Int {
  case chat
  case customerService
}
class ComprehensiveVC: UIViewController {
  var shops = [NSDictionary]()
  var dataArray = NSMutableArray()
  lazy var type = ComprehensiveType.chat
  
  @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
      tableView.tableFooterView = UIView()
      tableView.showsVerticalScrollIndicator = false
      let nibName = UINib(nibName: HotelCell.nibName(), bundle: nil)
      tableView.registerNib(nibName, forCellReuseIdentifier: HotelCell.reuseIdentifier())
      let item1 = UIBarButtonItem(image: UIImage(named: "ic_dingwei_orange"), style:.Plain, target: self, action: "popTotopView:")
      navigationController?.navigationItem.leftBarButtonItem = item1
      loadData()
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
    //self.hidesBottomBarWhenPushed = false
  }
  
  private func loadData() {
    ZKJSHTTPSessionManager .sharedInstance() .getAllShopInfoWithPage(1, key: nil, isDesc: true, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let array = responseObject as? NSArray {
        for dic in array {
          let hotelData = Hotel(dic: dic as! NSDictionary)
          self.dataArray .addObject(hotelData)
        }
        self.tableView .reloadData()
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        self.showHint("加载数据失败")
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
    return HotelCell.height()
  }
  
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(HotelCell.reuseIdentifier(), forIndexPath: indexPath) as! HotelCell
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    let shop = dataArray[indexPath.row]
    cell.setData(shop as! Hotel)
    
    return cell
  }
  
   func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
    if type == .chat {
      let storyboard = UIStoryboard(name: "BookingOrder", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("BookingOrderTVC") as! BookingOrderTVC
      vc.shopID = NSNumber(integer: Int((dataArray[indexPath.row] as! Hotel).shopid))
      self.navigationController?.pushViewController(vc, animated: true)
    }else if type == .customerService {
      let vc = CustomerServiceTVC()
      vc.shopID = NSNumber(integer: Int((dataArray[indexPath.row] as! Hotel).shopid))
      self.navigationController?.pushViewController(vc, animated: true)
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
