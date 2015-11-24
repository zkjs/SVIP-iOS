//
//  BookVC.swift
//  SVIP
//
//  Created by dai.fengyi on 15/6/30.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

typealias RoomSelectionBlock = (RoomGoods) -> ()

class BookVC: UIViewController , UITableViewDelegate, UITableViewDataSource{

  @IBOutlet private var layoutConstaintArray: [NSLayoutConstraint]!
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var selectionView: UIView!
  @IBOutlet private weak var selectionViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet private var leftSelectButtonArray: [BookItemButton]!
  @IBOutlet private var rightSelectButtonArray: [BookItemButton]!
  @IBOutlet weak var okButton: UIButton!
  
  //Data
  var shopid: NSNumber!
  var dataArray = NSMutableArray()
  var selection: RoomSelectionBlock?  // Hanton
  private var filtedArray = NSMutableArray()
  private var selectedRow : Int = 0
  
  //MARK:- FUNCTION
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: "BookVC", bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    setUI()
    loadData()
  }
  
  private func setUI() {
    title = NSLocalizedString("ROOM_TYPE", comment: "")
    
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 135, 0)
    
    for button in leftSelectButtonArray {
      button .addTarget(self, action: NSSelectorFromString("categorySelect:"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    for button in rightSelectButtonArray {
      button .addTarget(self, action: Selector("breakfastSelect:"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    okButton.setTitle(NSLocalizedString("CONFIRM", comment: ""), forState: UIControlState.Normal)
  }
  
  private func loadData() {
    let button = self.leftSelectButtonArray.last
    self.categorySelect(button!)
  }
  
  private func filtArray(keyString: String?)->NSMutableArray {
    if keyString == "全部" {
      return NSMutableArray(array: dataArray)
    }
    let mutArr = NSMutableArray()
    for tempObject in dataArray {
      let goods = tempObject as! RoomGoods
      if goods.room == keyString {
        mutArr .addObject(goods)
      }
    }
    return mutArr
  }
  
  override func updateViewConstraints() {
    let buttonCount = layoutConstaintArray.count
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let marginWidth = (Double(screenWidth) - Double(buttonCount) * 30.0) / Double(layoutConstaintArray.count + 1)
    for constrainst in layoutConstaintArray {
      constrainst.constant = CGFloat(marginWidth)
    }
    super.updateViewConstraints()
  }

  //MARK:- BUTTON ACTION
  
  func categorySelect(sender: UIButton) {
    for button in leftSelectButtonArray {
      button.selected = false
    }
    sender.selected  = true
    
    filtedArray = self .filtArray(sender.titleLabel?.text)
    tableView .reloadData()
    self.selectedRow = 0
    let numberOfRow = self.tableView .numberOfRowsInSection(0)
    if numberOfRow != 0 {
      self.tableView .selectRowAtIndexPath(NSIndexPath(forRow: self.selectedRow, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Top)
    }
  }
  
  func breakfastSelect(sender: UIButton) {
    for button in rightSelectButtonArray {
      button.selected = false
    }
    sender.selected  = true
  }

  @IBAction private func book(sender: UIButton) {
    if self.filtedArray.count == 0 {
      return
    }
    let goods = self.filtedArray[selectedRow] as! RoomGoods
    for button in rightSelectButtonArray {
      if button.selected == true {
        goods.meat = button.titleLabel?.text
      }
    }

    if selection != nil {
      selection!(goods)
    }
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  //MARK:- TABLEVIEW
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.filtedArray.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 160+8*2
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView .dequeueReusableCellWithIdentifier("BookVC") as? BookRoomCell
    if cell == nil {
      let arr = NSBundle .mainBundle() .loadNibNamed("BookRoomCell", owner: nil, options: nil) as Array
      cell = (arr[0] as! BookRoomCell)
    }
    cell!.goods = (filtedArray[indexPath.row] as! RoomGoods)
    return cell!
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
    let oldCell = tableView .cellForRowAtIndexPath(NSIndexPath(forRow: selectedRow, inSection: 0))
    oldCell?.selected = false
    let newCell = tableView .cellForRowAtIndexPath(indexPath)
    newCell?.selected = true
    self.selectedRow = indexPath.row
  }
  
  //MARK:- SCROLLVIEW
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    selectionViewBottomConstraint.constant = 0
    constraintAnimation(selectionView)
  }

  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      selectionViewBottomConstraint.constant = 0
      constraintAnimation(selectionView)
    }
  }

  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    selectionViewBottomConstraint.constant = -135
    constraintAnimation(selectionView)
  }
  
  private func constraintAnimation(sender: UIView) {
    UIView .animateWithDuration(0.3, animations: { () -> Void in
      sender .layoutIfNeeded()
    })
  }
}