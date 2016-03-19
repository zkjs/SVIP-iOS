//
//  PayListTVC.swift
//  SVIP
//
//  Created by AlexBang on 16/3/19.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class PayListTVC: UITableViewController {
  var orderStatus: FacePayOrderStatus!
  var paylistArr = [PaylistmModel]()
        

    override func viewDidLoad() {
        super.viewDidLoad()
      let nibName = UINib(nibName: PaylistCell.nibName(), bundle: nil)
      tableView.registerNib(nibName, forCellReuseIdentifier: PaylistCell.reuseIdentifier())

      if orderStatus == .NotPaid {
        self.title = "支付确认"
      } else if orderStatus == .Paid {
        self.title = "支付记录"
      }
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "paymentResult", name: FACEPAY_RESULT_NOTIFICATION, object: nil)

    }

    override func loadView() {
      NSBundle.mainBundle().loadNibNamed("PayListTVC", owner:self, options:nil)
    }

    override func viewWillAppear(animated: Bool) {
      super.viewWillAppear(true)
      self.showHUDInView(view, withLoading: "")
      
      loadOrderList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    func loadOrderList() {
      HttpService.sharedInstance.userPaylistInfo(orderStatus, page: 0) { (data,error) -> Void in
        if let _ = error {
          self.hideHUD()
          
        } else {
          if let json = data {
            self.paylistArr = json
            self.tableView.reloadData()
            self.hideHUD()
          }
        }
        
      }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return paylistArr.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier(PaylistCell.reuseIdentifier(), forIndexPath: indexPath) as! PaylistCell
      let pay:PaylistmModel = paylistArr[indexPath.row]
      cell.setData(pay)
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      return cell
    }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return PaylistCell.height()
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let pay = paylistArr[indexPath.row]
    if pay.status == .NotPaid {
      let vc = PayInfoVC()
      let childView = vc.view
      vc.payInfo = pay
      self.view.addSubview(childView)
      self.addChildViewController(vc)
      vc.payInfo = pay
      vc.didMoveToParentViewController(self)
      childView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-100, self.view.frame.size.width, self.view.frame.size.height+100)
    }
   }
  
  func paymentResult() {
    loadOrderList()
  }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
