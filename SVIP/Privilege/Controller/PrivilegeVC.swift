//
//  PrivilegeVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/23.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit
enum collectionViewItem: Int {
  case freeReception = 0
  case Integra
  case ExclusiveCustomeService
  case moreConstruction
}
let itemArray = ["免前台","积分","我的专属客服","更多开发中"]
let imageArray = ["ic_mianqiantai-1","ic_jifen","ic_zhuanshukefu","ic_gengduojianshezhong"]
class PrivilegeVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
  
  @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
      let item1 = UIBarButtonItem(image: UIImage(named: "ic_fanhui"), style:.Plain, target: self, action: "popTotopView:")
      self.navigationItem.leftBarButtonItem = item1
      setupUI()

        // Do any additional setup after loading the view.
    }
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = false
    
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func popTotopView(sender:UIBarButtonItem) {
    self.navigationController?.popViewControllerAnimated(true)
  }
  func setupUI() {
    let nibName = UINib(nibName: "PrivilegeCVCell", bundle: nil)
    collectionView.registerNib(nibName, forCellWithReuseIdentifier: "PrivilegeCVCell")
    //collectionView.registerClass(PrivilegeCVCell.classForCoder(), forCellWithReuseIdentifier: PrivilegeCVCell.reuseIdentifier())
  }
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 4
  }
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSizeMake(view.bounds.width/3.0, view.bounds.width/3.0)
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PrivilegeCVCell.reuseIdentifier(), forIndexPath: indexPath) as! PrivilegeCVCell
    let itemLabel = itemArray[indexPath.row]
    let string = imageArray[indexPath.row]
    cell.setData(itemLabel,string: string)
    return cell
  }
  
  //设置每个cell最小行间距
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 0
  }
  //设置每个cell的列间距
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 0
  }
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
     if let buttonIndex = collectionViewItem(rawValue: indexPath.row) {
      var vc = UIViewController()
      switch buttonIndex {
      case .freeReception:
        vc = SkipCheckInSettingViewController()
      case .Integra:
      vc = IntegralVC()
      case .ExclusiveCustomeService:
       let hotelVC = ComprehensiveVC()
        hotelVC.type = ComprehensiveType.customerService
        self.navigationController?.pushViewController(hotelVC, animated: true)
        return
      case .moreConstruction:
        break
      }
//      if let navi = self.sideMenuViewController.contentViewController as? UINavigationController {
//        self.sideMenuViewController.hideMenuViewController()
//        navi.pushViewController(vc, animated: true)
//      }
    } else {
      print("在枚举LeftButton中未找到\(indexPath.row)")
    }

  }
}
