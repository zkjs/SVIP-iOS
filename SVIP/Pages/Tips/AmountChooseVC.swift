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
  ("￥5", 5.0, 0,30),
  ("￥10", 10.0 , 30,60),
  ("￥?", 0.0, 0, 0),
  ("￥20", 20.0, 60,80),
  ("￥50", 50.0, 80,95),
  ("￥100",  100.0, 95,100),
  
]

class AmountChooseVC: UICollectionViewController {
  var selectedIndex:NSIndexPath?
  var delegate : AmountChooseDelegate?
  let wallet = StorageManager.sharedInstance().curentCash()
  

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
    if Double(tip.1) > wallet {
      cell.contentView.backgroundColor = UIColor(hex: "B8B8B8")
    }
    return cell
   
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let tip = AmountData[indexPath.row]
    if Double(tip.1) > wallet {
      return
    }
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
    let tip = AmountData[indexPath.row]
    if Double(tip.1) > wallet {
      return
    }
    if let selectedIndex = selectedIndex where selectedIndex == indexPath {
      delegate?.didSelectAmount(0)
      self.selectedIndex = nil
    }
    print("de select:\(indexPath.row)")
    let cell = collectionView.cellForItemAtIndexPath(indexPath) as! AmountCollectionViewCell
    cell.backgroundColor = UIColor(hex: "C17E22")
    cell.contentView.backgroundColor = UIColor(hex: "C17E22")
  }


  
  func getRandomAmount() -> Double {
    if wallet < 5 {
      showHint("余额不足")
      return 0
    }
    let total = AmountData.reduce(0) { (total, amount) -> Int in
      if wallet > amount.1 {
        return max(total, amount.3)
      }
      return total
    }
    let p = Int(arc4random() % UInt32(total))+1 
    print("\(total), \(p)")
    if let amount = AmountData.filter({ $0.2 < p &&  $0.3 >= p }).first {
      print(amount.1)
      return amount.1
    }
    return 0
  }
  
  
}
