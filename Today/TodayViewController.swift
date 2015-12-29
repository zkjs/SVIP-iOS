//
//  TodayViewController.swift
//  Today
//
//  Created by Hanton on 9/16/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
  
  @IBOutlet weak var attentionLabel: UILabel!
  @IBOutlet weak var hotelNameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var roomTypeLabel: UILabel!
  
  var defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.com.zkjinshi.svip")!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    preferredContentSize = CGSizeMake(320, 120)
    
    attentionLabel.text = ""
    hotelNameLabel.text = NSLocalizedString("LOADING", comment: "")
    dateLabel.text = ""
    roomTypeLabel.text = ""
  }
  
  func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResult.Failed
    // If there's no update required, use NCUpdateResult.NoData
    // If there's an update, use NCUpdateResult.NewData
    
    if let userID = defaults.objectForKey("userid") as? String,
      let token = defaults.objectForKey("token") as? String {
        let url = NSURL(string: "http://tap.zkjinshi.com/order/last")
        let request = NSMutableURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        let params = ["userid": userID, "token": token] as Dictionary<String, String>
        
        let boundaryConstant = "----------V2ymHFg03ehbqgZCaKO6jy"
        request.addValue("multipart/form-data; boundary=\(boundaryConstant)", forHTTPHeaderField: "Content-Type")
        let body = NSMutableData()
        var appendString: NSString
        for (key, value) in params {
          appendString = "--" + boundaryConstant + "\r\n"
          body.appendData(appendString.dataUsingEncoding(NSUTF8StringEncoding)!)
          appendString = "Content-Disposition: form-data; name=" + key + "\r\n\r\n"
          body.appendData(appendString.dataUsingEncoding(NSUTF8StringEncoding)!)
          appendString = value + "\r\n"
          body.appendData(appendString.dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        appendString = "--" + boundaryConstant + "--\r\n"
        body.appendData(appendString.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        request.HTTPBody = body
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
          print("Response: \(response)")
          if let data = data {
            let strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            let json = (try! NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves)) as? NSDictionary
            
//            if (error != nil) {
//              print(error!.localizedDescription)
//              let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
//              print("Error could not parse JSON: '\(jsonStr)'")
//            } else {
              if let parseJSON = json {
                let reservation_no = parseJSON["reservation_no"] as? String ?? ""
                if reservation_no == "0" {
                  // 暂无订单
                  dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                    self.hotelNameLabel.text = NSLocalizedString("NO_ORDER", comment: "")
                    })
                } else {
                  // 有订单
                  dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                    self.attentionLabel.text = NSLocalizedString("YOUR_ORDER", comment: "")
                    self.hotelNameLabel.text = parseJSON["fullname"] as? String ?? ""
                    let arrival_date = parseJSON["arrival_date"] as? String ?? ""
                    let departure_date = parseJSON["departure_date"] as? String ?? ""
                    self.dateLabel.text = "\(arrival_date) " + NSLocalizedString("TO", comment: "") + " \(departure_date)"
                    self.roomTypeLabel.text = parseJSON["room_type"] as? String ?? ""
                    })
                }
              } else {
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: \(jsonStr)")
              }
//            }
          }
        })
        
        task.resume()
        
        completionHandler(NCUpdateResult.NewData)
    } else {
      completionHandler(NCUpdateResult.NoData)
    }
  }
  
  func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsetsZero
  }
  
  @IBAction func handleMoreButtonTapped(sender: AnyObject) {
    let url = NSURL(scheme: "SVIP", host: nil, path: "/")
    extensionContext?.openURL(url!, completionHandler: nil)
    print("handleMoreButtonTapped")
  }
  
}
