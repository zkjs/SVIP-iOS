//
//  BillListCell.swift
//  SVIP
//
//  Created by Leon King on 3/26/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class BillListCell: UICollectionViewCell {
  @IBOutlet private weak var hotelLabel:UILabel!
  @IBOutlet private weak var timeLabel:UILabel!
  @IBOutlet private weak var moneyLabel:UILabel!
  @IBOutlet private weak var headerView:UIView!
  @IBOutlet private weak var orderNoLabel: UILabel!
  @IBOutlet private weak var hotelNameLabel: UILabel!
  @IBOutlet private var titleLabels: Array<UILabel>?
  
  static let gradientRows = 6
  
  private let hue:CGFloat = 36.0
  private let minSaturation:CGFloat = 0.64
  private let maxSaturation:CGFloat = 1.0
  private var deltaSaturation:CGFloat {
    return maxSaturation - minSaturation
  }
  
  static func reuseIdentifier() -> String {
    return "BillListCell"
  }
  
  var bill: PaylistmModel? {
    didSet {
      if let bill = bill {
        hotelLabel.text = bill.shopname
        timeLabel.text = bill.createtime
        moneyLabel.text = bill.displayAmount
        orderNoLabel.text = bill.orderno
        hotelNameLabel.text = bill.shopname
      }
    }
  }
  
  /* Returns the item index of the currently featured cell */
  var featuredItemIndex: Int {
    if let collectionView = self.superview as? UICollectionView {
      let layout = collectionView.collectionViewLayout as! BillListLayout
      return layout.featuredItemIndex
    }
    return 0
  }
  
  /* Returns the item Cell of the currently featured cell */
  var featuredItem: BillListCell? {
    if let collectionView = self.superview as? UICollectionView {
      return collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: featuredItemIndex, inSection: 0)) as? BillListCell
    }
    return nil
  }
  
  /* Returns the item Cell below the currently featured cell */
  var nextItem: BillListCell? {
    if let collectionView = self.superview as? UICollectionView {
      return collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: featuredItemIndex + 1, inSection: 0)) as? BillListCell
    }
    return nil
  }
  
  /* Returns the indexPath of the cell */
  var indexPath: NSIndexPath {
    if let collectionView = self.superview as? UICollectionView,
      let indexPath = collectionView.indexPathForCell(self){
      return indexPath
    }
    return NSIndexPath(forRow: 0, inSection: 0)
  }
  
  /* Returns the color saturation of current cell header */
  var currentSaturation: CGFloat {
    let rows = self.dynamicType.gradientRows
    let delta = CGFloat(min(max(indexPath.row - featuredItemIndex, 0), rows)) / CGFloat(rows)
    return min(minSaturation + delta * deltaSaturation, maxSaturation)
  }
  
  /* Returns the color saturation the cell header will become */
  var nextSaturation: CGFloat {
    let rows = self.dynamicType.gradientRows
    let delta = CGFloat(min(max(indexPath.row - featuredItemIndex - 1, 0), rows)) / CGFloat(rows)
    return min(minSaturation + delta * deltaSaturation, maxSaturation)
  }
  
  /* Returns the color of current cell */
  private func currentColorForIndexPath(indexPath:NSIndexPath) -> UIColor {
    let rows = self.dynamicType.gradientRows
    let delta = CGFloat(min(max(indexPath.row - featuredItemIndex, 0), rows)) / CGFloat(rows)
    return UIColor(hue: hue/360.0, saturation:min(minSaturation + delta * deltaSaturation, maxSaturation), brightness: 1.0, alpha: 1.0)
  }
  
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
    super.applyLayoutAttributes(layoutAttributes)
    
    let featuredHeight = BillListLayoutConstants.Cell.featuredHeight
    let standardHeight = BillListLayoutConstants.Cell.standardHeight
    
    let delta = 1 - ((featuredHeight - CGRectGetHeight(frame)) / (featuredHeight - standardHeight))
    
    // let scale = max(delta, 0.6)
    // hotelLabel.transform = CGAffineTransformMakeScale(scale, scale)
    
    timeLabel.alpha = delta
    orderNoLabel.alpha = delta
    hotelNameLabel.alpha = delta
    titleLabels?.forEach{ $0.alpha = delta }
    
    var nextItemHeight:CGFloat = CGRectGetHeight(frame)
    if let item = nextItem {
      nextItemHeight = CGRectGetHeight(item.frame)
    }
    let deltaSaturation = fabs(nextSaturation - currentSaturation)
    let deltaColor = 1 - ((featuredHeight - nextItemHeight) / (featuredHeight - standardHeight))
    
    headerView.backgroundColor = UIColor(hue: hue/360.0, saturation: currentSaturation - deltaColor * deltaSaturation, brightness: 1.0, alpha: 1.0)
    
  }
  
  func setCurrentColorForIndexPath(indexPath:NSIndexPath) {
    headerView.backgroundColor = currentColorForIndexPath(indexPath)
  }
  
}
