//
//  OrderDetailsVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/2.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class OrderDetailsVC: UIViewController,EDStarRatingProtocol {
  
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
      starRating.frame = CGRectMake(20, 10, self.view.bounds.width/1.3, 60)
      starRating.backgroundColor = UIColor.whiteColor()
      starRating.starImage = UIImage(named: "ic_star_nor")
      starRating.starHighlightedImage = UIImage(named: "ic_star_pre")
      starRating.maxRating = 5
      starRating.delegate = self
      starRating.horizontalMargin = 12
      starRating.editable = true
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
    if score == 2.0 {
      evaluateLabel.text = "满意"
    }
    if score == 2.0 {
      evaluateLabel.text = "非常满意"
    }
    if score == 2.0 {
      evaluateLabel.text = "强烈推荐"
    }
    
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  @IBAction func submit(sender: AnyObject) {
    ZKJSHTTPSessionManager.sharedInstance().submitEvaluationWithScore(NSString(format: "%f", score) as String, content: nil, reservation_no: order.reservation_no, success: { (task: NSURLSessionDataTask!, responObject: AnyObject!) -> Void in
      let dic = responObject as! NSDictionary
      let set = dic["set"] as? Bool
      if (set == true) {
        self.navigationController?.popViewControllerAnimated(true)
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
}
