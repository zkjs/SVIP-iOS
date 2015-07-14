//
//  JSHChatVC.m
//  HotelVIP
//
//  Created by Hanton on 6/3/15.
//  Copyright (c) 2015 ZKJS. All rights reserved.
//

#import "SVIP-Swift.h"
#import "JSHChatVC.h"
#import "XHDisplayMediaViewController.h"
#import "XHAudioPlayerHelper.h"
#import "ZKJSTCPSessionManager.h"
#import "UIImage+Resize.h"
#import "ZKJSTool.h"
#import "SKTagView.h"
//#import "JSHAccountManager.h"
//#import "JSHBookOrder.h"
@import AVFoundation;
//#import "JSHStorage.h"


@interface JSHChatVC () <XHMessageTableViewControllerDelegate, XHMessageTableViewCellDelegate, XHAudioPlayerHelperDelegate, AVAudioPlayerDelegate>
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) XHMessageTableViewCell *currentSelectedCell;
@property (nonatomic, strong) SKTagView *tagView;
@property (nonatomic, strong) NSString *messageReceiver;
@property (nonatomic, strong) NSString *receiverName;
@property (nonatomic, strong) NSString *senderID;
@property (nonatomic, strong) NSString *senderName;
@property (nonatomic) ChatType chatType;
@property (nonatomic, strong) NSString *sessionID;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) NSMutableSet *actionButtons;
@end

@implementation JSHChatVC

//- (instancetype)initWithBookOrder:(JSHBookOrder *)bookOrder {
//  self = [super init];
//  if (self) {
//    self.bookOrder = bookOrder;
//  }
//  return self;
//}

- (instancetype)initWithChatType:(ChatType)chatType {
  self = [super init];
  if (self) {
    self.chatType = chatType;
  }
  return self;
}


- (void)viewDidLoad {
  self.allowsSendFace = NO;
  
  [super viewDidLoad];
  
  [self setupDataSource];
  
  UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSelf)];
  self.navigationItem.rightBarButtonItem = rightItem;

  self.title = @"聊天";
  
  self.messageTableView.backgroundColor = [UIColor colorFromHexString:@"#CBCCCA"];
    
  self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan=NO;
  
  self.messageSender = @"我";
  self.messageReceiver = self.receiverName;
  self.senderID = [JSHAccountManager sharedJSHAccountManager].userid;
  self.senderName = [JSHStorage baseInfo].name;
  self.shopID = @"120";
  
  NSMutableArray *shareMenuItems = [NSMutableArray array];
  NSArray *plugIcons = @[@"sharemore_pic", @"sharemore_video"];
  NSArray *plugTitle = @[@"照片", @"拍摄"];
  for (NSString *plugIcon in plugIcons) {
    XHShareMenuItem *shareMenuItem = [[XHShareMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:plugIcon] title:[plugTitle objectAtIndex:[plugIcons indexOfObject:plugIcon]]];
    [shareMenuItems addObject:shareMenuItem];
  }
  self.shareMenuItems = shareMenuItems;
  [self.shareMenuView reloadData];
  
  self.messageInputView.delegate = self;
  
  [self loadDataSource];
  
  [self setupNotification];
  
  self.sessionID = [[StorageManager sharedInstance] chatSession:self.shopID];
//  self.sessionID = [JSHStorage chatSessionWithShopID:self.shopID];
  if (!self.sessionID) {
    self.sessionID = [self newSessionID];
  }
  
  switch (self.chatType) {
    case ChatNewSession: {
      NSString *orderInfo = @"请问您还有其它需求吗 :)";//[NSString stringWithFormat:@"系统消息\n订单号: %@\n姓名: %@\n电话: %@\n到达时间: %@\n离店时间: %@\n房型: %@\n房间价格: %@\n备注: %@", self.order.reservation_no, self.order.guest, self.order.guesttel, self.order.arrival_date, self.order.departure_date, self.order.room_type, self.order.room_rate, self.order.remark];
      [self requestWaiterWithRuleType:@"Booking" andDescription:orderInfo];  // 预订部
      // Delay
      __weak __typeof(self) weakSelf = self;
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf showSystemFeedbackWithText:orderInfo];
      });
      break;
    }
    case ChatOldSession: {
      
      break;
    }
    case ChatCallingWaiter: {
      NSString *orderStatus = @"";
      if ([self.order.status isEqualToString:@"0"]) {
        orderStatus = @"未确认可取消订单";
      } else if ([self.order.status isEqualToString:@"1"]) {
        orderStatus = @"取消订单";
      } else if ([self.order.status isEqualToString:@"2"]) {
        orderStatus = @"已确认订单";
      } else if ([self.order.status isEqualToString:@"3"]) {
        orderStatus = @"已经完成的订单";
      } else if ([self.order.status isEqualToString:@"5"]) {
        orderStatus = @"删除订单";
      }
      
      NSString *userInfo = [NSString stringWithFormat:@"客人所在区域: %@\n订单号: %@\n订单状态: %@\n客人名称: %@\n客人手机: %@\n入住时间: %@\n离店时间: %@\n房型: %@\n房价: %@\n", self.location, self.order.reservation_no, orderStatus, self.order.guest, self.order.guesttel, self.order.arrival_date, self.order.departure_date, self.order.room_type, self.order.room_rate];
      [self requestWaiterWithRuleType:@"CallCenter" andDescription:userInfo];  // 总机
      __weak __typeof(self) weakSelf = self;
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf showSystemFeedbackWithText:@"已在为您分配服务员,请稍候 :)"];
      });
      break;
    }
    case ChatService: {
      [self setupAssistantView];
      break;
    }
    default:
      break;
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self saveDataSource];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatClientChatOnlineStatus],
                               @"timestamp": timestamp,
                               @"userid": self.senderID,
                               @"status": @0  // 在线
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatClientChatOnlineStatus],
                               @"timestamp": timestamp,
                               @"userid": self.senderID,
                               @"status": @1  // 不在线
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)dealloc {
  [[XHAudioPlayerHelper shareInstance] setDelegate:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - XHMessageTableViewControllerDelegate

- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
  [self sendTextMessage:text];
  XHMessage *message = [[XHMessage alloc] initWithText:text sender:sender timestamp:date];
  message.avatar = [JSHStorage baseInfo].avatarImage;
//  message.avatarUrl = [[NSBundle mainBundle] pathForResource:@"ic_home_nor" ofType:@"png"];
  
  [self addMessage:message];
  [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
}

- (void)didSendPhoto:(UIImage *)photo fromSender:(NSString *)sender onDate:(NSDate *)date {
  [self sendImageMessage:photo];
  XHMessage *message = [[XHMessage alloc] initWithPhoto:photo thumbnailUrl:nil originPhotoUrl:nil sender:sender timestamp:date];
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [self addMessage:message];
  [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypePhoto];
}

- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date {
  [self sendVoiceMessage:voicePath];
  XHMessage *message = [[XHMessage alloc] initWithVoicePath:voicePath voiceUrl:voicePath voiceDuration:voiceDuration sender:sender timestamp:date];
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [self addMessage:message];
  [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeVoice];
}

#pragma mark - XHMessageTableViewCell delegate

- (void)multiMediaMessageDidSelectedOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(XHMessageTableViewCell *)messageTableViewCell {
  UIViewController *disPlayViewController;
  switch (message.messageMediaType) {
    case XHBubbleMessageMediaTypeVideo:
    case XHBubbleMessageMediaTypePhoto: {
      DLog(@"message : %@", message.photo);
      DLog(@"message : %@", message.videoConverPhoto);
      XHDisplayMediaViewController *messageDisplayTextView = [[XHDisplayMediaViewController alloc] init];
      messageDisplayTextView.message = message;
      disPlayViewController = messageDisplayTextView;
      break;
    }
      break;
    case XHBubbleMessageMediaTypeVoice: {
      DLog(@"message : %@", message.voicePath);
      
      message.isRead = YES;
      messageTableViewCell.messageBubbleView.voiceUnreadDotImageView.hidden = YES;
      
      [[XHAudioPlayerHelper shareInstance] setDelegate:(id<NSFileManagerDelegate>)self];
      if (self.currentSelectedCell) {
        [self.currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
      }
      if (self.currentSelectedCell == messageTableViewCell) {
        [messageTableViewCell.messageBubbleView.animationVoiceImageView stopAnimating];
        [[XHAudioPlayerHelper shareInstance] stopAudio];
        self.currentSelectedCell = nil;
      } else {
        self.currentSelectedCell = messageTableViewCell;
        [messageTableViewCell.messageBubbleView.animationVoiceImageView startAnimating];
        [[XHAudioPlayerHelper shareInstance] managerAudioWithFileName:message.voicePath toPlay:YES];
      }
      break;
    }
    case XHBubbleMessageMediaTypeEmotion:
      DLog(@"facePath : %@", message.emotionPath);
      break;
    case XHBubbleMessageMediaTypeLocalPosition: {
      DLog(@"facePath : %@", message.localPositionPhoto);
      break;
    }
    default:
      break;
  }
  if (disPlayViewController) {
    [self.navigationController pushViewController:disPlayViewController animated:YES];
  }
}

#pragma mark - XHAudioPlayerHelper Delegate

- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {
  if (!self.currentSelectedCell) {
    return;
  }
  [self.currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
  self.currentSelectedCell = nil;
}

#pragma mark - RecorderPath Helper Method

- (NSString *)getRecorderPath {
  NSString *recorderPath = nil;
  recorderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
  NSDate *now = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
  recorderPath = [recorderPath stringByAppendingFormat:@"%@.aac", [dateFormatter stringFromDate:now]];
  return recorderPath;
}

- (NSString *)getPlayPath {
  NSString *recorderPath = nil;
  recorderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
  NSDate *now = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
  recorderPath = [recorderPath stringByAppendingFormat:@"%@", [dateFormatter stringFromDate:now]];
  return recorderPath;
}

#pragma mark - Private Methods

- (void)showSystemFeedbackWithText:(NSString *)text {
  XHMessage *message;
  NSDate *timestamp = [NSDate date];
  message = [[XHMessage alloc] initWithText:text sender:@"系统" timestamp:timestamp];
  message.bubbleMessageType = XHBubbleMessageTypeReceiving;
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [self.messages addObject:message];
  [self.messageTableView reloadData];
  [self scrollToBottomAnimated:NO];
}

- (void)setupDataSource {
//0 OutOfRegion_NoOrder
//1 OutOfRegion_HasOrder_UnCheckin
//2 OutOfRegion_HasOrder_Checkin
//3 InRegion_NoOrder
//4 InRegion_HasOrder_UnCheckin
//5 InRegion_HasOrder_Checkin
   self.data = @{
   @"0": @{
         @"status": @"店外未预订",
         @"actions": @[@{
                         @"name": @"房间",
                         @"icon": @"ic_dingfang",
                         @"department": @"预订部/前台",
                         @"ruletype": @"Booking-FrontOffice",
                         @"tags": @[@"我想要订房", @"订房有什么优惠吗？"]
                         },
                       @{
                         @"name": @"订餐",
                         @"icon": @"ic_dingcan",
                         @"department": @"销售部",
                         @"ruletype": @"Sale",
                         @"tags": @[@"我要包厢", @"我要订餐"]
                         }
                       ]
         },
   @"1": @{
       @"status": @"店外已预订",
       @"actions": @[@{
                       @"name": @"房间",
                       @"icon": @"ic_dingfang",
                       @"department": @"预订部/前台",
                       @"ruletype": @"Booking-FrontOffice",
                       @"tags": @[@"我想取消订单", @"我想修改订单", @"我要指定房型"]
                       },
                     @{
                       @"name": @"订餐",
                       @"icon": @"ic_dingcan",
                       @"department": @"总台/餐饮部",
                       @"ruletype": @"CallCenter-FoodandBeverage",
                       @"tags": @[@"我要包厢", @"我要订餐", @"我想要房间送餐"]
                       },
                     @{
                       @"name": @"其它",
                       @"icon": @"ic_qita",
                       @"department": @"前台",
                       @"ruletype": @"FrontOffice",
                       @"tags": @[@"专属前台", @"我需要开发票"]
                       }
                     ]
       },
   @"2": @{
       @"status": @"店外已入住",
       @"actions": @[@{
                       @"name": @"房间",
                       @"icon": @"ic_dingfang",
                       @"department": @"客房部",
                       @"ruletype": @"Housekeeping",
                       @"tags": @[@"我要打扫房间", @"我要更换用品", @"我需要洗衣服务	"]
                       },
                     @{
                       @"name": @"订餐",
                       @"icon": @"ic_dingcan",
                       @"department": @"总台/餐饮部",
                       @"ruletype": @"CallCenter-FoodandBeverage",
                       @"tags": @[@"我要包厢", @"我要订餐", @"我想要房间送餐"]
                       },
                     @{
                       @"name": @"其它",
                       @"icon": @"ic_qita",
                       @"department": @"前台",
                       @"ruletype": @"FrontOffice",
                       @"tags": @[@"专属前台", @"我需要开发票"]
                       }
                     ]
       },
   @"3": @{
       @"status": @"大堂未预订",
       @"actions": @[@{
                       @"name": @"房间",
                       @"icon": @"ic_dingfang",
                       @"department": @"预订部/前台",
                       @"ruletype": @"Booking-FrontOffice",
                       @"tags": @[@"我想要订房", @"订房有什么优惠吗？"]
                       },
                     @{
                       @"name": @"订餐",
                       @"icon": @"ic_dingcan",
                       @"department": @"销售部",
                       @"ruletype": @"Sale",
                       @"tags": @[@"我要包厢", @"我要订餐"]
                       }
                     ]
       },
   @"4": @{
       @"status": @"大堂已预订",
       @"actions": @[@{
                       @"name": @"房间",
                       @"icon": @"ic_dingfang",
                       @"department": @"预订部/前台",
                       @"ruletype": @"Booking-FrontOffice",
                       @"tags": @[@"我想取消订单", @"我想修改订单", @"我要指定房型"]
                       },
                     @{
                       @"name": @"订餐",
                       @"icon": @"ic_dingcan",
                       @"department": @"总台/餐饮部",
                       @"ruletype": @"CallCenter-FoodandBeverage",
                       @"tags": @[@"我要包厢", @"我要订餐", @"我想要房间送餐"]
                       },
                     @{
                       @"name": @"其它",
                       @"icon": @"ic_qita",
                       @"department": @"前台",
                       @"ruletype": @"FrontOffice",
                       @"tags": @[@"专属前台", @"我需要开发票"]
                       }
                     ]
       },
   @"5": @{
       @"status": @"大堂已入住",
       @"actions": @[@{
                       @"name": @"房间",
                       @"icon": @"ic_dingfang",
                       @"department": @"客房部",
                       @"ruletype": @"Housekeeping",
                       @"tags": @[@"我要打扫房间", @"我要更换用品", @"我需要洗衣服务	"]
                       },
                     @{
                       @"name": @"订餐",
                       @"icon": @"ic_dingcan",
                       @"department": @"总台/餐饮部",
                       @"ruletype": @"CallCenter-FoodandBeverage",
                       @"tags": @[@"我要包厢", @"我要订餐", @"我想要房间送餐"]
                       },
                     @{
                       @"name": @"其它",
                       @"icon": @"ic_qita",
                       @"department": @"前台",
                       @"ruletype": @"FrontOffice",
                       @"tags": @[@"专属前台", @"我需要开发票"]
                       }
                     ]
       },
   };
}

- (void)setupAssistantView {
  NSDictionary *actions = self.data[self.condition][@"actions"];
  CGFloat division = self.view.frame.size.width / (actions.count * 2);
  CGFloat centerX = division - 60.0 / 2.0;
  self.actionButtons = [NSMutableSet set];
  NSInteger index = 0;
  for(NSDictionary* action in actions) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(showTagView:)
    forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:action[@"icon"]] forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0, 0.0, 60.0, 60.0);
    button.tag = index;
    button.alpha = 0.6;
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
      UIView *superView = self.view;
      make.bottom.equalTo(superView.mas_bottom).offset(-46);
      make.leading.equalTo([NSNumber numberWithFloat:centerX]);
    }];
    centerX += division * 2;
    [self.actionButtons addObject:button];
    index++;
  }
}

- (void)showAllActionButtons {
  for (UIButton *button in self.actionButtons) {
    button.hidden = NO;
  }
}

- (void)hideAllActionButtons {
  for (UIButton *button in self.actionButtons) {
    button.hidden = YES;
  }
}

- (void)showTagView:(UIButton *)sender {
  [self hideAllActionButtons];
  
  self.tagView = ({
    SKTagView *view = [SKTagView new];
    view.backgroundColor = [UIColor whiteColor];
    view.padding    = UIEdgeInsetsMake(10, 25, 10, 25);
    view.insets    = 5;
    view.lineSpace = 10;
    //Handle tag's click event
    __weak __typeof(self) weakSelf = self;
    view.didClickTagAtIndex = ^(NSUInteger index) {
      [weakSelf hideTagView];
      NSString *tag = self.data[self.condition][@"actions"][sender.tag][@"tags"][index];
      NSString *ruleType = self.data[self.condition][@"actions"][sender.tag][@"ruletype"];
      [self requestWaiterWithRuleType:ruleType andDescription:tag];
      XHMessage *message = [[XHMessage alloc] initWithText:tag sender:self.senderName timestamp:[NSDate date]];
      message.avatar = [JSHStorage baseInfo].avatarImage;
      [self addMessage:message];
      [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
      __weak __typeof(self) weakSelf = self;
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf showSystemFeedbackWithText:@"您的需求已收到"];
      });
    };
    view;
  });
  [self.view addSubview:self.tagView];
  [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
    UIView *superView = self.view;
    make.bottom.equalTo(superView.mas_bottom);
    make.leading.equalTo(superView.mas_leading);
    make.trailing.equalTo(superView.mas_trailing);
  }];
  
  //Add Tags
  NSArray *tags = self.data[self.condition][@"actions"][sender.tag][@"tags"];
  [tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
   {
   SKTag *tag = [SKTag tagWithText:obj];
   tag.textColor = [UIColor blackColor];
   tag.bgColor = [UIColor whiteColor];
   tag.cornerRadius = 6;
   tag.fontSize = 15;
   tag.padding = UIEdgeInsetsMake(13.5, 12.5, 13.5, 12.5);
   tag.borderColor = [UIColor grayColor];
   tag.borderWidth = 0.5;
   [self.tagView addTag:tag];
   }];
  
  self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.cancelButton addTarget:self
                        action:@selector(hideTagView)
              forControlEvents:UIControlEventTouchUpInside];
  [self.cancelButton setImage:[UIImage imageNamed:@"ic_quxiao2"] forState:UIControlStateNormal];
  self.cancelButton.frame = CGRectMake(0.0, 0.0, 60.0, 60.0);
  [self.view addSubview:self.cancelButton];
  [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
    UIView *tagView = self.tagView;
    make.bottom.equalTo(tagView.mas_top).offset(-8);
    make.trailing.equalTo(tagView.mas_trailing).offset(-8);
  }];
}

- (void)hideTagView {
  self.cancelButton.hidden = YES;
  self.tagView.hidden = YES;
}

- (void)requestWaiterWithRuleType:(NSString *)ruleType andDescription:(NSString *)desc {
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  self.sessionID = [NSString stringWithFormat:@"%@_%@_%@", self.senderID, self.shopID, timestamp];
//  [JSHStorage saveChatSession:self.sessionID withShopID:self.shopID];
  [[StorageManager sharedInstance] saveChatSession:self.sessionID shopID:self.shopID];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatRequestWaiter_C2S],
                               @"timestamp": timestamp,
                               @"ruletype": ruleType,
                               @"clientid": self.senderID,
                               @"clientname": self.senderName,
                               @"shopid": self.shopID,
                               @"desc": desc,
                               @"sessionid": self.sessionID
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)loadDataSource {
  WEAKSELF
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@.chatlog", self.shopID];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
//    NSMutableArray *messages = [NSMutableArray arrayWithContentsOfFile:filePath];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSMutableArray *messages = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"Loading Path: %@", filePath);
    dispatch_async(dispatch_get_main_queue(), ^{
      weakSelf.messages = messages;
      [weakSelf.messageTableView reloadData];
      [weakSelf scrollToBottomAnimated:NO];
      [self requestOfflineMessages];
    });
  });
}

- (void)saveDataSource {
  if (self.messages.count != 0) {
    [self saveLastChatMessage:self.messages.lastObject];
  }
  
//  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@.chatlog", self.shopID];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSLog(@"Saving Path: %@", filePath);
  //  [self.messages writeToFile:filePath atomically:YES];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.messages];
    [data writeToFile:filePath atomically:YES];
//  });
  [ZKJSTool hideHUD];
}

- (void)saveLastChatMessage:(XHMessage*)message {
  NSMutableDictionary *chatMessage = [NSMutableDictionary dictionary];
  if (message.messageMediaType == XHBubbleMessageMediaTypeText) {
    chatMessage[@"message"] = message.text;
  } else if (message.messageMediaType == XHBubbleMessageMediaTypePhoto) {
    chatMessage[@"message"] = @"图片消息";
  } else if (message.messageMediaType == XHBubbleMessageMediaTypeVoice) {
    chatMessage[@"message"] = @"语音消息";
  }
  NSDate *now = [NSDate date];
  NSInteger duration = [NSDate daysFromDate:message.timestamp toDate:now];
  if (duration == 0) {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    chatMessage[@"date"] = [NSString stringWithFormat:@"今天%@", [dateFormat stringFromDate:message.timestamp]];
  } else if (duration == 1) {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    chatMessage[@"date"] = [NSString stringWithFormat:@"昨天%@", [dateFormat stringFromDate:message.timestamp]];
  } else {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd"];
    chatMessage[@"date"] = [dateFormat stringFromDate:message.timestamp];
  }
  
  [[StorageManager sharedInstance] updateLastChatMessage:chatMessage shopID:@"120"];
}

- (void)sendTextMessage:(NSString *)text {
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatCustomerServiceTextChat],
                               @"timestamp": timestamp,
                               @"fromid": self.senderID,
                               @"fromname": self.senderName,
//                               @"clientid": self.senderID,
//                               @"clientname": self.senderName,
                               @"shopid": self.shopID,
                               @"sessionid": self.sessionID,
                               @"textmsg": text
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)sendVoiceMessage:(NSString *)voicePath {
  NSData *audioData = [[NSData alloc] initWithContentsOfFile:voicePath];
  NSString *body = [audioData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatCustomerServiceMediaChat],
                               @"timestamp": timestamp,
                               @"fromid": self.senderID,
                               @"fromname": self.senderName,
//                               @"clientid": self.senderID,
//                               @"clientname": self.senderName,
                               @"shopid": self.shopID,
                               @"sessionid": self.sessionID,
                               @"body": body
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)sendImageMessage:(UIImage *)image {
  UIImage *compressedImage = [image resizedImage:CGSizeMake(100.0, 100.0) interpolationQuality:kCGInterpolationDefault];
  NSData *imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
  NSString *body = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatCustomerServiceImgChat],
                               @"timestamp": timestamp,
                               @"fromid": self.senderID,
                               @"fromname": self.senderName,
//                               @"clientid": self.senderID,
//                               @"clientname": self.senderName,
                               @"shopid": self.shopID,
                               @"sessionid": self.sessionID,
                               @"body": body
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)dismissSelf {
  [ZKJSTool showLoading:@"正在保存聊天记录"];
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)newSessionID {
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  return [NSString stringWithFormat:@"%@_%@_%@", timestamp, self.shopID, self.senderID];
}

- (void)requestOfflineMessages {
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatOfflineMssage],
                               @"timestamp": timestamp,
                               @"userid": self.senderID
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

#pragma mark - Notifications

- (void)setupNotification {
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserver:self selector:@selector(showTextMessage:) name:@"MessageServiceChatCustomerServiceTextChatNotification" object:nil];
  [center addObserver:self selector:@selector(showImageMessage:) name:@"MessageServiceChatCustomerServiceImgChatNotification" object:nil];
  [center addObserver:self selector:@selector(showVoiceMessage:) name:@"MessageServiceChatCustomerServiceMediaChatNotification" object:nil];
}

- (void)sendReadAcknowledge:(NSDictionary *)userInfo {
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatCustomerServiceSessionMsgReadAck],
                               @"timestamp": timestamp,
                               @"shopid": userInfo[@"shopid"],
                               @"sessionid": userInfo[@"seqid"],
                               @"seqid": userInfo[@"seqid"],
                               @"fromid": self.senderID,
                               @"toid": userInfo[@"fromid"]
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)showTextMessage:(NSNotification *)notification {
  NSString *sender = notification.userInfo[@"fromname"];
  NSString *text = notification.userInfo[@"textmsg"];
  
  XHMessage *message;
  message = [[XHMessage alloc] initWithText:text sender:sender timestamp:[NSDate date]];
  message.bubbleMessageType = XHBubbleMessageTypeReceiving;
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [self.messages addObject:message];
  [self.messageTableView reloadData];
  [self scrollToBottomAnimated:NO];
  
  if ([notification.userInfo[@"isreadack"] isEqual: @1]) {
    // 发送回执
    [self sendReadAcknowledge:notification.userInfo];
  }
}

- (void)showVoiceMessage:(NSNotification *)notification {
  NSString *sender = notification.userInfo[@"fromname"];
  NSString *body = notification.userInfo[@"body"];
  NSData *voiceData = [[NSData alloc] initWithBase64EncodedString:body options:NSDataBase64DecodingIgnoreUnknownCharacters];
  NSString *voicePath = [self getPlayPath];
  
  [voiceData writeToFile:voicePath atomically:NO];
  NSString *voiceDuration = [self getVoiceDuration:voicePath];
  
  XHMessage *message;
  NSDate *timestamp = [NSDate date];
  message = [[XHMessage alloc] initWithVoicePath:voicePath voiceUrl:nil voiceDuration:voiceDuration sender:sender timestamp:timestamp isRead:NO];
  message.bubbleMessageType = XHBubbleMessageTypeReceiving;
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [self.messages addObject:message];
  [self.messageTableView reloadData];
  [self scrollToBottomAnimated:NO];
  
  if ([notification.userInfo[@"isreadack"] isEqual: @1]) {
    // 发送回执
    [self sendReadAcknowledge:notification.userInfo];
  }
}

- (void)showImageMessage:(NSNotification *)notification {
  NSString *sender = notification.userInfo[@"fromname"];
  NSString *body = notification.userInfo[@"body"];
  NSData *imageData = [[NSData alloc] initWithBase64EncodedString:body options:NSDataBase64DecodingIgnoreUnknownCharacters];
  UIImage *image = [UIImage imageWithData:imageData];
  
  XHMessage *message;
  NSDate *timestamp = [NSDate date];
  message = [[XHMessage alloc] initWithPhoto:image thumbnailUrl:nil originPhotoUrl:nil sender:sender timestamp:timestamp];
  message.bubbleMessageType = XHBubbleMessageTypeReceiving;
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [self.messages addObject:message];
  [self.messageTableView reloadData];
  [self scrollToBottomAnimated:NO];
  
  if ([notification.userInfo[@"isreadack"] isEqual: @1]) {
    // 发送回执
    [self sendReadAcknowledge:notification.userInfo];
  }
}

- (NSString *)getVoiceDuration:(NSString *)recordPath {
  NSError *error = nil;
  NSString *recordDuration = nil;
  AVAudioPlayer *play = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recordPath] error:&error];
  if (error) {
    DLog(@"recordPath：%@ error：%@", recordPath, error);
    recordDuration = @"";
  } else {
    DLog(@"时长:%f", play.duration);
    recordDuration = [NSString stringWithFormat:@"%.1f", play.duration];
  }
  return recordDuration;
}

#pragma mark - XHMessageInputViewDelegate

- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView {
  [super inputTextViewWillBeginEditing:messageInputTextView];
  [self hideAllActionButtons];
}

- (void)didSelectedMultipleMediaAction {
  [super didSelectedMultipleMediaAction];
  [self hideAllActionButtons];
}

- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion {
  [super prepareRecordingVoiceActionWithCompletion:completion];
  [self hideAllActionButtons];
}

@end
