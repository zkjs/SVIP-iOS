//
//  AttendActivityVC.swift
//  SVIP
//
//  Created by Qin Yejun on 6/30/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class AttendActivityVC: UIViewController {
  var actid:String!
  var startTime:String!
  var endTime:String!
  var maxMemberCount:Int = 0
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var startTimeLabel: UILabel!
  @IBOutlet weak var endTimeLabel: UILabel!
  @IBOutlet weak var attendanceControl: NumbersControl!
  @IBOutlet weak var confirmButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "参加活动"
    
    nameLabel.text = AccountManager.sharedInstance().userName
    startTimeLabel.text = startTime
    endTimeLabel.text = endTime
    attendanceControl.minValue = 1
    attendanceControl.maxValue = maxMemberCount
  }
  
  
  @IBAction func confirmAction(sender: AnyObject) {
    showHUDInView(view, withLoading: "")
    HttpService.sharedInstance.attendActivity(actid, memdersCount: attendanceControl.currentVal) { (json, error) in
      self.hideHUD()
      if let error = error {
        self.showErrorHint(error)
      } else {
        self.showHint("成功参加活动")
        self.navigationController?.popViewControllerAnimated(true)
      }
    }
  }
}
