//
//  BookPayVC.swift
//  SVIP
//
//  Created by Hanton on 15/7/2.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

enum BookPayVCType: Int {
  case Push = 0
  case Present = 1
}

class BookPayVC: UIViewController {
  
  @IBOutlet private weak var name: UILabel!
  @IBOutlet private weak var price: UILabel!
  @IBOutlet private weak var preference: UILabel!
  @IBOutlet weak var roomLook: UIImageView!
  var bkorder: BookOrder!
  var bkOrder: OrderDetailModel!
  var money: double_t!
  var dic: NSDictionary!
  var IP: String!
  var type = BookPayVCType.Push
  
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("BookPayVC", owner:self, options:nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    automaticallyAdjustsScrollViewInsets = false
    if type == .Present {
      let dismissItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismissSelf")
      navigationItem.rightBarButtonItem = dismissItem
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let image = UIImage(named: "ic_fanhui_orange")
    let item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: "pop:")
    self.navigationItem.leftBarButtonItem = item1
    
    name.text = bkOrder.roomtype
    //    orderLabel.text = "\(bkOrder.room_type)   \(bkOrder.dayInt)晚"
    preference.text = bkOrder.remark
    money = bkOrder.roomprice
    price.text = "￥\(bkOrder.roomprice)"
    name.text = bkOrder.roomtype
    getCurrentIP()
  }
  
  func pop(sender:UIBarButtonItem) {
   navigationController?.popToRootViewControllerAnimated(true)
  }
  
  func cancelOrder() {
    showHUDInView(view, withLoading: "正在取消订单")
    ZKJSHTTPSessionManager .sharedInstance() .cancelOrderWithReservationNO(bkOrder.orderno, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
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
      "order_no":bkOrder.orderno,
      "channel":"alipay",
      "amount":NSNumber(integer: Int(money*100)),
      "client_ip":"\(IP)",
      "subject":"\(bkOrder.shopname)" + "\(bkOrder.roomcount)" + "\(bkOrder.roomtype)" + "\(bkOrder.dayInt)晚",
      "body":"\(bkOrder.roomtype)" + "\(bkOrder.orderedby)"
    ]
    
    ZKJSHTTPSessionManager.sharedInstance().pingPayWithDic(dic as [NSObject : AnyObject], success: { (task: NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      let dic = responsObject as! NSDictionary
      self.payAliOrder(dic)
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        ZKJSTool.showMsg("请安装支付宝")
    }
}
  
  @IBAction private func weixinzhifu(sender: UIButton) {
    dic = [
      "order_no" :bkOrder.orderno,
      "channel":"wx",
      "amount":NSNumber(integer: Int(money*100)),
      "client_ip":"\(IP)",
      "subject":"\(bkOrder.shopname)" + "\(bkOrder.roomcount)" + "\(bkOrder.roomtype)" + "\(bkOrder.dayInt)晚",
      "body":"\(bkOrder.roomtype)" + "\(bkOrder.orderedby)"
    ]
    ZKJSHTTPSessionManager.sharedInstance().pingPayWithDic(dic as [NSObject : AnyObject], success: { (task: NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      let dic = responsObject as! NSDictionary
      self.payAliOrder(dic)
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        ZKJSTool.showMsg("请安装微信")
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
        ZKJSJavaHTTPSessionManager.sharedInstance().orderPayWithOrderno(self.bkOrder.orderno, success: { (task:NSURLSessionDataTask!, responsObjects:AnyObject!) -> Void in
          print(responsObjects)
          }, failure: { (task:NSURLSessionDataTask!, error: NSError!) -> Void in
            print(error)
        })
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
    let range = result .rangeOfString("success=\"")
    if range.length == 0 {
      return false
    }
    let str = result .substringWithRange(NSRange(location: range.location + range.length, length: 4))
    return str == "true"
  }
}
