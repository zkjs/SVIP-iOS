//
//  LoginVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/1.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

  @IBOutlet weak var phoneTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
      login()

        // Do any additional setup after loading the view.
    }
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("LoginVC", owner:self, options:nil)
  }
  func login() {
    ZKJSHTTPSessionManager.sharedInstance().verifyIsRegisteredWithID("phone", success: { (task:NSURLSessionDataTask!, responsObjects:AnyObject!) -> Void in
      if let data = responsObjects {
        if let set = data["set"] as? NSNumber {
          if set.boolValue == true {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
              
            })
          }
        }
      }
      
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        
    }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func login(sender: AnyObject) {
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
