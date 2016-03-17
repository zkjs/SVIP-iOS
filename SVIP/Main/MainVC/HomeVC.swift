//
//  HomeVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/8.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class HomeVC: UIViewController {
  
  let Identifier = "HomeVCCell"
  let locationManager = CLLocationManager()
  
  var refreshHomeDelegate:refreshHomeVCDelegate?
  var bluetoothManager = CBCentralManager()
  var floatingVC = FloatingWindowVC()
  var originOffsetY: CGFloat = 0.0
  var bluetoothStats: Bool!
  
  let viewModel = HomeViewModel(city: "长沙")
  
  enum TableSection:Int {
    case Header = 0,Privilege,Order,Recommed
  }
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var privilegeButton: UIButton!{
    didSet {
      privilegeButton.layer.masksToBounds = true
      privilegeButton.layer.cornerRadius = 30
    }
  }
  @IBOutlet weak var privilegeButtonConstraintTop: NSLayoutConstraint!
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("HomeVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if tableView.respondsToSelector(Selector("setSeparatorInset:")) {
      tableView.separatorInset = UIEdgeInsetsZero
    }
    if tableView.respondsToSelector(Selector("setLayoutMargins:")) {
      tableView.layoutMargins = UIEdgeInsetsZero
    }
   
    LocationStateObserver.sharedInstance.start()
    setupBluetoothManager()
    self.navigationController!.navigationBar.translucent = true
    self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
    self.navigationController!.navigationBar.shadowImage = UIImage()
    
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Identifier)
    let nibName = UINib(nibName: HomeCell.nibName(), bundle: nil)
    tableView.registerNib(nibName, forCellReuseIdentifier: HomeCell.reuseIdentifier())
    let NibName = UINib(nibName: CustonCell.nibName(), bundle: nil)
    tableView.registerNib(NibName, forCellReuseIdentifier: CustonCell.reuseIdentifier())
    tableView.showsVerticalScrollIndicator = false
    
    tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, 100, 40))
    originOffsetY = privilegeButton.frame.origin.y
    
    let imageURL = AccountManager.sharedInstance().avatarURL
    if TokenPayload.sharedInstance.isLogin {
      privilegeButton.sd_setBackgroundImageWithURL(NSURL(string: imageURL), forState: .Normal, placeholderImage: UIImage(named: "logo_white"))
      privilegeButton.addTarget(self, action: "getPrivilege", forControlEvents: UIControlEvents.TouchUpInside)
      privilegeButton.userInteractionEnabled = false
    } else {
      privilegeButton.setBackgroundImage(UIImage(named: "logo_white"), forState: UIControlState.Normal)
      privilegeButton.userInteractionEnabled = false
    }
    
    refreshHomeDelegate = self
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLoginStateChange:", name: KNOTIFICATION_LOGINCHANGE, object: nil)
    
    reloadImages()
    reloadData()
    
  }
  

  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    if cell.respondsToSelector(Selector("setSeparatorInset:")) {
      cell.separatorInset = UIEdgeInsetsZero
    }
    if cell.respondsToSelector(Selector("setLayoutMargins:")) {
      cell.layoutMargins = UIEdgeInsetsZero
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBarHidden = true
    navigationController?.navigationBar.translucent = true
    
    if viewModel.fetchDataError {
      reloadData()
    }
    if viewModel.fetchImageError {
      reloadImages()
    }
 }
  
  func reloadData() {
    viewModel.refreshData { (error) -> Void in
      if error == nil {
        self.refreshTableView()
      }
    }
  }
  
  func reloadImages() {
    // fetch images from server if no cache
    if viewModel.imgUrl == nil {
      viewModel.loadImageData({ (error) -> Void in
        if error == nil {
          self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Fade)
        }
      })
    }
  }
  
  // TableView Scroller Delegate
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBarHidden = false
    navigationController?.navigationBar.translucent = false
  }
  
  
  func refreshTableView() {
    tableView.reloadData()
    tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    let offsetY = scrollView.contentOffset.y
    privilegeButtonConstraintTop.constant = originOffsetY - offsetY - 20
  }
  
  func login(sender:UIButton) {
    let nc = BaseNC(rootViewController: LoginVC())
    self.presentViewController(nc, animated: true, completion: nil)
  }

  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 4
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == TableSection.Header.rawValue {
      return 1
    } else if section == TableSection.Privilege.rawValue {
      return min(7, viewModel.privilegeArray.count)
    } else if section == TableSection.Order.rawValue {
      return viewModel.orderArray.count
    } else {
      return viewModel.recommendArray.count
    }
  }
  
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == TableSection.Header.rawValue {
      return CustonCell.height()
    } else {
      return HomeCell.height()
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == TableSection.Header.rawValue {
      let headercell = tableView.dequeueReusableCellWithIdentifier("CustonCell", forIndexPath: indexPath) as! CustonCell
      headercell.selectionStyle = UITableViewCellSelectionStyle.None
      headercell.setData(viewModel.activate,homeUrl: viewModel.imgUrl ?? "")
      headercell.activeButton.addTarget(self, action: "activeCode:", forControlEvents: UIControlEvents.TouchUpInside)
      headercell.loginButton.addTarget(self, action: "login:", forControlEvents: UIControlEvents.TouchUpInside)
      let singleTap = UITapGestureRecognizer(target: self, action: "handleSingleTap")
      headercell.bluetoolView.addGestureRecognizer(singleTap)
      //      headercell.PrivilegeButton.addTarget(self, action: "getPrivilege", forControlEvents: .TouchUpInside)
      return headercell
    } else if indexPath.section == TableSection.Privilege.rawValue {
      let cell = tableView.dequeueReusableCellWithIdentifier("HomeCell", forIndexPath: indexPath) as! HomeCell
      cell.configCell(privilege: viewModel.privilegeArray[indexPath.row])
      return cell
    } else if indexPath.section == TableSection.Order.rawValue {
      let cell = tableView.dequeueReusableCellWithIdentifier("HomeCell", forIndexPath: indexPath) as! HomeCell
      cell.configCell(pushInfo: viewModel.orderArray[indexPath.row])
      return cell
    } else if indexPath.section == TableSection.Recommed.rawValue{//recommend
      let cell = tableView.dequeueReusableCellWithIdentifier("HomeCell", forIndexPath: indexPath) as! HomeCell
      cell.configCell(pushInfo: viewModel.recommendArray[indexPath.row])
      return cell
    }
    return UITableViewCell()
  }
  
  func activeCode(sender:UIButton) {
    //激活页面
    let vc = InvitationCodeVC()
    self.presentViewController(vc, animated: true, completion: nil)
  }
  
  
  /*func getPrivilege() {
    countTimer = 0
    self.timer.invalidate()
    
    if viewModel.privilegeArray.count == 0 {
      return
    }
    floatingVC = FloatingWindowVC()
    floatingVC.delegate = self
    floatingVC.privilegeArray = viewModel.privilegeArray
    self.view.addSubview(floatingVC.view)
    self.addChildViewController(floatingVC)
    
    privilegeButton.sd_setBackgroundImageWithURL(NSURL(string: AccountManager.sharedInstance().avatarURL.fullImageUrl), forState: .Normal, placeholderImage: UIImage(named: "logo_white"))
    privilegeButton.userInteractionEnabled = false
  }*/
  
  func handleSingleTap() {
    let vc = BluetoothDescriptionVC()
    vc.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {  
    if viewModel.recommendArray.count != 0 {
      if indexPath.section == 2 {
        /*let vc = OrderListTVC()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)*/
      }
      if indexPath.section == 3 {
        let pushInfo = viewModel.recommendArray[indexPath.row]
        if pushInfo.shopid == "" {
          //          let vc = WebViewVC()
          //          vc.hidesBottomBarWhenPushed = true
          //          vc.url = "http://www.zkjinshi.com/about_us/about_svip.html"
          //          self.navigationController?.pushViewController(vc, animated: true)
        } else {
          pushToBookVC(pushInfo)
        }
      }
    }
  }
  
  func pushToBookVC(pushinfo: PushInfoModel) {
    if pushinfo.shopid == "" {
      ZKJSTool.showMsg("暂无商家信息")
      return
    }
    let storyboard = UIStoryboard(name: "BusinessDetailVC", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("BusinessDetailVC") as! BusinessDetailVC
    vc.shopid = NSNumber(integer: Int(pushinfo.shopid)!)
    vc.shopName = pushinfo.shopName
    vc.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(vc, animated: true)
  }
  
  private func setupBluetoothManager() {
    bluetoothManager = CBCentralManager(delegate: self, queue: nil)
  }
  
  func didLoginStateChange(notification: NSNotification) {
    reloadData()
    reloadImages()
  }
  
}



// MARK: - CBCentralManagerDelegate
extension HomeVC: CBCentralManagerDelegate {

  func centralManagerDidUpdateState(central: CBCentralManager) {
    switch central.state {
    case .PoweredOn:
      self.bluetoothStats = true
      let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! CustonCell
      cell.bluetoolView.hidden = true
      BeaconMonitor.sharedInstance.startMonitoring()
      print(".PoweredOn")
    case .PoweredOff:
      self.bluetoothStats = false
      let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! CustonCell
      cell.bluetoolView.hidden = false
      print(".PoweredOff")
    case .Resetting:
      print(".Resetting")
    case .Unauthorized:
      print(".Unauthorized")
    case .Unknown:
      print(".Unknown")
    case .Unsupported:
      print(".Unsupported")
    }
  }
}

extension HomeVC: refreshHomeVCDelegate {
  //refreshHomeVCDelegate
  func refreshHomeVC(set: Bool) {
    //    getPushInfoData()
    self.refreshTableView()
  }
}
