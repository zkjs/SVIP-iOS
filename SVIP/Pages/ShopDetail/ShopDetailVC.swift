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
    tableView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0)
    self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "texture_bg")!)
    headerView.backgroundColor = UIColor(patternImage: UIImage(named: "texture_bg")!)
    tableView.separatorStyle = .None
    
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 365.0
    
    let swipeGesture = UISwipeGestureRecognizer(target: self, action: "popToHomeVC:")
    swipeGesture.direction = .Right
    self.view.addGestureRecognizer(swipeGesture)
    
    let backButton = UIBarButtonItem(image: UIImage(named: "ic_fanhui_orange"), style: UIBarButtonItemStyle.Plain, target: self, action: "popToHomeVC")
    self.navigationItem.leftBarButtonItem = backButton
    
    loadData()
    title = "商家详情"
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = false
    navigationController?.navigationBar.translucent = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.translucent = false
  }
  
  func popToHomeVC(gestureRecognizer:UISwipeGestureRecognizer) {
    if gestureRecognizer.state != .Ended {
      return
    }
    popToHomeVC()
  }
  
  func popToHomeVC() {
    UIView.transitionWithView((self.navigationController?.view)!, duration: 0.8, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: { () -> Void in
      self.navigationController?.popViewControllerAnimated(false)
      }, completion: nil)
  }
  
 
  func setupView() {
    title = shopDetail.shopname
    shoplogoImageView.sd_setImageWithURL(NSURL(string: shopDetail.shopbg.fittedImageUrl), placeholderImage: UIImage(named: "img_shangjia"))
    shopnameLabel.text = shopDetail.shopname
    shopAddressLabel.text = shopDetail.shopaddress
    phoneLabel.text = shopDetail.telephone
  }
  
  func loadData() { 
    showHUDInTableView(tableView, withLoading: "")
    HttpService.sharedInstance.getShopDetail { (shopDetail, error) -> Void in
      self.hideHUD()
      if let error = error {
        self.showErrorHint(error)
      } else {
        self.shopDetail = shopDetail 
        self.shopDetailArray = self.shopDetail.shopmods
        self.setupView()
        self.tableView.reloadData()
      }
    }
  }
  
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
  
  func gotoPhotoViewerDelegate(Brower:AnyObject) {
    self.navigationController?.pushViewController(Brower  as! UIViewController , animated: true)
  }
  
  
  //MARK: - ScrollView Delegate
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    let color = UIColor.ZKJS_mainColor()
    let offsetY = scrollView.contentOffset.y
    if (offsetY > 50) {
      let alpha = min(1, 1 - ((50 + 64 - offsetY) / 64))
      navigationController?.navigationBar.yj_setBackgroundColor(color.colorWithAlphaComponent(alpha))
      navigationItem.titleView?.alpha = alpha
    } else {
      navigationController?.navigationBar.yj_setBackgroundColor(color.colorWithAlphaComponent(0))
      navigationItem.titleView?.alpha = 0
    }
  }
  
}
