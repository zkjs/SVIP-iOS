//
//  BillListVC.swift
//  SVIP
//
//  Created by Qin Yejun on 3/24/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class BillListVC: UICollectionViewController {
  var billListArr = [PaylistmModel]()

  override func viewDidLoad() {
      super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    self.title = "支付记录"
    
    collectionView!.backgroundColor = UIColor(hex: "#f0f0f0")
    collectionView!.decelerationRate = UIScrollViewDecelerationRateFast
    //let layout = collectionView!.collectionViewLayout as! BillListLayout
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    self.showHUDInView(view, withLoading: "")
    
    loadOrderList()
  }
  
  func loadOrderList() {
    HttpService.sharedInstance.userPaylistInfo(.Paid, page: 0) {[weak self] (data,error) -> Void in
      guard let strongSelf = self else {
        return
      }
       strongSelf.hideHUD()
      if let error = error {
        if let msg = error.userInfo["resDesc"] as? String {
          strongSelf.showHint(msg)
        } else {
          strongSelf.showHint("数据请求错误:\(error.code)")
        }
      } else {
        if let json = data {
          strongSelf.billListArr = json
          strongSelf.collectionView?.reloadData()
        }
      }
      
    }
  }
  

  // MARK: UICollectionViewDataSource

  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }


  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return billListArr.count
  }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(BillListCell.reuseIdentifier(), forIndexPath: indexPath) as! BillListCell

    cell.bill = billListArr[indexPath.row]
    cell.setCurrentColorForIndexPath(indexPath)

    return cell
  }
  
  

  // MARK: UICollectionViewDelegate
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    guard let layout = collectionView.collectionViewLayout as? BillListLayout else {
      return
    }
    let y = CGFloat(indexPath.item) * layout.dragOffset
    collectionView.scrollRectToVisible(CGRectMake(0, y, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 64), animated: true)
  }

}
