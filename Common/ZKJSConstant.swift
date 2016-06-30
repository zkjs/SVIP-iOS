//
//  ZKJSConstant.swift
//  SVIP
//
//  Created by Qin Yejun on 4/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

let KNOTIFICATION_LOGINCHANGE = "loginStateChange"                   //登录状态变更
let KNOTIFICATION_LOGOUTCHANGE = "logoutStateChange"                 //退出登录
let KNOTIFICATION_PAYMENT = "KNOTIFICATION_PAYMENT"                  //支付通知
let KNOTIFICATION_WELCOME = "KNOTIFICATION_WELCOME"                  //营销推送
let KNOTIFICATION_CHANGELOGO = "KNOTIFICATION_CHANGELOGO"            //切换logo
let KNOTIFICATION_WELCOME_DISMISS = "KNOTIFICATION_WELCOME_DISMISS"  //关闭营销推送窗口
let KNOTIFICATION_ORDER = "KNOTIFICATION_ORDER"                      //服务完成通知
let KNOTIFICATION_ACT_INV = "KNOTIFICATION_ACT_INV"                  //活动邀请通知
let KNOTIFICATION_ACT_CANCEL = "KNOTIFICATION_ACT_CANCEL"            //活动取消通知
let KNOTIFICATION_ACT_UPDATE = "KNOTIFICATION_ACT_UPDATE"            //活动更新通知

let APP_GLOBAL_TINT_COLOR = UIColor(hex: "#ffc56e")

struct ScreenSize {
  static let SCREEN_WIDTH = CGRectGetWidth(UIScreen.mainScreen().bounds)
  static let SCREEN_HEIGHT = CGRectGetHeight(UIScreen.mainScreen().bounds)
  static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
  static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType {
  static let IS_IPHONE_4_OR_LESS =  UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
  static let IS_IPHONE_5 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
  static let IS_IPHONE_6 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
  static let IS_IPHONE_6P = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
  static let IS_IPAD = UIDevice.currentDevice().userInterfaceIdiom == .Pad
}

// 用户姓名最大长度
let MAX_NAME_LENGTH = 20