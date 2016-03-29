//
//  LoginFirstVC.swift
//  SVIP
//
//  Created by AlexBang on 16/3/29.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class LoginFirstVC: UIViewController {

  @IBOutlet weak var phonetextFiled: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  

  @IBAction func register(sender: AnyObject) {
    let vc = RegisterVC()
    self.navigationController?.pushViewController(vc, animated: true)
  }


  @IBAction func start(sender: AnyObject) {
    let vc = LoginVC()
    vc.phoneLabel.text = self.phonetextFiled.text
    self.navigationController?.presentViewController(vc, animated: true, completion: nil)
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
