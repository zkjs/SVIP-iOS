//
//  TodayViewController.swift
//  SVIPTodayWidget
//
//  Created by Hanton on 9/14/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

  var defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.com.zkjinshi.svip")!
  
  @IBOutlet weak var attentionLabel: UILabel!
  @IBOutlet weak var hotelNameLabel: UILabel!
  @IBOutlet weak var bookingInfoLabel: UILabel!
  @IBOutlet weak var moreButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    attentionLabel.text = ""
    hotelNameLabel.text = ""
    bookingInfoLabel.text = ""
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResult.Failed
    // If there's no update required, use NCUpdateResult.NoData
    // If there's an update, use NCUpdateResult.NewData
    
//    if let userID = defaults.objectForKey("userid") as? String,
//      let token = defaults.objectForKey("token") as? String {
//        let url = NSURL(string: "http://120.25.241.196/order/last")
//        var request = NSMutableURLRequest(URL: url!)
//        var session = NSURLSession.sharedSession()
//        request.HTTPMethod = "POST"
//        
//        var params = ["userid":userID, "password":token] as Dictionary<String, String>
//        
//        var err: NSError?
//        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        
//        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
//          println("Response: \(response)")
//          var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
//          println("Body: \(strData)")
//          var err: NSError?
//          var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
//          
//          // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
//          if(err != nil) {
//            println(err!.localizedDescription)
//            let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
//            println("Error could not parse JSON: '\(jsonStr)'")
//          }
//          else {
//            // The JSONObjectWithData constructor didn't return an error. But, we should still
//            // check and make sure that json has a value using optional binding.
//            if let parseJSON = json {
//              // Okay, the parsedJSON is here, let's get the value for 'success' out of it
//              var success = parseJSON["success"] as? Int
//              println("Succes: \(success)")
//            }
//            else {
//              // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
//              let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
//              println("Error could not parse JSON: \(jsonStr)")
//            }
//          }
//        })
//        
//        task.resume()
//        
//        completionHandler(NCUpdateResult.NewData)
//    } else {
//      completionHandler(NCUpdateResult.NoData)
//    }

    completionHandler(NCUpdateResult.NoData)
  }
  
  func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
    let newInsets = UIEdgeInsets(top: defaultMarginInsets.top, left: defaultMarginInsets.left - 30,
      bottom: defaultMarginInsets.bottom - 30, right: defaultMarginInsets.right)
    return newInsets
  }
  
  @IBAction func handleMoreButtonTapped(sender: AnyObject) {
    let url = NSURL(scheme: "SVIP", host: nil, path: "/")
    extensionContext?.openURL(url!, completionHandler: nil)
  }
  
}
