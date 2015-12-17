//
//  OrderDetailsVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/2.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class OrderDetailsVC: UIViewController,EDStarRatingProtocol {
  var order = OrderModel()
  var score = Float()
  

  @IBOutlet weak var remarkTextField: UITextField!
  @IBOutlet weak var submitButton: UIButton! {
    didSet {
      submitButton.layer.masksToBounds = true
      submitButton.layer.cornerRadius = 20
    }
  }

  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var userImageView: UIImageView! {
    didSet {
      userImageView.layer.masksToBounds = true
      userImageView.layer.cornerRadius = 45
    }
  }
  var orderV = UIView()
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("OrderDetailsVC", owner:self, options:nil)
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      title = "订单详情"
      //评价
      let starRating = EDStarRating()
      starRating.frame = CGRectMake(20, 550, self.view.bounds.width/1.7, 60)
      starRating.backgroundColor = UIColor.whiteColor()
      starRating.starImage = UIImage(named: "ic_star_nor")
      starRating.starHighlightedImage = UIImage(named: "ic_star_pre")
      starRating.maxRating = 5
      starRating.delegate = self
      starRating.horizontalMargin = 12
      
      scrollView.addSubview(starRating)
      starRating.rating = order.score.floatValue
      if order.score == 0 {
        starRating.editable = true
        scrollView.contentSize = CGSize(width:0,height:850)
      }else {
        starRating.editable = false
        scrollView.contentSize = CGSize(width:0,height:600)
      }
      
      scrollView.showsHorizontalScrollIndicator = false
      scrollView.showsVerticalScrollIndicator = false
      let orderV = NSBundle.mainBundle().loadNibNamed("OrderContentView", owner: self, options: nil).first as? OrderContentView
      orderV?.frame = CGRectMake(0, 214, self.view.bounds.width, 259)
      setupUI(orderV!)
      if orderV != nil {
        scrollView.addSubview(orderV!)
      }
      

        // Do any additional setup after loading the view.
    }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    }
  
  func setupUI(orderV:OrderContentView) {
    let hotelUrl = "\(kBaseURL)uploads/shops/\(order.shopid).png"
//    let userid = JSHAccountManager.sharedJSHAccountManager().userid
//    let urlString = "\(kBaseURL)uploads/users/\(userid).jpg"
//    userImageView.sd_setImageWithURL(NSURL(string: urlString), placeholderImage: UIImage(named: "img_hotel_zhanwei"))
    userImageView.image = AccountManager.sharedInstance().avatarImage
    usernameLabel.text = order.guest
    orderV.hotelNameLabel.text = order.fullname
    orderV.bedStulyLabel.text = order.room_type + "x" + order.rooms.stringValue
    orderV.room_priceLabel.text = "￥" + order.room_rate.stringValue
    orderV.startLabel.text = order.departure_date
    orderV.usernameLabel.text = order.guest
    orderV.hotelImage.sd_setImageWithURL(NSURL(string: hotelUrl), placeholderImage: UIImage(named: "img_hotel_zhanwei"))
    
    
  }
  
  //MARK -EDStarRating Protocol
  func starsSelectionChanged(control: EDStarRating!, rating: Float) {
    score = rating
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  @IBAction func submit(sender: AnyObject) {
    ZKJSHTTPSessionManager.sharedInstance().submitEvaluationWithScore(NSString(format: "%f", score) as String, content: remarkTextField.text, reservation_no: order.reservation_no, success: { (task: NSURLSessionDataTask!, responObject: AnyObject!) -> Void in
      let dic = responObject as! NSDictionary
      let set = dic["set"] as? Bool
      if (set == true) {
        self.navigationController?.popViewControllerAnimated(true)
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
    

}
