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

enum PaymentStatusType: Int {
  case Fail = 0
  case Success = 1
}

protocol BookPayVCDelegate {
  func didFinishPaymentWithStatus(status: PaymentStatusType)
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
  var delegate: BookPayVCDelegate? = nil
  
  
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
    //    preference.text = bkOrder.remark
    money = bkOrder.roomprice
    price.text = "￥\(bkOrder.roomprice)"
    name.text = bkOrder.roomtype
    getCurrentIP()
  }
  
  func pop(sender:UIBarButtonItem) {
    let appWindow = UIApplication.sharedApplication().keyWindow
    let mainTBC = MainTBC()
    mainTBC.selectedIndex = 3
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: kGotoOrderList)
    let nc = BaseNC(rootViewController: mainTBC)
    appWindow?.rootViewController = nc
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
  
  //MARK:- ALIPAY
  private func payAliOrder(charge:NSDictionary) {
    Pingpp.createPayment(charge,viewController: self, appURLScheme: "SVIPPAY") { (result:String!, error:PingppError!) -> Void in
      if result == "success" {
        ZKJSJavaHTTPSessionManager.sharedInstance().orderPayWithOrderno(self.bkOrder.orderno, success: { (task:NSURLSessionDataTask!, responsObjects:AnyObject!) -> Void in
          print(responsObjects)
          self.sendMessageNotificationWithText("订单已成功支付")
          self.navigationController?.popViewControllerAnimated(false)
          self.delegate?.didFinishPaymentWithStatus(.Success)
          }, failure: { (task:NSURLSessionDataTask!, error: NSError!) -> Void in
            print(error)
            self.navigationController?.popViewControllerAnimated(false)
            self.delegate?.didFinishPaymentWithStatus(.Fail)
        })
      } else {
        print(error.getMsg())
        self.navigationController?.popViewControllerAnimated(false)
        self.delegate?.didFinishPaymentWithStatus(.Fail)
      }
    }
  }
  
  func sendMessageNotificationWithText(text: String) {
    // 发送环信消息
    let userName = AccountManager.sharedInstance().userName
    let txtChat = EMChatText(text: text)
    let body = EMTextMessageBody(chatObject: txtChat)
    let message = EMMessage(receiver: bkOrder.saleid, bodies: [body])
    let ext: [String: AnyObject] = ["shopId": bkOrder.shopid,
      "shopName": bkOrder.shopname,
      "toName": "",
      "fromName": userName,
      "extType": 0]
    message.ext = ext
    message.messageType = .eMessageTypeChat
    EaseMob.sharedInstance().chatManager.asyncSendMessage(message, progress: nil)
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
