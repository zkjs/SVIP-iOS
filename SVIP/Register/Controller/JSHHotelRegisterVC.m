//
//  JSHHotelRegisterVC.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/28.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHHotelRegisterVC.h"
#import "JSHRegisterAnimationView.h"
#import "JSHTextField.h"
#import "JSHRoundRectButton.h"
#import "UIImage+ZKJS.h"
#import "HexColors.h"
#import "ZKJSTool.h"
#import "ZKJSHTTPSessionManager.h"
#import "JSHAccountManager.h"
#import "ZKJSHTTPSMSSessionManager.h"
#import "SVIP-swift.h"


#define kCountTime 30


@interface JSHHotelRegisterVC () <UIAlertViewDelegate, UITextFieldDelegate>

@end

@implementation JSHHotelRegisterVC
{
  __weak IBOutlet JSHTextField *_phoneField;
  __weak IBOutlet JSHTextField *_codeField;
  __weak IBOutlet JSHRoundRectButton *_OKButton;
  __weak IBOutlet JSHRoundRectButton *_CodeButton;
  
  int _count;
  NSTimer *_countTimer;
  NSDictionary *_wechatInfoDic;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setupSubviews];
}

// Hanton 修改
- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)setupSubviews {  
  _phoneField.background = [UIImage imageResizedWithName:@"line_dot"];
  _codeField.background = [UIImage imageResizedWithName:@"line_dot"];
  [_phoneField addLeftImageView:@"use_img"];
  [_codeField addLeftImageView:@"pasw_img"];
  
  NSAttributedString *attString1 = [[NSAttributedString alloc] initWithString:@"130-0000-0000" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14] , NSForegroundColorAttributeName : [UIColor colorWithHexString:@"8d8d8d"]}];
  _phoneField.attributedPlaceholder = attString1;
  NSAttributedString *attString2 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"VERIFIED_CODE", nil) attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14] , NSForegroundColorAttributeName : [UIColor colorWithHexString:NSLocalizedString(@"8d8d8d", nil)]}];
  _codeField.attributedPlaceholder = attString2;
  
  [_OKButton setTitle:NSLocalizedString(@"REGISTER", nil) forState:UIControlStateNormal];
  _OKButton.enabled = NO;
  _OKButton.alpha = 0.5;
  
  [_CodeButton setTitle:NSLocalizedString(@"SEND_VERIFIED_CODE", nil) forState:UIControlStateNormal];
  _CodeButton.enabled = NO;
  _CodeButton.alpha = 0.5;
  _CodeButton.layer.borderColor = [UIColor whiteColor].CGColor;
  _CodeButton.layer.borderWidth = 0.8;
  _CodeButton.layer.masksToBounds = YES;
  _CodeButton.layer.cornerRadius = 2;
}

#pragma mark - timer action

- (void)refreshCount:(id)sender {
  [_CodeButton setTitle:[NSString stringWithFormat:@"(%dS)",_count] forState:UIControlStateDisabled];
  if (_count-- == 0) {
    [_countTimer invalidate];
    _CodeButton.enabled = YES;
    _CodeButton.alpha = 1.0;
  }
}

#pragma mark - button action

- (IBAction)OKButtonClicked:(UIButton *)sender {
  if (_phoneField.text.length == 11) {
    if ([ZKJSTool validateMobile:_phoneField.text]) {
      if ([_phoneField.text isEqual:@"18503027465"] || [_phoneField.text isEqual:@"18925232944"]) {
        //跳过验证，直接注册
        [self.view endEditing:true];
        [[LoginManager sharedInstance] signup:_phoneField.text openID:nil success:^{
          JSHBaseInfo *baseInfo = [[JSHBaseInfo alloc] init];
          baseInfo.sex = [_wechatInfoDic[@"gender"] boolValue] ? NSLocalizedString(@"MAN", nil) : NSLocalizedString(@"WOMAN", nil);
          baseInfo.openid = _wechatInfoDic[@"openid"];
          baseInfo.avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_wechatInfoDic[@"profile_image_url"]]]];
          baseInfo.username = _wechatInfoDic[@"screen_name"];
          [JSHStorage saveBaseInfo:baseInfo];
        }];
        return;
      }
      if (_codeField.text.length == 6) {
        [[ZKJSHTTPSMSSessionManager sharedInstance] verifySmsCode:_codeField.text mobilePhoneNumber:_phoneField.text callback:^(BOOL succeeded, NSError *error) {
          if (succeeded) {
            //注册
            [self.view endEditing:true];
            [[LoginManager sharedInstance] signup:_phoneField.text openID:nil success:^{
              JSHBaseInfo *baseInfo = [[JSHBaseInfo alloc] init];
              baseInfo.sex = [_wechatInfoDic[@"gender"] boolValue] ? NSLocalizedString(@"MAN", nil) : NSLocalizedString(@"WOMAN", nil);
              baseInfo.openid = _wechatInfoDic[@"openid"];
              baseInfo.avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_wechatInfoDic[@"profile_image_url"]]]];
              baseInfo.username = _wechatInfoDic[@"screen_name"];
              [JSHStorage saveBaseInfo:baseInfo];
            }];
          } else {
            _codeField.text = @"";
            [ZKJSTool showMsg:NSLocalizedString(@"WRONG_VERIFIED_CODE", nil)];
          }
        }];
        
      }
    }
  }
}

- (IBAction)CodeButtonClicked:(id)sender {
    if ([ZKJSTool validateMobile:_phoneField.text]) {
      // request 验证码
      [[ZKJSHTTPSMSSessionManager sharedInstance] requestSmsCodeWithPhoneNumber:_phoneField.text callback:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
          [ZKJSTool showMsg:NSLocalizedString(@"VERIFIED_CODE_IS_SENT", nil)];
          [_codeField becomeFirstResponder];
          // 按钮置灰
          _CodeButton.enabled = NO;
          _CodeButton.alpha = 0.5;
          _count = kCountTime;
          _countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(refreshCount:) userInfo:nil repeats:YES];
        }
      }];
    } else {
      [ZKJSTool showMsg:NSLocalizedString(@"WRONG_MOBILE_PHONE", nil)];
      return;
    }
}

- (IBAction)agreement:(id)sender {
  
}

- (IBAction)help:(id)sender {
  
}

- (IBAction)loginWithUMSocial:(id)sender {
  //    [UMSocialControllerService defaultControllerService].socialUIDelegate = self;
  switch (((UIView *)sender).tag) {
    case 1:
    {
//      UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
//      snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
//        NSLog(@"response is %@",response);
//        //need to fetch info from wechat
//        if (response.responseCode == UMSResponseCodeSuccess) {//授权成功
//          //                UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToWechatSession];//暂时没用，后期扩展有用
//          [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToWechatSession completion:^(UMSocialResponseEntity *response) {//获取微信信息
//            NSLog(@"SnsInformation is %@",response.data);
//            _wechatInfoDic = response.data;
//          }];
//          
//          _buttonTitle = @"验证手机号";
//          [_OKButton setTitle:_buttonTitle forState:UIControlStateNormal];
//          
//        }
//      });
    }
      break;
    case 2:
    case 3:
    default:
      break;
  }
}

#pragma mark - 空白点击

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];
  [self.view endEditing:YES];
}

#pragma mark - TextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  if (textField == _phoneField) {
    // 只有当手机号码填全时，才能验证码按钮可按
    if (range.location + string.length >= 11) {
      _CodeButton.enabled = YES;
      _CodeButton.alpha = 1.0;
    } else {
      _CodeButton.enabled = NO;
      _CodeButton.alpha = 0.5;
    }
    
    if (range.location + string.length <= 11) {
      return YES;
    }
  } else {
    // 只有但验证码填全时，才让登录按钮可按
    if (range.location + string.length >= 6) {
      _OKButton.enabled = YES;
      _OKButton.alpha = 1.0;
    } else {
      _OKButton.enabled = NO;
      _OKButton.alpha = 0.5;
    }
    
    if (range.location + string.length <= 6) {
      return YES;
    }
  }
  return NO;
}

@end
