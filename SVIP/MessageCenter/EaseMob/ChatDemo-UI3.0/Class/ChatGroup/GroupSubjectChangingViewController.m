/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "GroupSubjectChangingViewController.h"

#import "EaseMob.h"
//#import "SuperService-Swift.h"

@interface GroupSubjectChangingViewController () <UITextFieldDelegate>
{
  EMGroup         *_group;
  BOOL            _isOwner;
  UITextField     *_subjectField;
}

@end

@implementation GroupSubjectChangingViewController

- (instancetype)initWithGroup:(EMGroup *)group
{
  self = [self init];
  if (self) {
    _group = group;
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
    _isOwner = [_group.owner isEqualToString:loginUsername];
    self.view.backgroundColor = [UIColor whiteColor];
  }
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = NSLocalizedString(@"title.groupSubjectChanging", @"Change group name");
  
  if (_isOwner)
    {
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save", @"Save") style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
    saveItem.tintColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItem:saveItem];
    }
  
  CGRect frame = CGRectMake(20, 20, self.view.frame.size.width - 40, 40);
  _subjectField = [[UITextField alloc] initWithFrame:frame];
  _subjectField.layer.cornerRadius = 5.0;
  _subjectField.layer.borderWidth = 1.0;
  _subjectField.layer.borderColor = [UIColor blackColor].CGColor;
  _subjectField.placeholder = NSLocalizedString(@"group.setting.subject", @"Please input group name");
  _subjectField.text = _group.groupSubject;
  if (!_isOwner)
    {
    _subjectField.enabled = NO;
    }
  frame.origin = CGPointMake(frame.size.width - 5.0, 0.0);
  frame.size = CGSizeMake(5.0, 40.0);
  UIView *holder = [[UIView alloc] initWithFrame:frame];
  _subjectField.rightView = holder;
  _subjectField.rightViewMode = UITextFieldViewModeAlways;
  frame.origin = CGPointMake(0.0, 0.0);
  holder = [[UIView alloc] initWithFrame:frame];
  _subjectField.leftView = holder;
  _subjectField.leftViewMode = UITextFieldViewModeAlways;
  _subjectField.delegate = self;
  [self.view addSubview:_subjectField];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return YES;
}

#pragma mark - action
- (void)back
{
  if ([_subjectField isFirstResponder])
    {
    [_subjectField resignFirstResponder];
    }
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)save:(id)sender
{
  [self saveSubject];
}

- (void)saveSubject
{
  EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:_group.groupId conversationType:eConversationTypeGroupChat];
  [[EaseMob sharedInstance].chatManager asyncChangeGroupSubject:_subjectField.text forGroup:_group.groupId completion:^(EMGroup *group, EMError *error) {
    if (!error) {
      if ([_group.groupId isEqualToString:conversation.chatter]) {
        NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
        [ext setObject:_group.groupSubject forKey:@"groupSubject"];
        [ext setObject:[NSNumber numberWithBool:_group.isPublic] forKey:@"isPublic"];
        conversation.ext = ext;
      }
    }
    [self back];
  } onQueue:NULL];
}

@end
