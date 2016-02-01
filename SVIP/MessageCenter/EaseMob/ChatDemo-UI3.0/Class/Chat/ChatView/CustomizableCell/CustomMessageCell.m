//
//  CustomMessageCell.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 15/8/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "CustomMessageCell.h"
#import "EMBubbleView+Gif.h"
#import "EMGifImage.h"
#import "UIImageView+HeadImage.h"

#import "EaseMob.h"
#import "EaseUI.h"
#import "EMBubbleView+Card.h"
#import "SVIP-Swift.h"

@interface CustomMessageCell ()

@end

@implementation CustomMessageCell

+ (void)initialize
{
  // UIAppearance Proxy Defaults
}

#pragma mark - IModelCell

- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
  BOOL flag = NO;
  switch (model.bodyType) {
    case eMessageBodyType_Text: {
      if ([model.message.ext objectForKey:@"em_emotion"]) {
        flag = YES;
      } else if ([[model.message.ext objectForKey:@"extType"] integerValue] == eTextTxtCard) {
        flag = YES;
      }
    }
      break;
    default:
      break;
  }
  return flag;
}

- (void)setCustomModel:(id<IMessageModel>)model
{
  if ([model.message.ext objectForKey:@"em_emotion"]) {
    UIImage *image = [EMGifImage imageNamed:[model.message.ext objectForKey:@"em_emotion"]];
    if (!image) {
      image = model.image;
      if (!image) {
        image = [UIImage imageNamed:model.failImageName];
      }
    }
    _bubbleView.imageView.image = image;
    [self.avatarView imageWithUsername:model.nickname placeholderImage:nil];
  } else if ([[model.message.ext objectForKey:@"extType"] integerValue] == eTextTxtCard) {
    NSLog(@"%@", model.text);

    OrderDetailModel *order = [[OrderDetailModel alloc] initWithJson:model.text];
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kImageURL, order.imgurl]];
    [_bubbleView.locationImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"bg_dingdanzhuangtai"]];
    NSString *roomInfo = order.roomInfo;
    NSString *cardInfo = [NSString stringWithFormat:@" %@", roomInfo];
    _bubbleView.locationLabel.text = cardInfo;
  }
}

- (void)setCustomBubbleView:(id<IMessageModel>)model
{
  if ([model.message.ext objectForKey:@"em_emotion"]) {
    [_bubbleView setupGifBubbleView];
    _bubbleView.imageView.image = [UIImage imageNamed:@"imageDownloadFail"];
  } else if ([[model.message.ext objectForKey:@"extType"] integerValue] == eTextTxtCard) {
    [_bubbleView setupCardBubbleView];
  }
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
  if ([model.message.ext objectForKey:@"em_emotion"]) {
    [_bubbleView updateGifMargin:bubbleMargin];
  } else if ([[model.message.ext objectForKey:@"extType"] integerValue] == eTextTxtCard) {
    [_bubbleView updateCardMargin:bubbleMargin];
  }
}

+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
  if ([model.message.ext objectForKey:@"em_emotion"]) {
    return model.isSender ? @"EaseMessageCellSendGif" : @"EaseMessageCellRecvGif";
  } else if ([[model.message.ext objectForKey:@"extType"] integerValue] == eTextTxtCard) {
    return model.isSender ? @"EaseMessageCellSendCard" : @"EaseMessageCellRecvCard";
  } else {
    NSString *identifier = [EaseBaseMessageCell cellIdentifierWithModel:model];
    return identifier;
  }
}

+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
  if ([model.message.ext objectForKey:@"em_emotion"]) {
    return 100;
  } else if ([[model.message.ext objectForKey:@"extType"] integerValue] == eTextTxtCard) {
    return kCardHeight;
  } else {
    CGFloat height = [EaseBaseMessageCell cellHeightWithModel:model];
    return height;
  }
}

@end
