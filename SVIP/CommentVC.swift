//
//  CommentVC.swift
//  SVIP
//
//  Created by AlexBang on 16/5/7.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class CommentVC: UIViewController,UITextViewDelegate {
  var region:Region!
  @IBOutlet weak var commentsView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
      title = "评论"
      let rightBtn = UIBarButtonItem(title: "发送", style: UIBarButtonItemStyle.Plain, target: self, action: "send:")
      self.navigationItem.rightBarButtonItem = rightBtn
      let leftBtn = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "cancle:")
      self.navigationItem.leftBarButtonItem = leftBtn
      let str = NSAttributedString(string: "写评论...", attributes: [NSForegroundColorAttributeName:UIColor(hex: "#888888")])
      commentsView.attributedText = str
      commentsView.delegate = self



        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  func send(sender:UIBarButtonItem) {
    guard let comment = commentsView.text where !comment.trim.isEmpty && comment.trim != "写评论..."  else {
      self.showHint("请填写评论内容")
      return
    }
    let data = RegionComment.create() as! RegionComment
    data.userID = TokenPayload.sharedInstance.userID
    data.userName = AccountManager.sharedInstance().userName
    data.avatarUrl = AccountManager.sharedInstance().avatarURL
    data.timestamp = NSDate()
    data.locid = region.locid
    data.content = "\(comment)"
    data.save()
    navigationController?.popViewControllerAnimated(true)
  }

  func cancle(sender:UIBarButtonItem) {
    
    navigationController?.popViewControllerAnimated(true)
  }
  
  func textViewShouldBeginEditing(textView: UITextView) -> Bool {
    
    return true
  }
  
  func textViewDidBeginEditing(textView: UITextView) {
    commentsView.text = ""
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
