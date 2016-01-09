//
//  OrderDetailsVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/2.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class OrderDetailsVC: UIViewController,EDStarRatingProtocol {
  
  @IBOutlet weak var remark: UITextView!
  @IBOutlet weak var evaluateLabel: UILabel!
  var order = OrderModel()
  var score = Float()
  var orderV = UIView()
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("OrderDetailsVC", owner:self, options:nil)
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      title = "订单详情"
      //评价
      let starRating = EDStarRating()
      starRating.frame = CGRectMake(20, 10, self.view.bounds.width/1.7, 60)
      starRating.backgroundColor = UIColor.whiteColor()
      starRating.starImage = UIImage(named: "ic_star_nor")
      starRating.starHighlightedImage = UIImage(named: "ic_star_pre")
      starRating.maxRating = 5
      starRating.rating = 1
      starRating.delegate = self
      starRating.horizontalMargin = 12
      starRating.editable = true
      view.addSubview(starRating)
        // Do any additional setup after loading the view.
    }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    }
  
  
  //MARK -EDStarRating Protocol
  func starsSelectionChanged(control: EDStarRating!, rating: Float) {
    score = rating
    if score == 1.0 {
      evaluateLabel.text = "差"
    }
    if score == 2.0 {
      evaluateLabel.text = "一般"
    }
    if score == 3.0 {
      evaluateLabel.text = "满意"
    }
    if score == 4.0 {
      evaluateLabel.text = "非常满意"
    }
    if score == 5.0 {
      evaluateLabel.text = "强烈推荐"
    }
    
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  @IBAction func submit(sender: AnyObject) {
    
    let userID = AccountManager.sharedInstance().userID
    var dic = [String: AnyObject]()
    dic["id"] = ""
    dic["orderNo"] = order.reservation_no
    dic["score"] = score
    dic["content"] = self.remark.text
    dic["createDate"] = ""
    dic["userid"] = userID
    showHUDInView(view, withLoading: "")
    ZKJSJavaHTTPSessionManager.sharedInstance().evaluationWithData(dic, success: { (task: NSURLSessionDataTask!, responsObjects: AnyObject!) -> Void in
      self.hideHUD()
      if let dic = responsObjects as? NSDictionary {
        if let result = dic["result"] as? NSNumber {
          if result.boolValue == true {
            self.navigationController?.popToRootViewControllerAnimated(true)
          }
        }
      }
      }) { (task:NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
}
