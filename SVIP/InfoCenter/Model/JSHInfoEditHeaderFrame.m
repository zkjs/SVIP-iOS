//
//  JSHInfoEditHeaderFrame.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/30.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHInfoEditHeaderFrame.h"
#define kScreenSize         [UIScreen mainScreen].bounds.size
#define kPositionW          90
@implementation JSHInfoEditHeaderFrame
-(void)setEdit:(BOOL)Edit
{
    _Edit = Edit;
    if (_Edit) {
        _viewFrame = CGRectMake(0, 0, kScreenSize.width, 375);
        
        _bgImageFrame = _viewFrame;
        
        CGSize avatarSize = CGSizeMake(86, 86);
        CGFloat avatarX = kScreenSize.width / 2 - avatarSize.width / 2;
        CGFloat avatarY = 95;
        _avatarButtonFrame = (CGRect){CGPointMake(avatarX, avatarY), avatarSize};
        
        CGSize phoneSize = CGSizeMake(120, 25);
        CGFloat phoneX = kScreenSize.width / 2 - phoneSize.width / 2;
        CGFloat phoneY = CGRectGetMaxY(_avatarButtonFrame) +  20;
        _phoneLabelFrame = (CGRect){(CGPoint){phoneX, phoneY}, phoneSize};
        
        CGSize nameSize = CGSizeMake(kPositionW * 2, 25);
        CGFloat nameX = kScreenSize.width / 2 - kPositionW;
        CGFloat nameY = CGRectGetMaxY(_phoneLabelFrame);
        _nameFieldFrame = (CGRect){CGPointMake(nameX, nameY), nameSize};
        
        CGSize positionSize = CGSizeMake(kPositionW * 2, 25);
        CGFloat positionX = nameX;
        CGFloat positionY = CGRectGetMaxY(_nameFieldFrame) + 8;
        _positionFieldFrame = (CGRect){CGPointMake(positionX, positionY), positionSize};
        
        CGSize companySize = CGSizeMake(kPositionW * 2, 25);
        CGFloat companyX = positionX;
        CGFloat companyY = CGRectGetMaxY(_positionFieldFrame) + 8;
        _companyFieldFrame = (CGRect){CGPointMake(companyX, companyY), companySize};
        
        CGSize maleButtonSize = CGSizeMake(37, 37);
        CGFloat maleButtonX = kScreenSize.width / 2 - maleButtonSize.width - 8;
        CGFloat maleButtonY = CGRectGetMaxY(_companyFieldFrame) + 20;
        _maleButtonFrame = (CGRect){CGPointMake(maleButtonX, maleButtonY), maleButtonSize};
        
        CGSize femaleButtonSize = CGSizeMake(37, 37);
        CGFloat femaleButtonX = kScreenSize.width / 2 + 8;
        CGFloat femaleButtonY = maleButtonY;
        _femaleButtonFrame = (CGRect){CGPointMake(femaleButtonX, femaleButtonY), femaleButtonSize};
    }else {
        _viewFrame = CGRectMake(0, 0, kScreenSize.width, 138);
        
        _bgImageFrame = CGRectMake(0, 138 - 375, kScreenSize.width, 375);
        
        CGSize avatarSize = CGSizeMake(53, 53);
        CGFloat avatarX = 20;
        CGFloat avatarY = 73;
        _avatarButtonFrame = (CGRect){CGPointMake(avatarX, avatarY), avatarSize};
        
        CGSize nameSize = CGSizeMake(120, 25);
        CGFloat nameX = CGRectGetMaxX(_avatarButtonFrame) + 10;
        CGFloat nameY = avatarY +  4;
        _nameFieldFrame = (CGRect){(CGPoint){nameX, nameY}, nameSize};
        
        CGSize companySize = CGSizeMake(65, 25);
        CGFloat companyX = nameX;
        CGFloat companyY = CGRectGetMaxY(_nameFieldFrame) + 1;
        _companyFieldFrame = (CGRect){CGPointMake(companyX, companyY), companySize};
        
        CGSize positionSize = CGSizeMake(65, 25);
        CGFloat positionX = CGRectGetMaxX(_companyFieldFrame) + 10;
        CGFloat positionY = companyY;
        _positionFieldFrame = (CGRect){CGPointMake(positionX, positionY), positionSize};
        
        CGSize phoneSize = CGSizeMake(90, 25);
        CGFloat phoneX = CGRectGetMaxX(_positionFieldFrame);;
        CGFloat phoneY = companyY;
        _phoneLabelFrame = (CGRect){CGPointMake(phoneX, phoneY), phoneSize};
    }
}
@end
