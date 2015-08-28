//
//  PersonalLabelViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/24.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class PersonalLabelViewController: UIViewController, LabelSelectViewDelegate {
  @IBOutlet weak var avatar: UIImageView!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var publicSwitch: UISwitch!
  
  @IBOutlet weak var selectedLabelView: LabelSelectView!
  @IBOutlet weak var toSelectLabelView: LabelSelectView!
  @IBOutlet weak var selectedLabelViewConstraintHeight: NSLayoutConstraint!
  @IBOutlet weak var toSelectLabelViewConstraintHeight: NSLayoutConstraint!

  let scrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
  var header: UIView!
  var footer: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadData()
    setUI()
  }

  func setUI() {
    self.title = "偏好标签"
    self.view.backgroundColor = UIColor.blackColor()
    let right = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Plain, target: self, action: NSSelectorFromString("save"))
    self.navigationItem.rightBarButtonItem = right

    self.view.addSubview(scrollView)
    header = NSBundle.mainBundle().loadNibNamed("PersonalLabelHeader", owner: self, options: nil).last as! UIView
    footer = NSBundle.mainBundle().loadNibNamed("PersonalLabelFooter", owner: self, options: nil).last as! UIView
    header.frame = CGRectMake(0, 0, scrollView.frame.width, header.frame.height)
    footer.frame = CGRectMake(0, header.frame.height, scrollView.frame.width, 180)
    footer.clipsToBounds = false;
    footer.backgroundColor = UIColor(red: 255.0/255.0, green: 95.0/255.0, blue: 154.0/255.0, alpha: 1.0)//UIColor.pinkColor()
    scrollView.addSubview(header)
    scrollView.addSubview(footer)

    let baseinfo = JSHStorage.baseInfo()
    self.username.text = baseinfo.username
    self.avatar.image = baseinfo.avatarImage
    self.publicSwitch.on = baseinfo.tagopen == 1 ? true : false
    
    selectedLabelView.delegate = self
    toSelectLabelView.delegate = self
  }

  func adjustUI() {//调整没有autolayout的视图和属性
    self.footer.frame = CGRectMake(self.footer.frame.origin.x, self.footer.frame.origin.y, self.footer.frame.size.width, 88 + self.selectedLabelViewConstraintHeight.constant + self.toSelectLabelViewConstraintHeight.constant)
    self.scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(self.footer.frame))
  }
  
  func loadData() {
    ZKJSHTTPSessionManager.sharedInstance().getSelectedTagsWithID(JSHAccountManager.sharedJSHAccountManager().userid, token: JSHAccountManager.sharedJSHAccountManager().token, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let arr = responseObject as? [AnyObject] {
        for dic in arr {
          self.selectedLabelView.addItem(dic as! NSDictionary)
          self.selectedLabelViewConstraintHeight.constant = self.selectedLabelView.height
          self.adjustUI()
        }
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      
    }

    ZKJSHTTPSessionManager.sharedInstance().getRandomTagsWithSuccess({ (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let arr = responseObject as? [AnyObject] {
        for dic in arr {
          self.toSelectLabelView.addItem(dic as! NSDictionary)
          self.toSelectLabelViewConstraintHeight.constant = self.toSelectLabelView.height
          self.adjustUI()
        }
      }
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      
    })
  }
  //MARK:- Button Action
  func save() {
    var tags: String!
    if selectedLabelView.dataArray.count == 0 {//如果用户全清空，传什么???
      tags = ""
    }else {
      let mutArr = NSMutableArray()
      for dic in selectedLabelView.dataArray {
        mutArr.addObject(dic["tagid"] as! String)
      }
      tags = mutArr.componentsJoinedByString(",")
    }
    ZKJSHTTPSessionManager.sharedInstance().updateTagsWithUserID(JSHAccountManager.sharedJSHAccountManager().userid, token: JSHAccountManager.sharedJSHAccountManager().token, tags: tags, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let dic = responseObject as? NSDictionary {
        let set = dic["set"]!.boolValue!
        if set {
          ZKJSTool.showMsg("保存成功")
          self.navigationController?.popViewControllerAnimated(true)
        }else {
          ZKJSTool.showMsg("保存失败")
        }
      }
    }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      
    }
    
    let tagopen = NSNumber(int: publicSwitch.on ? 1 : 0)
    ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithUserID(JSHAccountManager.sharedJSHAccountManager().userid, token: JSHAccountManager.sharedJSHAccountManager().token, username: nil, realname: nil, imageData: nil, imageName: nil, sex: nil, company: nil, occupation: nil, email: nil, tagopen: tagopen,success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let dic = responseObject as? NSDictionary {
        let set = dic["set"]!.boolValue!
        if set {
//          ZKJSTool.showMsg("保存成功")
//          self.navigationController?.popViewControllerAnimated(true)
          let baseinfo = JSHStorage.baseInfo()
          baseinfo.tagopen = tagopen.intValue
          JSHStorage.saveBaseInfo(baseinfo)
        }else {
//          ZKJSTool.showMsg("保存失败")
        }
      }
    }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
    
    })
  }
  //MARK:- LabelSelectViewDelegate
  func labelSelectView(labelSelectView: LabelSelectView,  didSelected dic: NSDictionary, index:Int) {
    if labelSelectView == toSelectLabelView {
      selectedLabelView.addItem(dic)
    }
    if labelSelectView == selectedLabelView {
      selectedLabelView.removeItem(index)
    }
    self.selectedLabelViewConstraintHeight.constant = selectedLabelView.height
    self.adjustUI()
  }
}
