//
//  ShopDetailVC.swift
//  SVIP
//
//  Created by Qin Yejun on 4/6/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class ShopDetailVC: UITableViewController,PhotoViewerDelegate {
  
 
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var shopAddressLabel: UILabel!
  @IBOutlet weak var shopnameLabel: UILabel!
  @IBOutlet weak var shoplogoImageView: UIImageView!
  var shopDetailArray = [ShopmodsModel]() 
  var shopDetail: ShopDetailModel!
  var imgUrlArray = [String]()
  var photosArray = NSMutableArray()
  var photo = MWPhoto()
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.tableFooterView = UIView()
    tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
    self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "texture_bg")!)
    headerView.backgroundColor = UIColor(patternImage: UIImage(named: "texture_bg")!)
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    tableView.separatorColor = UIColor(hex: "#B8B8B8")
    //分割线往左移
    if tableView.respondsToSelector(Selector("setSeparatorInset:")) {
      tableView.separatorInset = UIEdgeInsetsZero
    }
    if tableView.respondsToSelector(Selector("setLayoutMargins:")) {
      tableView.layoutMargins = UIEdgeInsetsZero
    }
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 365.0

  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = true
    let swipeGesture = UISwipeGestureRecognizer(target: self, action: "popToHomeVC:")
    swipeGesture.direction = .Right
    self.view.addGestureRecognizer(swipeGesture)
    loadData()

  }
  
  func popToHomeVC(gestureRecognizer:UISwipeGestureRecognizer) {
    if gestureRecognizer.state != .Ended {
      return
    }
    let vc = HomeVC()
    UIView.transitionWithView((self.navigationController?.view)!, duration: 1.5, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: { () -> Void in
      self.navigationController?.pushViewController(vc, animated: false)
      }, completion: nil)
  }
  
 
  func setupView() {
    guard let url:String = shopDetail.shoplogo,let shopname:String = shopDetail.shopname,let shopAddress:String = shopDetail.shopaddress,phone:String = shopDetail.telephone else {return}
    shoplogoImageView.sd_setImageWithURL(NSURL(string: url.fullImageUrl))
    shopnameLabel.text = shopname
    shopAddressLabel.text = shopAddress
    phoneLabel.text = phone
    self.tableView.reloadData()
  }
  
  func loadData() { 
    showHUDInTableView(tableView, withLoading: "")
    HttpService.sharedInstance.getShopDetail { (shopDetail, error) -> Void in
      self.hideHUD()
      if let _ = error {
        
      } else {
        self.shopDetail = shopDetail 
        self.shopDetailArray = self.shopDetail.shopmods
        self.setupView()
        self.tableView.reloadData()
      }
    }
  }
  
  
   override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    if cell.respondsToSelector(Selector("setSeparatorInset:")) {
      cell.separatorInset = UIEdgeInsetsZero
    }
    if cell.respondsToSelector(Selector("setLayoutMargins:")) {
      cell.layoutMargins = UIEdgeInsetsZero
    }
  }
  
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  
  override   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return shopDetailArray.count
  }
  
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ShopDetailCell", forIndexPath: indexPath) as! ShopDetailCell
    let shopmod = shopDetail.shopmods[indexPath.row]
    cell.customImageView.userInteractionEnabled = true
    cell.delegate = self
    cell.configCell(shopmod)
    return cell
  }
  
//  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//    let cell = tableView.cellForRowAtIndexPath(indexPath) as! ShopDetailCell
//    let shopmod = shopDetail.shopmods[indexPath.row]
//    photosArray.removeAllObjects()
//
//    for image in shopmod.photos {
//      let url = NSURL(string: image)
//      self.photo = MWPhoto(URL: url!)
//      self.photosArray.addObject(photo)
//    }
//    let tapGR = UITapGestureRecognizer(target: self, action: "photoViewer:")
//    cell.customImageView.addGestureRecognizer(tapGR)
//  }
  func gotoPhotoViewerDelegate(Brower:AnyObject) {
    self.navigationController?.pushViewController(Brower  as! UIViewController , animated: true)
  }
 
  
}
