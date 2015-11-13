//
//  MainHeaderView.swift
//  SVIP
//
//  Created by AlexBang on 15/11/10.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class MainHeaderView: UIView {

  @IBOutlet weak var orderStatusLabel: UILabel!
  @IBOutlet weak var gradeLabel: UILabel!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userImageButton: UIButton! {
    didSet {
      userImageButton.layer.masksToBounds = true
      userImageButton.layer.cornerRadius = 40
    }
  }

  @IBOutlet weak var leftButton: UIButton!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
