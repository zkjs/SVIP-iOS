//
//  JSHChatVC.h
//  HotelVIP
//
//  Created by Hanton on 6/3/15.
//  Copyright (c) 2015 ZKJS. All rights reserved.
//

#import "XHMessageTableViewController.h"

//@class BookOrder;

typedef NS_ENUM(NSInteger, ChatType) {
  ChatNewSession,
  ChatOldSession,
  ChatCallingWaiter,
  ChatService
};

@interface JSHChatVC : XHMessageTableViewController
@property (nonatomic, strong) NSString *shopID;
@property (nonatomic, strong) NSDictionary *order;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *condition;

- (instancetype)initWithChatType:(ChatType)chatType;
@end
