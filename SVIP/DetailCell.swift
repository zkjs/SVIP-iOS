//
//  DetailCell.swift
//  SVIP
//
//  Created by AlexBang on 16/5/7.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {

  @IBOutlet weak var detailDescLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
      self.contentView.backgroundColor = UIColor(patternImage: UIImage(named: "texture_bg")!)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
