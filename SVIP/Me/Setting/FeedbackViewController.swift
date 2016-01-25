//
//  FeedbackViewController.swift
//  SVIP
//
//  Created by AlexBang on 16/1/25.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {

  @IBOutlet weak var feedBackTextView: UITextView! {
    didSet {
      feedBackTextView.layer.borderWidth = 1 //边框粗细
      feedBackTextView.layer.borderColor = UIColor(hexString: "B8B8B8").CGColor //边框颜色
    }
  }

    override func viewDidLoad() {
        super.viewDidLoad()
      title = "意见反馈"
      let image = UIImage(named: "ic_fanhui_orange")
      let item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: "pop:")
      self.navigationItem.leftBarButtonItem = item1
        // Do any additional setup after loading the view.
    }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("FeedbackViewController", owner:self, options:nil)
  }
  
  func pop(sender:UIBarButtonItem) {
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    view.endEditing(true)
  }

  @IBAction func sendFeedBack(sender: AnyObject) {
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

extension FeedbackViewController: UITextViewDelegate {
  
  func textViewDidBeginEditing(textView: UITextView) {
    if textView.text == "期待您的意见反馈" {
      textView.text = ""
      textView.textColor = UIColor.blackColor()
    }
    textView.becomeFirstResponder()
  }
  
  func textViewDidEndEditing(textView: UITextView) {
    if textView.text == "" {
      textView.text = "期待您的意见反馈"
      textView.textColor = UIColor.lightGrayColor()
    }
    textView.resignFirstResponder()
  }
  
}
