//
//  BookPayVC.swift
//  SVIP
//
//  Created by dai.fengyi on 15/7/2.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class BookPayVC: UIViewController {
  @IBOutlet private weak var name: UILabel!
  @IBOutlet private weak var price: UILabel!
  @IBOutlet private weak var preference: UILabel!
  @IBOutlet weak var roomLook: UIImageView!
  
  var bkOrder: BookOrder!
  var money:double_t!
  var dic: NSDictionary!
  var IP:String!
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: "BookPayVC", bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.hidesBarsOnSwipe = true
   
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.hidesBarsOnSwipe = false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    name.text = bkOrder.room_type
//    orderLabel.text = "\(bkOrder.room_type)   \(bkOrder.dayInt)晚"
    preference.text = bkOrder.remark
    let rate = bkOrder.room_rate.doubleValue
    money = rate * bkOrder.dayInt.doubleValue
    price.text = "￥\(money)"
    name.text = bkOrder.room_type
   getCurrentIP()

  }
  
  func cancelOrder() {
    showHUDInView(view, withLoading: "正在取消订单")
    ZKJSHTTPSessionManager .sharedInstance() .cancelOrderWithReservationNO(bkOrder.reservation_no, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      self.showHint("订单已取消")
      self.dismissViewControllerAnimated(true, completion: nil)
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        self.showHint("订单取消失败，请进入订单列表取消订单")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  func dismissSelf() -> Void {
    dismissViewControllerAnimated(true, completion: nil)
  }
  func getCurrentIP() {
   IP = ZKJSTool.getIPAddress(true)
    
  }
  
  @IBAction private func zhifubao(sender: UIButton) {
    dic = [
    "order_no":bkOrder.reservation_no,
      "channel":"alipay",
      "amount":NSNumber(integer: Int(money*100)),
      "client_ip":"\(IP)",
      "subject":"\(bkOrder.fullname)" + "\(bkOrder.rooms)" + "\(bkOrder.room_type)" + "\(bkOrder.dayInt)晚",
      "body":"\(bkOrder.room_type)" + "\(bkOrder.guest)"
    ]
    
    ZKJSHTTPSessionManager.sharedInstance().pingPayWithDic(dic as [NSObject : AnyObject], success: { (task: NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      let dic = responsObject as! NSDictionary
      self.payAliOrder(dic)
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
    
  }
  
  @IBAction private func weixinzhifu(sender: UIButton) {
    dic = [
      "order_no" :bkOrder.reservation_no,
      "channel":"wx",
      "amount":NSNumber(integer: Int(money*100)),
      "client_ip":"\(IP)",
      "subject":"\(bkOrder.fullname)" + "\(bkOrder.rooms)" + "\(bkOrder.room_type)" + "\(bkOrder.dayInt)晚",
      "body":"\(bkOrder.room_type)" + "\(bkOrder.guest)"
    ]
    ZKJSHTTPSessionManager.sharedInstance().pingPayWithDic(dic as [NSObject : AnyObject], success: { (task: NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      let dic = responsObject as! NSDictionary
      self.payAliOrder(dic)
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }

  }
  
  @IBAction private func payInHotel(sender: UIButton) {
//    let chatVC = JSHChatVC(chatType: .OldSession)
//    chatVC.order = bkOrder
//    chatVC.shopID = bkOrder.shopid.stringValue
//    chatVC.firstMessage = NSLocalizedString("FIRST_MESSAGE_PAY_WHEN_CHECKIN", comment: "")
//    navigationController?.pushViewController(chatVC, animated: true)
  }

//MARK:- ALIPAY
  private func payAliOrder(charge:NSDictionary) {
    Pingpp.createPayment(charge,viewController: self, appURLScheme: "SVIPPAY") { (result:String!, error:PingppError!) -> Void in
      if result == "success" {
        ZKJSTool.showMsg("支付成功")
      }else {
        print(error.getMsg())
        ZKJSTool.showMsg("支付失败")
      }
    }
//    let aliOrder = AlipayOrder()
//    aliOrder.partner = partner
//    aliOrder.seller = seller
////    aliOrder.tradeNO = tradeNo  //need to fetch 
//    aliOrder.tradeNO = AbookOrder.reservation_no
//    aliOrder.productName = AbookOrder.room_type
//    aliOrder.productDescription = "needtoknow"
//    if let rooms = AbookOrder.rooms {
//      let amount = AbookOrder.room_rate.doubleValue * rooms.doubleValue
//    aliOrder.amount = NSString(format:"%.2f", amount) as String
////      aliOrder.amount = "0.02"
//    }
//    
//    aliOrder.notifyURL = "http://api.zkjinshi.com/alipay/notify"
//    aliOrder.service = "mobile.securitypay.pay"
//    aliOrder.paymentType = "1"
//    aliOrder.inputCharset = "utf-8"
//    aliOrder.itBPay = "30m"
//    aliOrder.showUrl = "m.alipay.com"
//    
//    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
//    let appScheme = "SVIPPAY"
//    
//    //将商品信息拼接成字符串
//    let orderSpec = aliOrder.description
//    print(orderSpec, terminator: "")
//    
//    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
////    id<DataSigner> signer = CreateRSADataSigner(privateKey);
////    NSString *signedString = [signer signString:orderSpec];
//    let signer = CreateRSADataSigner(privateKey)
//    if let signedString = signer.signString(orderSpec) {
//      let orderString = String(format: "%@&sign=\"%@\"&sign_type=\"%@\"", orderSpec, signedString, "RSA")
//      let service = AlipaySDK .defaultService()
////      service .payOrder("abc", fromScheme: "abc", callback: { (resultDic: AnyObject!) -> Void in
////
////      })
//      service .payOrder(orderString, fromScheme: appScheme, callback: { [unowned self] (aDictionary) -> Void in
//        let resultStatus = aDictionary["resultStatus"] as! String
//        let result = aDictionary["result"] as! NSString
//        if self.validateResult(result) && resultStatus == "9000" {
//          //支付成功,跳到聊天
//          let chatVC = JSHChatVC(chatType: .OldSession)
//          chatVC.order = self.bkOrder
//          chatVC.shopID = self.bkOrder.shopid.stringValue
//          chatVC.firstMessage = NSLocalizedString("FIRST_MESSAGE_ORDER_PAID", comment: "")
//          chatVC.navigationItem.hidesBackButton = true
//          self.navigationController?.pushViewController(chatVC, animated: true)
//        }else {
//          self.showHint("支付失败")
//        }
//        })
//    }
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
//    NSString *orderString = nil;
//    if (signedString != nil) {
//      orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
//      orderSpec, signedString, @"RSA"];
//      
//      [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
//      NSLog(@"reslut = %@",resultDic);
//      }];
//
//    }
  }
  
  private func validateResult(result: NSString) -> Bool{
//    let resultRange = NSRange(location: 0, length: count(result))
//    let locale = NSLocale.systemLocale()
//    result .rangeOfString("success=\"", options: NSStringCompareOptions.LiteralSearch, range: resultRange, locale:locale)
    let range = result .rangeOfString("success=\"")
    if range.length == 0 {
      return false
    }
    let str = result .substringWithRange(NSRange(location: range.location + range.length, length: 4))
    return str == "true"
  }
}
