//
//  AmountCollectionViewCell.swift
//  SVIP
//
//  Created by AlexBang on 16/4/22.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class AmountCollectionViewCell: UICollectionViewCell {
    
  @IBOutlet weak var amountLabel: UILabel!
  
  override func awakeFromNib() {
    
  }
  func configCell(title:String) {
    amountLabel.text = title

  }
}
