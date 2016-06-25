//
//  MyOrderCell.swift
//  SVIP
//
//  Created by Qin Yejun on 6/22/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class MyOrderCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var stateLabel: UILabel!
  
  var order:MyOrder! {
    didSet {
      titleLabel.text = order.title
      timeLabel.text = order.createtime
      stateLabel.text = order.status
      stateLabel.textColor = stateColor
    }
  }
  
  var stateColor:UIColor {
    switch order.statusCode {
    case .Finished,.Rated:
      return UIColor(hex: "#888888")
    default:
      return UIColor(hex: "#ffc56e")
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

}
