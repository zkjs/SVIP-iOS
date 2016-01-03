//
//  BusinessDetailTVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/29.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit
protocol PhotoViewerDelegate {
  func gotoPhotoViewerDelegate(brower:MWPhotoBrowser)
}
class BusinessDetailTVC: UITableViewController,EDStarRatingProtocol, MWPhotoBrowserDelegate {
  
  @IBOutlet weak var scrollView: UIScrollView! {
    didSet {
      scrollView.bounces = false
      scrollView.pagingEnabled = true
      scrollView.delegate = self
      scrollView.showsHorizontalScrollIndicator = false
    }
  }
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var telphoneLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var webView: UIWebView! {
    didSet {
      webView.scrollView.scrollEnabled = false
    }
  }
  var delegate:PhotoViewerDelegate?
  var scheduledButton = UIButton()
  var shopid: NSNumber!
  var shopName: String!
  var saleid: String!

  var shopDetail = DetailModel()
  var timer = NSTimer()
  var imgUrlArray = NSArray()
  var originOffsetY: CGFloat = 0.0
  var photosArray = NSMutableArray()
  var photo = MWPhoto()
  var thumb = MWPhoto()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        title = shopName
      self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
      self.navigationController!.navigationBar.shadowImage = UIImage()
      navigationController?.navigationBar.translucent = true
      self.tableView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0)
      
    }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.translucent = true
    loadData()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.translucent = false
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  
  func advanceOrder() {
    let storyboard = UIStoryboard(name: "HotelOrderTVC", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("HotelOrderTVC") as! HotelOrderTVC
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func loadData() {
    ZKJSJavaHTTPSessionManager.sharedInstance().getOrderDetailWithShopID(String(shopid), success: { (task:NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      if let dict = responsObject as? NSDictionary {
        self.shopDetail = DetailModel(dic: dict)
        self.imgUrlArray = self.shopDetail.images
      }
      self.setupUI()
      self.tableView.reloadData()
      }) { (task:NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  func setupUI() {
    addressLabel.text = shopDetail.address
    telphoneLabel.text = shopDetail.telephone
    timer = NSTimer.scheduledTimerWithTimeInterval(3.5, target: self, selector: "runTimePage", userInfo: nil, repeats: true)
    let count = shopDetail.images.count
    pageControl.addTarget(self, action: "turnPage", forControlEvents: UIControlEvents.ValueChanged)
    pageControl.numberOfPages = imgUrlArray.count
    pageControl.currentPage = 0
    for var i = 0; i < shopDetail.images.count; i++ {
      let imgView = BrowserImageView()
      imgView.addTarget(self, action: "photoViewer")
      imgView.contentMode = UIViewContentMode.ScaleToFill
      let url = NSURL(string: shopDetail.images[i] as! String)
      imgView.sd_setImageWithURL(url, placeholderImage: nil)
      self.photo = MWPhoto(URL: url!)
      self.photosArray.addObject(photo)
      imgView.frame = CGRectMake(CGFloat(i+1) * view.bounds.size.width, 0, view.frame.size.width, 400)
      self.scrollView.addSubview(imgView)
    }
    //取数组最后一张图片 放在第0页
    var imageView = BrowserImageView(frame: CGRectMake(0, 0, view.bounds.size.width, 400))
     imageView.addTarget(self, action: "photoViewer")
    let url = NSURL(string: shopDetail.images[count - 1] as! String)
    imageView.sd_setImageWithURL(url, placeholderImage: nil)
    scrollView.addSubview(imageView)
    // 取数组第一张图片 放在最后1页
    imageView = BrowserImageView(frame: CGRectMake(CGFloat(count + 1)*view.bounds.size.width, 0, view.bounds.size.width, 400))
     imageView.addTarget(self, action: "photoViewer")
    let Url = NSURL(string: shopDetail.images[0] as! String)
    imageView.sd_setImageWithURL(Url, placeholderImage: nil)
    scrollView.addSubview(imageView)
    scrollView.contentSize = CGSizeMake(view.bounds.size.width * CGFloat(count + 2), 400)//  +上第1页和第4页  原理：4-[1-2-3-4]-1
    scrollView.contentOffset = CGPointMake(0.0, 0.0)
    scrollView.scrollRectToVisible(CGRectMake(view.bounds.size.width, 0, view.bounds.size.width, 400), animated: false)
  }
  
  // pagecontrol 选择器的方法
  func turnPage() {
    let page = pageControl.currentPage
    self.scrollView.scrollRectToVisible(CGRectMake(view.bounds.size.width * CGFloat(page+1), 0, view.bounds.size.width, 400), animated: true)
  }
  
  // 定时器 绑定的方法
  func runTimePage() {
    var page = pageControl.currentPage
    page++
    page = page > imgUrlArray.count - 1 ? 0 : page
    pageControl.currentPage = page
    self.turnPage()
  }
  
  //MARK: - ScrollView Delegate
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    let pageWidth:CGFloat = scrollView.frame.size.width
    if imgUrlArray.count != 0 {
      var page = Int((self.scrollView.contentOffset.x - pageWidth/(CGFloat(shopDetail.images.count+2)))/pageWidth) + 1
      page--
      pageControl.currentPage = page
    }
    let color = UIColor.ZKJS_whiteColor()
    let offsetY = scrollView.contentOffset.y
    if (offsetY > 50) {
      let alpha = min(1, 1 - ((50 + 64 - offsetY) / 64))
    self.navigationController?.navigationBar.lt_setBackgroundColor(color.colorWithAlphaComponent(alpha))
    } else {
      self.navigationController?.navigationBar.lt_setBackgroundColor(color.colorWithAlphaComponent(0))
    }
   
  }
  
  override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
  
     let pageWidth:CGFloat = scrollView.frame.size.width
    if imgUrlArray.count != 0 {
      let currentPage = Int((self.scrollView.contentOffset.x - pageWidth/(CGFloat(shopDetail.images.count+2)))/pageWidth) + 1
      if currentPage == 0 {
        self.scrollView.scrollRectToVisible(CGRectMake(view.bounds.size.width * CGFloat(shopDetail.images.count), 0, view.bounds.size.width, 400), animated: true)
      }
      if currentPage == shopDetail.images.count + 1 {
        self.scrollView.scrollRectToVisible(CGRectMake(view.bounds.size.width , 0, view.bounds.size.width, 400), animated: true)
      }
}
    }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    if indexPath.section == 2 {
      //评价
      let starRating = EDStarRating()
      starRating.frame = CGRectMake(view.bounds.size.width/2, 2, 100, 45)
      starRating.backgroundColor = UIColor.whiteColor()
      starRating.starImage = UIImage(named: "ic_star_nor")
      starRating.starHighlightedImage = UIImage(named: "ic_star_pre")
      starRating.maxRating = 5
      starRating.delegate = self
      starRating.horizontalMargin = 12
      if let score = self.shopDetail.score {
        starRating.rating = score.floatValue
      }
      
      cell.addSubview(starRating)
    }
    return cell
  }
  
  func photoViewer() {
    let browser = MWPhotoBrowser(delegate: self)
    
    browser.displayActionButton = false
    browser.displayNavArrows = false
    browser.displaySelectionButtons = false
    browser.alwaysShowControls = false
    browser.zoomPhotosToFill = true
    browser.enableGrid = true
    browser.startOnGrid = true
    browser.enableSwipeToDismiss = false
    browser.setCurrentPhotoIndex(0)
    self.delegate?.gotoPhotoViewerDelegate(browser)

  }
  
  func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
    return UInt(imgUrlArray.count)
  }
  
  func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
    if index < UInt(self.photosArray.count) {
      return self.photosArray.objectAtIndex(Int(index)) as! MWPhotoProtocol
    }
    return nil
  }
  
}
