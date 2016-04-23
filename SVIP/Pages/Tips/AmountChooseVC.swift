//
//  AmountChooseVC.swift
//  SVIP
//
//  Created by AlexBang on 16/4/22.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

private let AmountReuseIdentifier = "AmountCollectionViewCell"

protocol AmountChooseDelegate {
  func didSelectAmount(amount:Double)
}

let AmountData = [
  ("￥50", 50.0),
  ("￥100",  100.0),
  ("￥?", 0.0),
  ("￥10", 10.0),
  ("￥5", 5.0),
  ("￥20", 20.0),
]

class AmountChooseVC: UICollectionViewController {
  var selectedIndex:NSIndexPath?
  var delegate : AmountChooseDelegate?

  override func viewDidLoad() {
      super.viewDidLoad()

      // Uncomment the following line to preserve selection between presentations
      // self.clearsSelectionOnViewWillAppear = false

      // Register cell classes
    let width = (CGRectGetWidth(collectionView!.frame) - 30)/3
    let layout = collectionViewLayout as! UICollectionViewFlowLayout
    layout.itemSize = CGSize(width: width, height: width)

      // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      // Get the new view controller using [segue destinationViewController].
      // Pass the selected object to the new view controller.
  }
  */

  // MARK: UICollectionViewDataSource

  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }


  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return AmountData.count
  }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AmountReuseIdentifier, forIndexPath: indexPath) as! AmountCollectionViewCell
    let tip = AmountData[indexPath.row]
    cell.configCell(tip.0)
    return cell
   
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let cell = collectionView.cellForItemAtIndexPath(indexPath) as! AmountCollectionViewCell
    cell.backgroundColor = UIColor(hex: "F89502")
    cell.contentView.backgroundColor = UIColor(hex: "F89502")
    if let selectedIndex = selectedIndex where selectedIndex != indexPath {
      collectionView.deselectItemAtIndexPath(selectedIndex, animated: true)
    }
    selectedIndex = indexPath
    
    var amount = 0.0
    if indexPath.row == 2 {//random
      amount = getRandomAmount()
    } else {
      let tip = AmountData[indexPath.row]
      amount = tip.1
    }
    
    delegate?.didSelectAmount(amount)
    print("select \(selectedIndex?.row)")
  }
  
  override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    print("de select:\(indexPath.row)")
    let cell = collectionView.cellForItemAtIndexPath(indexPath) as! AmountCollectionViewCell
    cell.backgroundColor = UIColor(hex: "C17E22")
    cell.contentView.backgroundColor = UIColor(hex: "C17E22")
  }


  
  func getRandomAmount() -> Double {
    return 50
  }
  
  
}
