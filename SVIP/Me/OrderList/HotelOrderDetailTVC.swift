//
//  HotelOrderDetailTVC.swift
//  SVIP
//
//  Created by AlexBang on 16/1/3.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class HotelOrderDetailTVC:  UITableViewController {
  @IBOutlet weak var pendingConfirmationLabel: UILabel!
  @IBOutlet weak var invoinceTextField: UITextField!
  @IBOutlet weak var contacterLabel: UILabel!
  @IBOutlet weak var telphotoLabel: UILabel!
  @IBOutlet weak var smokingLabel: UILabel!
  @IBOutlet weak var breakbreastLabel: UILabel!
  @IBOutlet weak var arrivateLabel: UILabel!
  @IBOutlet weak var roomTypeLabel: UILabel!
  @IBOutlet weak var roomsCountLabel: UILabel!
  @IBOutlet weak var payTypeLabel: UILabel!
  @IBOutlet weak var payButton: UIButton!
  @IBOutlet weak var cancleButton: UIButton!
  var reservation_no: String!
  var orderno: String!
  var orderDetail = OrderDetailModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.translucent = false
  }
  
  func loadData() {
    //获取订单详情
    ZKJSJavaHTTPSessionManager.sharedInstance().getOrderDetailWithOrderNo(reservation_no, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      print(responseObject)
      if let dic = responseObject as? NSDictionary {
        self.orderDetail = OrderDetailModel(dic: dic)
      }
      self.tableView.reloadData()
      self.setUI()
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
    
  }
  
  func setUI() {
    arrivateLabel.text = orderDetail.arrivaldate
    roomTypeLabel.text = orderDetail.roomtype
    roomsCountLabel.text = String(orderDetail.roomcount)
    contacterLabel.text = orderDetail.orderedby
    telphotoLabel.text = orderDetail.telephone
    if orderDetail.paytype == 1 {
      payTypeLabel.text = "在线支付"
      payButton.setTitle("立即支付", forState: UIControlState.Normal)
    }
    
    if orderDetail.paytype == 0 {
      payButton.hidden = true
      pendingConfirmationLabel.text = "  请您核对订单，并确认。如需修改，请联系客服"
    }
    if orderDetail.orderstatus == "待确认" {
      payButton.addTarget(self, action: "confirm:", forControlEvents: UIControlEvents.TouchUpInside)
      cancleButton.addTarget(self, action: "cancle:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    
  }
  
  func confirm(sender:UIButton) {
    if self.orderDetail.paytype == 1 {
      let vc = BookPayVC()
      vc.bkOrder = self.orderDetail
      self.navigationController?.pushViewController(vc, animated: true)
    } else {
      ZKJSJavaHTTPSessionManager.sharedInstance().confirmOrderWithOrderNo(orderDetail.orderno, success: { (task: NSURLSessionDataTask!, responsObjects:AnyObject!) -> Void in
        print(responsObjects)
        if let dic = responsObjects as? NSDictionary {
          self.orderno = dic["data"] as! String
          if let result = dic["result"] as? NSNumber {
            if result.boolValue == true {
              ZKJSTool.showMsg("订单已确认")
              self.navigationController?.popViewControllerAnimated(true)
            }
            
          }
        }
        }) { (task: NSURLSessionDataTask!, eeror: NSError!) -> Void in
          
      }
    }
    
  }
  
  func cancle(sender:UIButton) {
   ZKJSJavaHTTPSessionManager.sharedInstance().cancleOrderWithOrderNo(orderDetail.orderno, success: { (task: NSURLSessionDataTask!, responsObjects:AnyObject!)-> Void in
    if let dic = responsObjects as? NSDictionary {
      self.orderno = dic["data"] as! String
      if let result = dic["result"] as? NSNumber {
        if result.boolValue == true {
          self.navigationController?.popViewControllerAnimated(true)
        }
        
      }
    }
    }) { (task: NSURLSessionDataTask!, eeror: NSError!) -> Void in
      
    }
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
