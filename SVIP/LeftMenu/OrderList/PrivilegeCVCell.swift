//
//  PrivilegeCVCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/23.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class PrivilegeCVCell: UICollectionViewCell {

  @IBOutlet weak var itemLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView! {
    didSet {
      imageView.contentMode = UIViewContentMode.ScaleAspectFit
    }
  }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  class func reuseIdentifier() -> String {
    return "PrivilegeCVCell"
  }
  
  class func nibName() -> String {
    return "PrivilegeCVCell"
  }
  func setData(item: String,string:String) {
    imageView.image = UIImage(named: string)
    itemLabel.text = item
  }
}
