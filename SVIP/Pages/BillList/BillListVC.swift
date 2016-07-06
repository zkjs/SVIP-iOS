//
//  BillListVC.swift
//  SVIP
//
//  Created by Qin Yejun on 3/24/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class BillListVC: UICollectionViewController {
  var shopid = ""
  
  var billListArr = [PaylistmModel]()
  var balance = 0.0

  override func viewDidLoad() {
      super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    self.title = "支付记录"
    
    collectionView!.backgroundColor = UIColor(hex: "#f0f0f0")
    collectionView!.decelerationRate = UIScrollViewDecelerationRateFast
    //let layout = collectionView!.collectionViewLayout as! BillListLayout
    
    //let rightButton = UIBarButtonItem(image: UIImage(named: "ic_balance"), landscapeImagePhone: nil, style: .Plain, target: self, action: "showBalance:")
    //navigationItem.rightBarButtonItem = rightButton
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    self.showHUDInView(view, withLoading: "")
    
    loadOrderList()
    //getBalance()
  }
  
  func loadOrderList() {
    HttpService.sharedInstance.userPaylistInfo(.Paid, page: 0, shopid: shopid) {[weak self] (data,error) -> Void in
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
  
  func showBalance(sender:AnyObject) {
    
    let storyboard = UIStoryboard(name: "BillList", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("BalancePopoverVC") as! BalancePopoverVC
    vc.balance = balance
    vc.modalPresentationStyle = .Popover
    vc.popoverPresentationController?.permittedArrowDirections = .Up
    vc.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem;
    vc.popoverPresentationController?.permittedArrowDirections = .Up;
    vc.popoverPresentationController?.delegate = self;
    vc.preferredContentSize = CGSizeMake(180, 60);
    presentViewController(vc, animated: true, completion: nil)
    
  }
  
  // 账户余额
  func getBalance() {
    HttpService.sharedInstance.getBalance { (balance, error) -> Void in
      if error == nil {
        self.balance = balance
      }
    }
  }
  
}

extension BillListVC:UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return .None
  }
}

extension BillListVC {

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
