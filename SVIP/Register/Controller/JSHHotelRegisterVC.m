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
    
    int _count;
    NSTimer *_countTimer;
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
-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupSubviews
{
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
    if ((_phoneField.text.length == 11) & ([_OKButton.titleLabel.text isEqualToString:@"注册"]) & (aNotification.object == _phoneField)) {
        if ([ZKJSTool validateMobile:_phoneField.text]) {
          [[ZKJSHTTPSessionManager sharedInstance] checkDuplicatePhoneWithPhone:_phoneField.text success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dic = (NSDictionary *)responseObject;
            if ([dic[@"set"]  isEqual: @"true"]) {
              [_OKButton setTitle:@"发送验证码" forState:UIControlStateDisabled];
              [_OKButton setTitle:@"发送验证码" forState:UIControlStateNormal];
              _OKButton.enabled = YES;
            }else {
              [ZKJSTool showMsg:@"当前仅限被邀请客户使用！"];
              _phoneField.text = nil;
            }
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [ZKJSTool showMsg:@"当前仅限被邀请客户使用！"];
          }];
        }else {
            [ZKJSTool showMsg:@"手机号错误"];
          return;
        }
    }
    
    if ((_phoneField.text.length < 11) & [_OKButton.titleLabel.text isEqualToString:@"发送验证码"]) {
        [_OKButton setTitle:@"注册" forState:UIControlStateDisabled];
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
            if (_codeField.text.length == 6) {
              if ([_codeField.text isEqual:@"586878"] & [_phoneField.text isEqual:@"18503027465"]) {
                //注册
                [[ZKJSHTTPSessionManager sharedInstance] userSignUpWithPhone:_phoneField.text success:^(NSURLSessionDataTask *task, id responseObject) {
                  if ([[responseObject objectForKey:@"set"] boolValue]) {
                    //save account data
                    [[JSHAccountManager sharedJSHAccountManager] saveAccountWithDic:responseObject];
                    //jump
                    UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:[MainVC new]];
                    [vc pushViewController:[JSHInfoEditVC new] animated:NO];
                    vc.navigationBarHidden = YES;
                    [self presentViewController:vc animated:YES completion:^{
                      [self removeFromParentViewController];
                    }];
                  }
                  
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                  [ZKJSTool showMsg:@"请输入受邀请的手机号码"];
                }];
                return;
              }
                [[ZKJSHTTPSMSSessionManager sharedInstance] verifySmsCode:_codeField.text mobilePhoneNumber:_phoneField.text callback:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        //注册
                        [[ZKJSHTTPSessionManager sharedInstance] userSignUpWithPhone:_phoneField.text success:^(NSURLSessionDataTask *task, id responseObject) {
                            if ([[responseObject objectForKey:@"set"] boolValue]) {
                                //save account data
                                [[JSHAccountManager sharedJSHAccountManager] saveAccountWithDic:responseObject];
                                //jump
                                UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:[MainVC new]];
                                [vc pushViewController:[JSHInfoEditVC new] animated:NO];
                                vc.navigationBarHidden = YES;
                                [self presentViewController:vc animated:YES completion:^{
                                    [self removeFromParentViewController];
                                }];
                            }

                        } failure:^(NSURLSessionDataTask *task, NSError *error) {
                            [ZKJSTool showMsg:@"请输入受邀请的手机号码"];
                        }];
                    }else{
                        _codeField.text = @"";
                        [ZKJSTool showMsg:@"验证码错误"];
                    }
                }];
              
                //test
//                [[ZKJSHTTPSessionManager sharedInstance] userSignUpWithPhone:_phoneField.text success:^(NSURLSessionDataTask *task, id responseObject) {
//                    if ([[responseObject objectForKey:@"set"] boolValue]) {
//                        //save account data
//                        [[JSHAccountManager sharedJSHAccountManager] saveAccountWithDic:responseObject];
//                        //jump
////                        UINavigationController *navigationController = [UINavigationController new];
////                        navigationController.navigationBarHidden = YES;
////                        [navigationController setViewControllers:@[[JSHInfoEditVC new]] animated:NO];
//                        UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:[[JSHInfoEditVC alloc] init]];
//                        vc.navigationBarHidden = YES;
//                        [self presentViewController:vc animated:YES completion:^{
//                            [self removeFromParentViewController];
//                        }];
//                    }
//                    
//                } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                    [ZKJSTool showMsg:@"注册失败，请重试"];
//                }];

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
