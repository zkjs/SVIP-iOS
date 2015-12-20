//
//  SalesDetailHeaderView.swift
//  SVIP
//
//  Created by Hanton on 12/17/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class SalesDetailHeaderView: UIView {

  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var shopNameLabel: UILabel!
  @IBOutlet weak var lastLoginLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    
    nameLabel.text = ""
    shopNameLabel.text = ""
    lastLoginLabel.text = ""
  }
}
