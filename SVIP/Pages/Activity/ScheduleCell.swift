//
//  ScheduleCell.swift
//  SVIP
//
//  Created by Qin Yejun on 6/29/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class ScheduleCell: UITableViewCell {
  
  @IBOutlet weak var merchantLabel: UILabel!
  @IBOutlet weak var activityLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!  

  var schedule:MySchedule! {
    didSet {
      merchantLabel.text = schedule.merchant
      activityLabel.text = schedule.activity
      dateLabel.text = schedule.date
      timeLabel.text = schedule.time
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

}
