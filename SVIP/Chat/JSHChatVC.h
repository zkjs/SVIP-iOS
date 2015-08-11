//
//  JSHChatVC.h
//  HotelVIP
//
//  Created by Hanton on 6/3/15.
//  Copyright (c) 2015 ZKJS. All rights reserved.
//

#import "XHMessageTableViewController.h"

@class BookOrder;

typedef NS_ENUM(NSInteger, ChatType) {
  ChatNewSession,
  ChatOldSession,
  ChatCallingWaiter,
  ChatService,
  ChatOrder
};

@interface JSHChatVC : XHMessageTableViewController
@property (nonatomic, strong) NSString *shopID;
@property (nonatomic, strong) NSString *shopName;
@property (nonatomic, strong) BookOrder *order;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *condition;

- (instancetype)initWithChatType:(ChatType)chatType;
@end
