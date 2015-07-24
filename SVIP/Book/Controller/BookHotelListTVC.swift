//
//  BookHotelListTVC.swift
//  SVIP
//
//  Created by dai.fengyi on 15/7/22.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class BookHotelListCell: UITableViewCell {
  var hotelData: Hotel? {
    didSet {
      avatar .sd_setImageWithURL(NSURL(string: hotelData!.logoURL), placeholderImage: UIImage(named:"img_hotel_zhanwei"), options: SDWebImageOptions.LowPriority | SDWebImageOptions.RetryFailed, completed: nil)
      hotel.text = hotelData!.fullname
    }
  }
  @IBOutlet weak var avatar: UIImageView!
  @IBOutlet weak var hotel: UILabel!
  @IBOutlet weak var hotelInfo: UILabel!
  
//  func configureCell(hotelData: Hotel) {
//    avatar .sd_setImageWithURL(NSURL(string: hotelData.logoURL), placeholderImage: UIImage(named:"img_hotel_zhanwei"), options: SDWebImageOptions.LowPriority | SDWebImageOptions.RetryFailed, completed: nil)
//    hotel.text = hotelData.fullname
//  }
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    avatar.layer.cornerRadius = 40
    avatar.clipsToBounds = true
  }
}

class BookHotelListTVC: UITableViewController {
  var dataArray = NSMutableArray()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    self.tableView .registerNib(UINib(nibName: "BookHotelListCell", bundle: nil), forCellReuseIdentifier: "reuseIdentifier")
    self.tableView.tableFooterView = UIView()
    
    // Hanton
    title = "选择酒店"
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: NSSelectorFromString("dismissSelf"))
    
    loadData()
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
      ZKJSTool .showMsg("加载数据失败")
    }
  }
  //MARK: - Button Action
  // Hanton
  func dismissSelf() -> Void {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete method implementation.
    // Return the number of rows in the section.
    return dataArray.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 100
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! BookHotelListCell
    
    // Configure the cell...
    cell.hotelData = dataArray[indexPath.row] as? Hotel

    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
    let vc = BookVC()
    vc.shopid = (dataArray[indexPath.row] as? Hotel)!.shopid
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return NO if you do not want the specified item to be editable.
  return true
  }
  */
  
  /*
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  if editingStyle == .Delete {
  // Delete the row from the data source
  tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
  } else if editingStyle == .Insert {
  // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }
  }
  */
  
  /*
  // Override to support rearranging the table view.
  override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
  
  }
  */
  
  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return NO if you do not want the item to be re-orderable.
  return true
  }
  */
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.
  }
  */
  
}
