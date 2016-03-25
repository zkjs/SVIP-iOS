//
//  BillListVC.swift
//  SVIP
//
//  Created by Qin Yejun on 3/24/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

private let reuseIdentifier = "BillListCell"

class BillListVC: UICollectionViewController {
  var billListArr = [PaylistmModel]()

  override func viewDidLoad() {
      super.viewDidLoad()

      // Uncomment the following line to preserve selection between presentations
      // self.clearsSelectionOnViewWillAppear = false

      // Register cell classes
      self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

      // Do any additional setup after loading the view.
    self.title = "支付记录"
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
      // #warning Incomplete implementation, return the number of sections
      return 0
  }


  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      // #warning Incomplete implementation, return the number of items
      return 0
  }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
  
      // Configure the cell
  
      return cell
  }

  // MARK: UICollectionViewDelegate

  /*
  // Uncomment this method to specify if the specified item should be highlighted during tracking
  override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
      return true
  }
  */

  /*
  // Uncomment this method to specify if the specified item should be selected
  override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
      return true
  }
  */

  /*
  // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
  override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
      return false
  }

  override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
      return false
  }

  override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
  
  }
  */

}
