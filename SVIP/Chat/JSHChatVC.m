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
#import "JTSImageViewController.h"

@import AVFoundation;

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
@property (nonatomic, strong) UIView *shortcutView;
@property (nonatomic, strong) NSMutableArray *subButtonViews;
@property (nonatomic) NSInteger currentSubButtonViewIndex;
@end

@implementation JSHChatVC

#pragma mark - View Lifecycle

- (instancetype)initWithChatType:(ChatType)chatType {
  self = [super init];
  if (self) {
    self.chatType = chatType;
    self.shopName = @"";
  }
  return self;
}

- (void)viewDidLoad {
  self.allowsSendFace = NO;
  if (self.chatType == ChatService) {
    self.allowsShortcutView = YES;
  }
  
  [super viewDidLoad];
  
  [self loadDataSource];
  [self setupNotification];
  [self setupDataSource];
  [self setupNavigationBar];
  [self setupMessageTableView];
  [self setupMessageInputView];
  [self setupSessionID];
  [self customizeChatType];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self requestOfflineMessages];
  [self updateShopMessageBadge];
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

#pragma mark - XHMessageTableViewController Delegate

- (BOOL)shouldLoadMoreMessagesScrollToTop {
  return YES;
}

- (void)loadMoreMessagesScrollTotop {
  NSLog(@"Load More Messages");
  if (self.messages.count == 0) {
    return;
  } else {
    if (!self.loadingMoreMessage) {
      self.loadingMoreMessage = YES;
      XHMessage *message = self.messages[0];
      WEAKSELF
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *messages = [NSMutableArray array];
        messages = [Persistence.sharedInstance fetchMessagesWithShopID:self.shopID userID:self.senderID beforeTimeStamp:message.timestamp];
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf insertOldMessages:messages completion:^{
            weakSelf.loadingMoreMessage = NO;
          }];
        });
      });
    }
  }
}

- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
  [self sendTextMessage:text];
  XHMessage *message = [[XHMessage alloc] initWithText:text sender:sender timestamp:date];
  message.bubbleMessageType = XHBubbleMessageTypeSending;
  message.messageMediaType = XHBubbleMessageMediaTypeText;
  message.avatar = [JSHStorage baseInfo].avatarImage;
  
  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
  [self addMessage:message];
  [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
}

- (void)didSendPhoto:(UIImage *)photo fromSender:(NSString *)sender onDate:(NSDate *)date {
  [self sendImageMessage:photo];
  XHMessage *message = [[XHMessage alloc] initWithPhoto:photo thumbnailUrl:nil originPhotoUrl:nil sender:sender timestamp:date];
  message.bubbleMessageType = XHBubbleMessageTypeSending;
  message.messageMediaType = XHBubbleMessageMediaTypePhoto;
  message.avatar = [JSHStorage baseInfo].avatarImage;
  
  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
  [self addMessage:message];
  [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypePhoto];
}

- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date {
  [self sendVoiceMessage:voicePath];
  XHMessage *message = [[XHMessage alloc] initWithVoicePath:voicePath voiceUrl:voicePath voiceDuration:voiceDuration sender:sender timestamp:date];
  message.bubbleMessageType = XHBubbleMessageTypeSending;
  message.messageMediaType = XHBubbleMessageMediaTypeVoice;
  message.avatar = [JSHStorage baseInfo].avatarImage;
  
  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
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
      
      JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
      imageInfo.image = message.photo;
      imageInfo.referenceRect = messageTableViewCell.frame;
      imageInfo.referenceView = messageTableViewCell.superview;
      JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                             initWithImageInfo:imageInfo
                                             mode:JTSImageViewControllerMode_Image
                                             backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
      [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOffscreen];
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

- (void)setupNavigationBar {
  UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissSelf)];
  self.navigationItem.rightBarButtonItem = rightItem;
  self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
}

- (void)setupMessageTableView {
  self.messageTableView.backgroundColor = [UIColor colorFromHexString:@"#CBCCCA"];
  self.messageSender = @"我";
  self.messageReceiver = self.receiverName;
  self.senderID = [JSHAccountManager sharedJSHAccountManager].userid;
  self.senderName = [JSHStorage baseInfo].name;
}

- (void)setupMessageInputView {
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
}

- (void)customizeChatType {
  switch (self.chatType) {
    case ChatNewSession: {
      self.title = @"联系客服";
      
      NSString *orderInfo = [NSString stringWithFormat:@"系统消息\n订单号: %@\n姓名: %@\n电话: %@\n到达时间: %@\n离店时间: %@\n房型: %@\n房间价格: %@\n备注: %@", self.order.reservation_no, self.order.guest, self.order.guesttel, self.order.arrival_date, self.order.departure_date, self.order.room_type, self.order.room_rate, self.order.remark];
      [self requestWaiterWithRuleType:@"Booking" andDescription:orderInfo];  // 预订部
      // Delay
      __weak __typeof(self) weakSelf = self;
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf showSystemFeedbackWithText:@"请问您还有其它需求吗 :)"];
      });
      break;
    }
    case ChatOldSession: {
      self.title = [NSString stringWithFormat:@"%@欢迎您!", self.shopName];
      break;
    }
    case ChatCallingWaiter: {
      self.title = [NSString stringWithFormat:@"%@欢迎您!", self.shopName];
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
      self.title = [NSString stringWithFormat:@"%@欢迎您!", self.shopName];
      self.messageInputView.transform = CGAffineTransformTranslate(self.messageInputView.transform, 0.0, CGRectGetHeight(self.messageInputView.frame));
      self.messageInputView.hidden = YES;
      self.subButtonViews = [NSMutableArray array];
      [self setupShortcutView];
      break;
    }
    default:
      break;
  }
}

- (void)setupSessionID {
  self.sessionID = [[StorageManager sharedInstance] chatSession:self.shopID];
  if (!self.sessionID) {
    self.sessionID = [self newSessionID];
  }
}

- (void)updateShopMessageBadge {
  NSDictionary *shopMessageBadge = [StorageManager sharedInstance].shopMessageBadge;
  if (shopMessageBadge) {
    NSMutableDictionary *newShopMessageBadge = [NSMutableDictionary dictionaryWithDictionary:shopMessageBadge];
    if (newShopMessageBadge[self.shopID]) {
      newShopMessageBadge[self.shopID] = @0;
      [[StorageManager sharedInstance] updateShopMessageBadge:newShopMessageBadge];
    }
  }
}

- (void)showSystemFeedbackWithText:(NSString *)text {
  XHMessage *message;
  NSDate *timestamp = [NSDate date];
  message = [[XHMessage alloc] initWithText:text sender:@"系统" timestamp:timestamp];
  message.bubbleMessageType = XHBubbleMessageTypeReceiving;
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
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
                         @"department": @"预订部/前台",
                         @"ruletype": @"Booking-FrontOffice",
                         @"tags": @[@"订房", @"订房优惠"]
                         },
                       @{
                         @"name": @"订餐",
                         @"department": @"销售部",
                         @"ruletype": @"Sale",
                         @"tags": @[@"包厢", @"订餐"]
                         }
                       ]
         },
   @"1": @{
       @"status": @"店外已预订",
       @"actions": @[@{
                       @"name": @"房间",
                       @"department": @"预订部/前台",
                       @"ruletype": @"Booking-FrontOffice",
                       @"tags": @[@"取消订单", @"修改订单", @"指定房型"]
                       },
                     @{
                       @"name": @"订餐",
                       @"department": @"总台/餐饮部",
                       @"ruletype": @"CallCenter-FoodandBeverage",
                       @"tags": @[@"包厢", @"订餐", @"房间送餐"]
                      }
                     ]
       },
   @"2": @{
       @"status": @"店外已入住",
       @"actions": @[@{
                       @"name": @"房间",
                       @"department": @"客房部",
                       @"ruletype": @"Housekeeping",
                       @"tags": @[@"打扫房间", @"更换用品", @"洗衣服务"]
                       },
                     @{
                       @"name": @"订餐",
                       @"department": @"总台/餐饮部",
                       @"ruletype": @"CallCenter-FoodandBeverage",
                       @"tags": @[@"包厢", @"订餐", @"房间送餐"]
                       }
                     ]
       },
   @"3": @{
       @"status": @"大堂未预订",
       @"actions": @[@{
                       @"name": @"房间",
                       @"department": @"预订部/前台",
                       @"ruletype": @"Booking-FrontOffice",
                       @"tags": @[@"订房", @"订房优惠"]
                       },
                     @{
                       @"name": @"订餐",
                       @"department": @"销售部",
                       @"ruletype": @"Sale",
                       @"tags": @[@"包厢", @"订餐"]
                       }
                     ]
       },
   @"4": @{
       @"status": @"大堂已预订",
       @"actions": @[@{
                       @"name": @"房间",
                       @"department": @"预订部/前台",
                       @"ruletype": @"Booking-FrontOffice",
                       @"tags": @[@"取消订单", @"修改订单", @"指定房型"]
                       },
                     @{
                       @"name": @"订餐",
                       @"department": @"总台/餐饮部",
                       @"ruletype": @"CallCenter-FoodandBeverage",
                       @"tags": @[@"包厢", @"订餐", @"房间送餐"]
                       }
                     ]
       },
   @"5": @{
       @"status": @"大堂已入住",
       @"actions": @[@{
                       @"name": @"房间",
                       @"department": @"客房部",
                       @"ruletype": @"Housekeeping",
                       @"tags": @[@"打扫房间", @"更换用品", @"洗衣服务"]
                       },
                     @{
                       @"name": @"订餐",
                       @"department": @"总台/餐饮部",
                       @"ruletype": @"CallCenter-FoodandBeverage",
                       @"tags": @[@"包厢", @"订餐", @"房间送餐"]
                       }
                     ]
       },
   };
}

- (void)setupShortcutView {
  CGFloat shortcutViewHeight = 45.0;
  CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
  CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
  
  self.shortcutView = [[UIView alloc] initWithFrame:CGRectMake(0.0, screenHeight - shortcutViewHeight, screenWidth, shortcutViewHeight)];
  self.shortcutView.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:self.shortcutView];
  [self.shortcutView mas_makeConstraints:^(MASConstraintMaker *make) {
    UIView *superView = self.view;
    make.bottom.equalTo(superView.mas_bottom);
    make.leading.equalTo(superView.mas_leading);
    make.trailing.equalTo(superView.mas_trailing);
    make.height.equalTo([NSNumber numberWithFloat:shortcutViewHeight]);
  }];
  
  
  CGFloat switchWidth = 45.0;
  UIButton *switchButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, switchWidth, shortcutViewHeight)];
  [switchButton setImage:[UIImage imageNamed:@"ic_jianpan"] forState:UIControlStateNormal];
  [switchButton addTarget:self action:@selector(hideShortcutView) forControlEvents:UIControlEventTouchUpInside];
  switchButton.layer.borderWidth = 0.3;
  switchButton.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.3].CGColor;
  [self.shortcutView addSubview:switchButton];
  
  NSArray *actions = self.data[self.condition][@"actions"];
  NSInteger buttonNumber = actions.count;
  CGFloat buttonWidth = ([[UIScreen mainScreen] bounds].size.width - switchWidth) / buttonNumber;
  NSInteger actionIndex = 0;
  for (NSDictionary *action in actions) {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(switchWidth + buttonWidth * actionIndex, 0.0, buttonWidth, shortcutViewHeight)];
    button.tag = actionIndex;
    [button setTitle:action[@"name"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"ic_liaotianmore"] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [button setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:0.3 alpha:0.6] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(switchSubButtonView:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth = 0.3;
    button.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.3].CGColor;
    [self.shortcutView addSubview:button];
    
    UIImageView *subButtonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_liaotiantankuang"]];
    subButtonView.userInteractionEnabled = YES;
    subButtonView.contentMode = UIViewContentModeScaleToFill;
    subButtonView.tag = actionIndex;
    NSArray *tags = action[@"tags"];
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat viewWidth = buttonWidth;
    CGFloat viewHeight = shortcutViewHeight * tags.count + 25.0;
    CGFloat viewX = switchWidth + buttonWidth * actionIndex;
    CGFloat viewY = screenHeight - viewHeight - navigationBarHeight - statusBarHeight - shortcutViewHeight;
    CGRect frame = subButtonView.frame;
    frame.origin = CGPointMake(viewX, viewY);
    frame.size = CGSizeMake(viewWidth, viewHeight);
    subButtonView.frame = frame;
    NSLog(@"subButtonView frame: %@", NSStringFromCGRect(subButtonView.frame));
    subButtonView.transform = CGAffineTransformTranslate(subButtonView.transform, 0.0, subButtonView.frame.size.height);
    [self.view addSubview:subButtonView];
    [self.view insertSubview:subButtonView aboveSubview:self.messageTableView];
    subButtonView.hidden = YES;
    [self.subButtonViews addObject:subButtonView];
    NSInteger tagIndex = 0;
    for (NSString *tag in tags) {
      NSLog(@"%@", tag);
      UIButton *subButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, shortcutViewHeight * tagIndex, buttonWidth, shortcutViewHeight)];
      NSLog(@"%@", NSStringFromCGRect(subButton.frame));
      subButton.tag = tagIndex;
      [subButton setTitle:tag forState:UIControlStateNormal];
      if (tagIndex != (tags.count - 1)) {
        [subButton setBackgroundImage:[UIImage imageNamed:@"ic_liaotianline"] forState:UIControlStateNormal];
        [subButton setBackgroundImage:[UIImage imageNamed:@"ic_liaotianline"] forState:UIControlStateHighlighted];
      }
      subButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
      [subButton setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0] forState:UIControlStateNormal];
      [subButton setTitleColor:[UIColor colorWithWhite:0.3 alpha:0.6] forState:UIControlStateHighlighted];
      [subButton addTarget:self action:@selector(didSelectedSubButton:) forControlEvents:UIControlEventTouchUpInside];
      [subButtonView addSubview:subButton];
      tagIndex++;
    }
    actionIndex++;
  }
}

- (void)didSelectedSubButton:(UIButton *)sender {
  NSString *ruleType = self.data[self.condition][@"actions"][self.currentSubButtonViewIndex][@"ruletype"];
  NSLog(@"ruleType: %@ text: %@", ruleType, sender.titleLabel.text);
  [self requestWaiterWithRuleType:ruleType andDescription:sender.titleLabel.text];
  XHMessage *message = [[XHMessage alloc] initWithText:sender.titleLabel.text sender:self.messageSender timestamp:[NSDate date]];
  message.bubbleMessageType = XHBubbleMessageTypeSending;
  message.messageMediaType = XHBubbleMessageMediaTypeText;
  message.avatar = [JSHStorage baseInfo].avatarImage;

  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];

  [self addMessage:message];
  [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];

  __weak __typeof(self) weakSelf = self;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [weakSelf showSystemFeedbackWithText:@"您的需求已收到"];
  });
  
  UIView *subButtonView = self.subButtonViews[self.currentSubButtonViewIndex];
  [UIView animateWithDuration:0.1 animations:^{
    subButtonView.transform = CGAffineTransformTranslate(subButtonView.transform, 0.0, subButtonView.frame.size.height);
  } completion:^(BOOL finished) {
    if (finished) {
      subButtonView.hidden = YES;
    }
  }];
}

- (void)showShortcutView {
  [UIView animateWithDuration:0.3 animations:^{
    self.shortcutView.hidden = NO;
    self.shortcutView.transform = CGAffineTransformTranslate(self.shortcutView.transform, 0.0, -CGRectGetHeight(self.shortcutView.frame));
    
    self.messageInputView.transform = CGAffineTransformTranslate(self.messageInputView.transform, 0.0, CGRectGetHeight(self.messageInputView.frame));
  } completion:^(BOOL finished) {
    if (finished) {
      self.messageInputView.hidden = YES;
    }
  }];
}

- (void)hideShortcutView {
  [self hideAllSubButtonView];
  
  [UIView animateWithDuration:0.3 animations:^{
    self.messageInputView.hidden = NO;
    self.messageInputView.transform = CGAffineTransformTranslate(self.messageInputView.transform, 0.0, -CGRectGetHeight(self.messageInputView.frame));
    
    self.shortcutView.transform = CGAffineTransformTranslate(self.shortcutView.transform, 0.0, CGRectGetHeight(self.shortcutView.frame));
  } completion:^(BOOL finished) {
    if (finished) {
      self.shortcutView.hidden = YES;
    }
  }];
}

- (void)switchSubButtonView:(UIButton *)sender {
  self.currentSubButtonViewIndex = sender.tag;
  UIView *subButtonView = self.subButtonViews[sender.tag];
  if (subButtonView.hidden) {
    subButtonView.hidden = NO;
    [UIView animateWithDuration:0.1 animations:^{
      subButtonView.transform = CGAffineTransformTranslate(subButtonView.transform, 0.0, -subButtonView.frame.size.height);
    }];
  } else {
    [UIView animateWithDuration:0.1 animations:^{
      subButtonView.transform = CGAffineTransformTranslate(subButtonView.transform, 0.0, subButtonView.frame.size.height);
    } completion:^(BOOL finished) {
      if (finished) {
        subButtonView.hidden = YES;
      }
    }];
  }
  
  for (UIView *view in self.subButtonViews) {
    [UIView animateWithDuration:0.1 animations:^{
      if (view.tag != sender.tag && !view.hidden) {
        view.transform = CGAffineTransformTranslate(view.transform, 0.0, view.frame.size.height);
      }
    } completion:^(BOOL finished) {
      if (finished) {
        if (view.tag != sender.tag && !view.hidden) {
          view.hidden = YES;
        }
      }
    }];
  }
}

- (void)hideAllSubButtonView {
  for (UIView *subButtonView in self.subButtonViews) {
    if (!subButtonView.hidden) {
      [UIView animateWithDuration:0.1 animations:^{
        subButtonView.transform = CGAffineTransformTranslate(subButtonView.transform, 0.0, subButtonView.frame.size.height);
      } completion:^(BOOL finished) {
        if (finished) {
          subButtonView.hidden = YES;
        }
      }];
    }
  }
}

- (void)requestWaiterWithRuleType:(NSString *)ruleType andDescription:(NSString *)desc {
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  self.sessionID = [NSString stringWithFormat:@"%@_%@_%@", self.senderID, self.shopID, ruleType];
  NSLog(@"lastBeacon: %@", [StorageManager sharedInstance].lastBeacon);
  NSString *locid = @"";
  NSDictionary *beacon = [StorageManager sharedInstance].lastBeacon;
  if (beacon) {
    locid = beacon[@"locid"];
  }
  [[StorageManager sharedInstance] saveChatSession:self.sessionID shopID:self.shopID];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatRequestWaiter_C2S],
                               @"timestamp": timestamp,
                               @"ruletype": ruleType,
                               @"clientid": self.senderID,
                               @"clientname": self.senderName,
                               @"shopid": self.shopID,
                               @"locid": locid,
                               @"desc": desc,
                               @"sessionid": self.sessionID
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)loadDataSource {
  [ZKJSTool showLoading:@"正在加载聊天记录"];
  
  WEAKSELF
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    self.messages = [Persistence.sharedInstance fetchMessagesWithShopID:self.shopID userID:self.senderID beforeTimeStamp:[NSDate date]];
    dispatch_async(dispatch_get_main_queue(), ^{
      [weakSelf.messageTableView reloadData];
      [weakSelf scrollToBottomAnimated:NO];
      [ZKJSTool hideHUD];
    });
  });
}

- (void)sendTextMessage:(NSString *)text {
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatCustomerServiceTextChat],
                               @"timestamp": timestamp,
                               @"fromid": self.senderID,
                               @"fromname": self.senderName,
                               @"clientid": self.senderID,
                               @"clientname": self.senderName,
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
                               @"clientid": self.senderID,
                               @"clientname": self.senderName,
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
                               @"clientid": self.senderID,
                               @"clientname": self.senderName,
                               @"shopid": self.shopID,
                               @"sessionid": self.sessionID,
                               @"body": body
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)dismissSelf {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)newSessionID {
  return [NSString stringWithFormat:@"%@_%@_%@", self.senderID, self.shopID, @"DefaultChatRuleType"];
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
  message.messageMediaType = XHBubbleMessageMediaTypeText;
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
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
  message.messageMediaType = XHBubbleMessageMediaTypeVoice;
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
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
  message.messageMediaType = XHBubbleMessageMediaTypePhoto;
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
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

- (void)didSelectedSwitchAction {
  [super didSelectedSwitchAction];
  [self showShortcutView];
}

@end
