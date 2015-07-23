//
//  JSHInfoEditHeader.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/30.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHInfoEditHeader.h"
#import "Colours.h"
#import "UIButton+WebCache.h"
#import "Networkcfg.h"

#define kTextFont           [UIFont systemFontOfSize:14]
#define kDuration           0.3f
@implementation JSHInfoEditHeader 
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
        _headerFrame.Edit = !_headerFrame.isEdit;
        [self changeFrame];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initSubviews
{
    _bgImageView = [[UIImageView alloc] init];
    _bgImageView.image = [UIImage imageNamed:@"星空default"];
    _bgImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickInView:)];
    [_bgImageView addGestureRecognizer:tap];
//    [self addSubview:_bgImageView];
  
    _avatarButton = [[JSHRoundRectButton alloc] init];
//    _avatarButton.backgroundColor = [UIColor colorFromHexString:@"0x1b2024"];
    
    [_avatarButton addTarget:self action:@selector(avatarClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [_avatarButton setBackgroundImage:[UIImage imageNamed:@"ic_toux_ell"] forState:UIControlStateNormal];
    [_avatarButton setBackgroundColor:[UIColor whiteColor]];
    [_avatarButton setImage:[UIImage imageNamed:@"img_shezhitoux"] forState:UIControlStateNormal];
//    [_avatarButton setImage:[UIImage imageNamed:@"ic_camera_pre"] forState:UIControlStateHighlighted];
    [self addSubview:_avatarButton];
    
    _phoneLabel = [[UILabel alloc] init];
    _phoneLabel.font = kTextFont;
    _phoneLabel.textAlignment = NSTextAlignmentCenter;
    _phoneLabel.textColor = [UIColor whiteColor];
    [self addSubview:_phoneLabel];
    
    _nameField = [[UITextField alloc] init];
    _nameField.delegate = self;
    _nameField.font = kTextFont;
    _nameField.returnKeyType = UIReturnKeyNext;
    _nameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"姓名" attributes:@{NSFontAttributeName : kTextFont, NSForegroundColorAttributeName : [UIColor whiteColor]}];
    _nameField.textColor = [UIColor whiteColor];
    [self addSubview:_nameField];
    
    _positionField = [[UITextField alloc] init];
    _positionField.delegate = self;
    _positionField.font = kTextFont;
    _positionField.returnKeyType = UIReturnKeyNext;
    _positionField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"称呼/职位" attributes:@{NSFontAttributeName : kTextFont, NSForegroundColorAttributeName : [UIColor whiteColor]}];
    _positionField.textColor = [UIColor whiteColor];
    [self addSubview:_positionField];
    
    _companyField = [[UITextField alloc] init];
    _companyField.delegate = self;
    _companyField.font = kTextFont;
    _companyField.returnKeyType = UIReturnKeyDone;
    _companyField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"公司/单位" attributes:@{NSFontAttributeName : kTextFont, NSForegroundColorAttributeName : [UIColor whiteColor]}];
    _companyField.textColor = [UIColor whiteColor];
    [self addSubview:_companyField];
    
    _maleButton = [[UIButton alloc] init];
    [_maleButton addTarget:self action:@selector(sexClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_maleButton setImage:[UIImage imageNamed:@"ic_boy_nor"] forState:UIControlStateNormal];
    [_maleButton setImage:[UIImage imageNamed:@"ic_boy_pre"] forState:UIControlStateSelected];
    [self addSubview:_maleButton];
    
    _femaleButton = [[UIButton alloc] init];
    [_femaleButton addTarget:self action:@selector(sexClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_femaleButton setImage:[UIImage imageNamed:@"ic_girl_nor"] forState:UIControlStateNormal];
    [_femaleButton setImage:[UIImage imageNamed:@"ic_girl_pre"] forState:UIControlStateSelected];
    [self addSubview:_femaleButton];
}

- (void)setHeaderFrame:(JSHInfoEditHeaderFrame *)headerFrame
{
    _headerFrame = headerFrame;
    JSHBaseInfo *baseInfo = _headerFrame.baseInfo;
    
    self.frame = headerFrame.viewFrame;
    
    _bgImageView.frame = _headerFrame.bgImageFrame;
    
    _avatarButton.frame = _headerFrame.avatarButtonFrame;
    if (baseInfo.avatarImage != nil) {
      [_avatarButton setImage:baseInfo.avatarImage forState:UIControlStateNormal];
    }else {
      NSString *urlStr = [kBaseURL stringByAppendingPathComponent:baseInfo.avatarStr];
      NSURL *url = [NSURL URLWithString:urlStr];
      [_avatarButton sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ic_camera_nor"] options:SDWebImageLowPriority | SDWebImageRetryFailed | SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
      }];
    }
  
//    if (baseInfo != nil & _avatarButton.imageView.image == nil) {
//        NSString *urlStr = [kBaseURL stringByAppendingPathComponent:baseInfo.avatarStr];
//        NSURL *url = [NSURL URLWithString:urlStr];
//        [_avatarButton sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ic_camera_nor"] options:SDWebImageLowPriority | SDWebImageRetryFailed | SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            
//        }];
//    }
    _avatarButton.layer.cornerRadius = _avatarButton.frame.size.height / 2;
    
    _phoneLabel.frame = _headerFrame.phoneLabelFrame;
    _phoneLabel.text = baseInfo.phone;
    
    _nameField.frame = _headerFrame.nameFieldFrame;
    _nameField.text = baseInfo.name;
    
    _positionField.frame = _headerFrame.positionFieldFrame;
    _positionField.text = baseInfo.position;
    
    _companyField.frame = _headerFrame.companyFieldFrame;
    _companyField.text = baseInfo.company;
    
    _maleButton.frame = _headerFrame.maleButtonFrame;
    
    _femaleButton.frame = _headerFrame.femaleButtonFrame;
    if ([baseInfo.sex isEqualToString:@"0"]) {
        _maleButton.selected = YES;
        _femaleButton.selected = NO;
    }else {
        _maleButton.selected = NO;
        _femaleButton.selected = YES;
    }
    
    if (_headerFrame.isEdit == YES) {
        UIImage *field = [UIImage imageNamed:@"line_dot"];
        _nameField.background = field;
        _positionField.background = field;
        _companyField.background = field;
        _nameField.enabled = YES;
        _positionField.enabled = YES;
        _companyField.enabled = YES;
        _avatarButton.enabled = YES;
        
        _maleButton.hidden = NO;
        _femaleButton.hidden = NO;
    }else {
        _nameField.background = nil;
        _positionField.background = nil;
        _companyField.background = nil;
        _nameField.enabled = NO;
        _positionField.enabled = NO;
        _companyField.enabled = NO;
        _avatarButton.enabled = NO;
        
        _maleButton.hidden = YES;
        _femaleButton.hidden = YES;
    }
}

- (void)avatarClicked:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择照片来源" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"照相" otherButtonTitles:@"照片库", nil];
    [actionSheet showInView:self.viewController.view];
}

- (void)sexClicked:(UIButton *)sender
{
    if (sender == _maleButton) {
        _maleButton.selected = YES;
        _femaleButton.selected = NO;
    }else {
        _maleButton.selected = NO;
        _femaleButton.selected = YES;
    }
    _headerFrame.baseInfo.sex = _femaleButton.isSelected ? @"1" : @"0";
    
}
- (void)clickInView:(id)sender
{
    [self endEditing:YES];
//    _headerFrame.Edit = !_headerFrame.isEdit;

//    [self changeFrame];
  
//    [UIView animateWithDuration:kDuration animations:^{
//    
//        self.headerFrame = _headerFrame;
//        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _headerFrame.viewFrame.size.height, _tableView.frame.size.width, [UIScreen mainScreen].bounds.size.height - _headerFrame.viewFrame.size.height);
//    } completion:^(BOOL finished) {
//        
//    }];
}

- (void)changeFrame
{
    [UIView animateWithDuration:kDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.headerFrame = _headerFrame;
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _headerFrame.viewFrame.size.height, _tableView.frame.size.width, [UIScreen mainScreen].bounds.size.height - _headerFrame.viewFrame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}
#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerVC.delegate = self;
            imagePickerVC.allowsEditing = YES;
            [self.viewController.navigationController presentViewController:imagePickerVC animated:YES completion:^{
                
            }];
        }
            break;
        case 1:
        {
            UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerVC.delegate = self;
            imagePickerVC.allowsEditing = YES;
            [self.viewController.navigationController presentViewController:imagePickerVC animated:YES completion:^{
                
            }];
        }
        default:
            break;
    }
}

#pragma mark - UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  if (self.frame.origin.y == 0) {
    CGRect frame = self.frame;
    frame.origin.y = -110;
    [UIView animateWithDuration:0.25 animations:^{
      self.frame = frame;
    }];
  }
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.frame.origin.y == -110) {
      CGRect frame = self.frame;
      frame.origin.y = 0;

      [UIView animateWithDuration:0.25 animations:^{
        self.frame = frame;
      }];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    if (textField.text.length == 0) {
//        return;
//    }
    if (textField == _nameField) {
        _headerFrame.baseInfo.name = textField.text;
    }else if (textField == _positionField) {
        _headerFrame.baseInfo.position = textField.text;
    } else if (textField == _companyField) {
        _headerFrame.baseInfo.company = textField.text;
    }
}

- (void)textFieldDidChange:(NSNotification *)aNotification
{
    UITextField *textField = [aNotification object];
    if (textField == _nameField) {
        _headerFrame.baseInfo.name = textField.text;
    }else if (textField == _positionField) {
        _headerFrame.baseInfo.position = textField.text;
    } else if (textField == _companyField) {
        _headerFrame.baseInfo.company = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField == _nameField) {
    [_positionField becomeFirstResponder];
  }else if (textField == _positionField) {
    [_companyField becomeFirstResponder];
  }else if (textField == _companyField) {
    [_companyField resignFirstResponder];
  }
  return YES;
}
#pragma mark - UIImagePickerViewController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    if ([info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
//        UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
//    }
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    int i = 1;
    while (imageData.length / 1024 > 80) {
        float persent = (100 - i++) / 100;
        imageData = UIImageJPEGRepresentation(image, persent);
    }
    
    image = [UIImage imageWithData:imageData];
    [_avatarButton setImage:image forState:UIControlStateNormal];
    _headerFrame.baseInfo.avatarImage = image;
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
