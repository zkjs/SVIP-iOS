//
//  ReasonOfTipsCollectionViewCell.swift
//  SVIP
//
//  Created by AlexBang on 16/4/22.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class ReasonOfTipsCollectionViewCell: UICollectionViewCell {
    
  @IBOutlet weak var reasonLabel: UILabel!
      
  

  
  override func awakeFromNib() {
    self.contentView.layer.borderWidth = 1
    self.contentView.layer.borderColor = UIColor.whiteColor().CGColor

  }
  
  func configCell(tips:Count) {
    reasonLabel.text = tips.reason
    
  }
}
