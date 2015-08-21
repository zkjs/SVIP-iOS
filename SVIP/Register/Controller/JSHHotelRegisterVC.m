//
//  JSHHotelRegisterVC.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/28.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//
/*
 说明：
 1. 增加一个buttonTitle，通过其text来区别直接手机号登陆注册还是手机号验证
 */
#import "JSHHotelRegisterVC.h"
#import "JSHRegisterAnimationView.h"
#import "JSHTextField.h"
#import "JSHRoundRectButton.h"
#import "UIImage+ZKJS.h"
#import "Colours.h"
#import "ZKJSTool.h"
#import "ZKJSHTTPSessionManager.h"
#import "JSHAccountManager.h"
#import "ZKJSHTTPSMSSessionManager.h"
#import "JSHInfoEditVC.h"
#import "SVIP-swift.h"
#define kCountTime 30
@interface JSHHotelRegisterVC () <UIAlertViewDelegate, UITextFieldDelegate>

@end

@implementation JSHHotelRegisterVC
{
    __weak IBOutlet JSHTextField *_phoneField;
    __weak IBOutlet JSHTextField *_codeField;
    __weak IBOutlet JSHRoundRectButton *_OKButton;
  
    NSString *_buttonTitle;
    int _count;
    NSTimer *_countTimer;
    NSDictionary *_wechatInfoDic;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
//    [JSHRegisterAnimationView showInView:self.view];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupSubviews];
}

// Hanton 修改
- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupSubviews
{
    _buttonTitle = @"注册";
  
    _phoneField.background = [UIImage imageResizedWithName:@"line_dot"];
    _codeField.background = [UIImage imageResizedWithName:@"line_dot"];
    [_phoneField addLeftImageView:@"use_img"];
    [_codeField addLeftImageView:@"pasw_img"];
    
    NSAttributedString *attString1 = [[NSAttributedString alloc] initWithString:@"130-0000-0000" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14] , NSForegroundColorAttributeName : [UIColor colorFromHexString:@"0x8d8d8d"]}];
    _phoneField.attributedPlaceholder = attString1;
    NSAttributedString *attString2 = [[NSAttributedString alloc] initWithString:@"验证码" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14] , NSForegroundColorAttributeName : [UIColor colorFromHexString:@"0x8d8d8d"]}];
    _codeField.attributedPlaceholder = attString2;
}
#pragma mark - timer action
- (void)refreshCount:(id)sender
{
    [_OKButton setTitle:[NSString stringWithFormat:@"(%dS)",_count] forState:UIControlStateDisabled];
    if (_count-- == 0) {
        [_countTimer invalidate];
        _OKButton.enabled = YES;
//        [_OKButton setTitle:@"发送验证码" forState:UIControlStateDisabled];
    }
}

#pragma mark - button action
- (IBAction)OKButtonClicked:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"注册"]) {
        return;
    }
    if ([sender.titleLabel.text isEqualToString:@"发送验证码"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认手机号码" message:[NSString stringWithFormat:@"验证码将发送至手机号%@",_phoneField.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
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
            UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
            snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
                NSLog(@"response is %@",response);
                //need to fetch info from wechat
              if (response.responseCode == UMSResponseCodeSuccess) {//授权成功
//                UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToWechatSession];//暂时没用，后期扩展有用
                [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToWechatSession completion:^(UMSocialResponseEntity *response) {//获取微信信息
                  NSLog(@"SnsInformation is %@",response.data);
                  _wechatInfoDic = response.data;
                }];
              
                _buttonTitle = @"验证手机号";
                [_OKButton setTitle:_buttonTitle forState:UIControlStateNormal];
                
              }
            });
        }
            break;
        case 2:
        case 3:
        default:
            break;
    }
}

#pragma mark - 空白点击
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}
#pragma alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
//        //request 验证码
        [[ZKJSHTTPSMSSessionManager sharedInstance] requestSmsCodeWithPhoneNumber:_phoneField.text callback:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [ZKJSTool showMsg:@"验证码已发送"];
//                _codeField
            }
        }];
        //按钮置灰
        _OKButton.enabled = NO;
        _count = kCountTime;
        _countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(refreshCount:) userInfo:nil repeats:YES];
    }
}
#pragma mark - textField Notification
- (void)textFieldDidChanged:(NSNotification *)aNotification
{
//如下注释掉的内容为当填满电话号码时，去验证该号码是否授权去注册
    if ((_phoneField.text.length == 11) & ([_OKButton.titleLabel.text isEqualToString:_buttonTitle]) & (aNotification.object == _phoneField)) {
        if ([ZKJSTool validateMobile:_phoneField.text]) {
//          [[ZKJSHTTPSessionManager sharedInstance] checkDuplicatePhoneWithPhone:_phoneField.text success:^(NSURLSessionDataTask *task, id responseObject) {
//            NSDictionary *dic = (NSDictionary *)responseObject;
//            if ([dic[@"set"]  isEqual: @"true"]) {
              [_OKButton setTitle:@"发送验证码" forState:UIControlStateDisabled];
              [_OKButton setTitle:@"发送验证码" forState:UIControlStateNormal];
              _OKButton.enabled = YES;
//            }else {
//              [ZKJSTool showMsg:@"当前仅限被邀请客户使用！"];
//              _phoneField.text = nil;
//            }
//          } failure:^(NSURLSessionDataTask *task, NSError *error) {
//            [ZKJSTool showMsg:@"当前仅限被邀请客户使用！"];
//          }];
        }else {
            [ZKJSTool showMsg:@"手机号错误"];
          return;
        }
    }



    if ((_phoneField.text.length < 11) & [_OKButton.titleLabel.text isEqualToString:@"发送验证码"]) {
        [_OKButton setTitle:_buttonTitle forState:UIControlStateDisabled];
        _OKButton.enabled = NO;
        return;
    }
  if (aNotification.object == _phoneField & _phoneField.text.length == 11) {
    [[ZKJSHTTPSessionManager sharedInstance] checkDuplicatePhoneWithPhone:_phoneField.text success:^(NSURLSessionDataTask *task, id responseObject) {
      
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
      
    }];
  }
  
  
    if (_phoneField.text.length == 11) {
        if ([ZKJSTool validateMobile:_phoneField.text]) {
          if ([_phoneField.text isEqual:@"18503027465"]) {
            //跳过验证，直接注册
            [[LoginManager sharedInstance] signup:_phoneField.text openID:nil success:^{
              
            }];
            return;
          }
            if (_codeField.text.length == 6) {
                [[ZKJSHTTPSMSSessionManager sharedInstance] verifySmsCode:_codeField.text mobilePhoneNumber:_phoneField.text callback:^(BOOL succeeded, NSError *error) {
                    if (!succeeded) {
                      //注册
                      [[LoginManager sharedInstance] signup:_phoneField.text openID:nil success:^{
                        JSHBaseInfo *baseInfo = [[JSHBaseInfo alloc] init];
                        baseInfo.sex = [_wechatInfoDic[@"gender"] boolValue] ? @"男" : @"女";
                        baseInfo.openid = _wechatInfoDic[@"openid"];
                        baseInfo.avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_wechatInfoDic[@"profile_image_url"]]]];
                        baseInfo.username = _wechatInfoDic[@"screen_name"];
                        [JSHStorage saveBaseInfo:baseInfo];
                      }];
                    }else{
                        _codeField.text = @"";
                        [ZKJSTool showMsg:@"验证码错误"];
                    }
                }];

            }
        }
    }
}
#pragma mark - TextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _phoneField) {
        if (range.location + string.length <= 11) {
            return YES;
        }
    }else {
        if (range.location + string.length <= 6) {
            return YES;
        }
    }
    return NO;
}


@end
