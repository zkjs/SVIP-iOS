//
//  OrderDetailsVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/2.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class OrderDetailsVC: UIViewController,EDStarRatingProtocol {

  @IBOutlet weak var scrollView: UIScrollView!
  var orderV = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
      title = "订单详情"
      navigationController?.navigationBar.tintColor = UIColor.clearColor()
      scrollView.contentSize = CGSize(width:0,height:700)
      scrollView.showsHorizontalScrollIndicator = false
      scrollView.showsVerticalScrollIndicator = false
      let orderV = NSBundle.mainBundle().loadNibNamed("OrderContentView", owner: self, options: nil).first as? OrderContentView
      orderV?.frame = CGRectMake(0, 214, self.view.bounds.width, 259)
      
      if orderV != nil {
        scrollView.addSubview(orderV!)
      }
      let starRating = EDStarRating()
      starRating.frame = CGRectMake(80, 500, self.view.bounds.width/3, 123)
      starRating.backgroundColor = UIColor.whiteColor()
      starRating.starImage = UIImage(named: "star-template")
      starRating.starHighlightedImage = UIImage(named: "star-highlighted-template")
      starRating.maxRating = 5
      starRating.delegate = self;
      starRating.horizontalMargin = 12;
      starRating.editable = true;
      scrollView.addSubview(starRating)
      
      starRating.rating = 5.0;

        // Do any additional setup after loading the view.
    }
  
  
  //MARK -EDStarRating Protocol
  func starsSelectionChanged(control: EDStarRating!, rating: Float) {
    print(rating)
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
