//
//  ReasonCollectionVC.swift
//  SVIP
//
//  Created by AlexBang on 16/4/22.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

private let ReasonOfTipsIdentifier = "ReasonOfTipsCollectionViewCell"
protocol ReasonChooseDelegate {
  func didSelectReason(reason:String)
}
let ReasonData = [
  ("超预期"),("态度好"),("质量好"),("说不清"),("一种感觉"),("喜欢给")
]
class ReasonCollectionVC: UICollectionViewController {
  var selectedIndex:NSIndexPath?
  var Delegate:ReasonChooseDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Register cell classes
    let width = (CGRectGetWidth(collectionView!.frame) - 100)/3
    let layout = collectionViewLayout as! UICollectionViewFlowLayout
    layout.itemSize = CGSize(width: width, height: 40)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: UICollectionViewDataSource

  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }

    // MARK: UICollectionViewDataSource

  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return ReasonData.count
  }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ReasonOfTipsIdentifier, forIndexPath: indexPath) as! ReasonOfTipsCollectionViewCell
    let tip = ReasonData[indexPath.row] 
    cell.configCell(tip)
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ReasonOfTipsCollectionViewCell
    cell.backgroundColor = UIColor(hex: "F89502")
    cell.contentView.backgroundColor = UIColor(hex: "F89502")
    if let selectedIndex = selectedIndex where selectedIndex != indexPath {
      collectionView.deselectItemAtIndexPath(selectedIndex, animated: true)
    }
    selectedIndex = indexPath
    let reason = ReasonData[indexPath.row]
    Delegate?.didSelectReason(reason)
  }
  
  override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ReasonOfTipsCollectionViewCell
    cell.backgroundColor = UIColor(hex: "888888")
    cell.contentView.backgroundColor = UIColor(hex: "888888")
  }

}
