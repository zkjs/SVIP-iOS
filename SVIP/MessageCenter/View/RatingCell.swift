//
//  RatingCell.swift
//  SVIP
//
//  Created by Hanton on 12/17/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class RatingCell: UITableViewCell {
  
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var ratingView: EDStarRating!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    ratingLabel.text = ""
    ratingView.starImage = UIImage(named: "ic_star_nor")
    ratingView.starHighlightedImage = UIImage(named: "ic_star_pre")
    ratingView.maxRating = 5
    ratingView.horizontalMargin = 12
  }
  
  class func reuseIdentifier() -> String {
    return "RatingCell"
  }
  
  class func nibName() -> String {
    return "RatingCell"
  }
  
  class func height() -> CGFloat {
    return 45
  }
  
  func setData(sales: SalesModel) {
    ratingLabel.text = sales.avg_score.stringValue
    ratingView.rating = sales.avg_score.floatValue
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
