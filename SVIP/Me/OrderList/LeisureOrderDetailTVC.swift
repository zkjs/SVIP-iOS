//
//  LeisureOrderDetailTVC.swift
//  SVIP
//
//  Created by AlexBang on 16/1/4.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class LeisureOrderDetailTVC: UITableViewController {

  @IBOutlet weak var roomImage: UIImageView!
  @IBOutlet weak var pendingConfirmationLabel: UILabel!
  @IBOutlet weak var cancleButton: UIButton!
  @IBOutlet weak var payButton: UIButton!
  @IBOutlet weak var remarkView: UITextView!
  @IBOutlet weak var invoiceLabel: UILabel!
  @IBOutlet weak var telphotoLabel: UILabel!
  @IBOutlet weak var contacterLabel: UILabel!
  @IBOutlet weak var personCountLabel: UILabel!
  @IBOutlet weak var arriveDateLabel: UILabel!
  
  var reservation_no: String!
  var orderno: String!
  var orderDetail = OrderDetailModel()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      loadData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    arriveDateLabel.text = orderDetail.arrivaldate
    
    personCountLabel.text = String(orderDetail.roomcount)
    contacterLabel.text = orderDetail.orderedby
    telphotoLabel.text = orderDetail.telephone
    invoiceLabel.text = String(orderDetail.isinvoice)
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
      showHUDInView(view, withLoading: "")
      ZKJSJavaHTTPSessionManager.sharedInstance().confirmOrderWithOrderNo(orderDetail.orderno, success: { (task: NSURLSessionDataTask!, responsObjects:AnyObject!) -> Void in
        print(responsObjects)
        if let dic = responsObjects as? NSDictionary {
          self.orderno = dic["data"] as! String
          if let result = dic["result"] as? NSNumber {
            if result.boolValue == true {
              ZKJSTool.showMsg("订单已确认")
              self.hideHUD()
              self.navigationController?.popViewControllerAnimated(true)
            }
          }
        }
        }) { (task: NSURLSessionDataTask!, eeror: NSError!) -> Void in
          
      }
    }
    
  }
  
  func cancle(sender:UIButton) {
    showHUDInView(view, withLoading: "")
    ZKJSJavaHTTPSessionManager.sharedInstance().cancleOrderWithOrderNo(orderDetail.orderno, success: { (task: NSURLSessionDataTask!, responsObjects:AnyObject!)-> Void in
      if let dic = responsObjects as? NSDictionary {
        self.orderno = dic["data"] as! String
        if let result = dic["result"] as? NSNumber {
          if result.boolValue == true {
            self.navigationController?.popViewControllerAnimated(true)
            self.hideHUD()
          }
        }
      }
      }) { (task: NSURLSessionDataTask!, eeror: NSError!) -> Void in
        
    }
  }
  

}
