//
//  PersonalLabelViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/24.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class PersonalLabelViewController: UIViewController, LabelSelectViewDelegate {
  @IBOutlet weak var selectedLabelView: LabelSelectView!
  @IBOutlet weak var toSelectLabelView: LabelSelectView!
  @IBOutlet weak var selectedLabelViewConstraintHeight: NSLayoutConstraint!
  @IBOutlet weak var toSelectLabelViewConstraintHeight: NSLayoutConstraint!
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: "PersonalLabelViewController", bundle: nil)
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadData()
    setUI()
  }
  func setUI() {
    self.title = "偏好标签"
    let right = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Plain, target: self, action: NSSelectorFromString("save"))
    self.navigationItem.rightBarButtonItem = right
    
    selectedLabelView.delegate = self
    toSelectLabelView.delegate = self
  }
  func loadData() {
    ZKJSHTTPSessionManager.sharedInstance().getSelectedTagsWithID(JSHAccountManager.sharedJSHAccountManager().userid, token: JSHAccountManager.sharedJSHAccountManager().token, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let arr = responseObject as? [AnyObject] {
        for dic in arr {
          self.selectedLabelView.addItem(dic as! NSDictionary)
          self.selectedLabelViewConstraintHeight.constant = self.selectedLabelView.height
        }
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      
    }

    ZKJSHTTPSessionManager.sharedInstance().getRandomTagsWithSuccess({ (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let arr = responseObject as? [AnyObject] {
        for dic in arr {
          self.toSelectLabelView.addItem(dic as! NSDictionary)
          self.toSelectLabelViewConstraintHeight.constant = self.toSelectLabelView.height
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
  }
}
