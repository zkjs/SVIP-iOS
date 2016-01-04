//
//  CommentsCell.swift
//  SVIP
//
//  Created by AlexBang on 16/1/3.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class CommentsCell: UITableViewCell {

  @IBOutlet weak var contentEvaluation: UILabel!
  @IBOutlet weak var commentsDateLabel: UILabel!
  @IBOutlet weak var appraiserNameLabel: UILabel!
  @IBOutlet weak var appraiserImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
  class func reuseIdentifier() -> String {
    return "CommentsCell"
  }
  
  class func nibName() -> String {
    return "CommentsCell"
  }
  
  class func height() -> CGFloat {
    return 130.0
  }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
