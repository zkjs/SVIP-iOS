//
//  CityVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/14.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

typealias sendValueClosure=(string:String)->Void

class CityVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
  var myView:CityHeaderView!
  var cityArray = [String]()
  //声明一个闭包
  var testClosure:sendValueClosure?
  var city:String!
  
  @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
     navigationController?.navigationBarHidden = false
      getCityListData()
      
      let leftBarBtn = UIBarButtonItem(title: "|想去哪里", style: .Plain, target: self,
        action: nil)
      self.navigationItem.leftBarButtonItem = leftBarBtn
     // UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.hx_colorWithHexString("ffc56e")]
      let item2 = UIBarButtonItem(image: UIImage(named: "ic_quxiao_b"), style: UIBarButtonItemStyle.Plain, target: self, action: "cancle:")
      navigationItem.rightBarButtonItem = item2
      
      let nibName = UINib(nibName: HotCityCell.nibName(), bundle: nil)
      tableView.registerNib(nibName, forCellReuseIdentifier: HotCityCell.reuseIdentifier())                                                            
      tableView.tableFooterView = UIView()
      self.navigationController?.navigationBar.tintColor = UIColor.blackColor()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("CityVC", owner:self, options:nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    
    tableView.reloadData()
    
    
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  func cancle(sender:UIBarButtonItem) {
    self.dismissViewControllerAnimated(true) { () -> Void in
     }
  }
  func getCityListData() {
    ZKJSHTTPSessionManager.sharedInstance().getCityListSuccess({ (task: NSURLSessionDataTask!, responsObject: AnyObject!) -> Void in
      if let array = responsObject as? NSArray {
        for dic in array {
          let string = dic["city"] as! String
          self.cityArray.append(string)
        }
        self.tableView.reloadData()
      }
      
      }) { (task:NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  
  //MARK -TableView Data Source
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cityArray.count
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
    
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 50
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
      let cell = tableView.dequeueReusableCellWithIdentifier(HotCityCell.reuseIdentifier(), forIndexPath: indexPath) as! HotCityCell
      cell.selectionStyle = UITableViewCellSelectionStyle.None
     cell.textLabel?.text = cityArray[indexPath.row]
      return cell
  
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    myView = NSBundle.mainBundle().loadNibNamed("CityHeaderView", owner: self, options: nil).first as! CityHeaderView
      return myView
    }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    /**
    先判断闭包是否存在，然后再调用
    */
    let string = cityArray[indexPath.row]
    if (testClosure != nil){
      testClosure!(string: string)
    }

    self.dismissViewControllerAnimated(true, completion: nil)
  }
    
    
    
    
  }
