//
//  ZKJSConstant.swift
//  SVIP
//
//  Created by Qin Yejun on 4/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

let KNOTIFICATION_LOGINCHANGE = "loginStateChange"
let KNOTIFICATION_LOGOUTCHANGE = "logoutStateChange"
let KNOTIFICATION_PAYMENT = "KNOTIFICATION_PAYMENT"
let KNOTIFICATION_WELCOME = "KNOTIFICATION_WELCOME"
let KNOTIFICATION_CHANGELOGO = "KNOTIFICATION_CHANGELOGO"
let KNOTIFICATION_BALANCECHANGE = "KNOTIFICATION_BALANCECHANGE"

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
}