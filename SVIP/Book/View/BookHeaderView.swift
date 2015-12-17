//
//  BookHeaderView.swift
//  SVIP
//
//  Created by AlexBang on 15/12/17.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class BookHeaderView: UIView {

  @IBOutlet weak var userImageButton: UIButton! {
    didSet {
      userImageButton.layer.masksToBounds = true
      userImageButton.layer.cornerRadius = 28
    }
  }
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var introducesLabel: UILabel!
  @IBOutlet weak var explainLabel: UILabel!
  @IBOutlet weak var hotelNameLabel: UILabel!
  @IBOutlet weak var backImageView: UIImageView!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
