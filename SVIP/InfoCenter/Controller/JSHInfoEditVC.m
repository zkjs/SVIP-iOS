//
//  JSHInfoEditVC.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/29.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHInfoEditVC.h"
#import "UIImage+ZKJS.h"
#import "Colours.h"
#import "JSHInfoEditCell.h"

#import "JSHInfoEditHeader.h"
#import "JSHBaseInfo.h"
#import "JSHInfoEditHeaderFrame.h"
#import "JSHSectionModel.h"
#import "ZKJSHTTPSessionManager.h"
#import "JSHInfoEditLabelLevel1Model.h"
#import "JSHAccountManager.h"
#import "JSHStorage.h"
#import "ZKJSTool.h"
#import "NSString+JSH.h"
#import "SVIP-swift.h"
#define kDuration       1.0f
#define kCellH         60

@interface JSHInfoEditVC () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, InfoEditSelectionDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation JSHInfoEditVC
{
    JSHInfoEditHeader *_header;
    UITableView *_tableView;
    NSArray *_dataArray;
}
static NSString *identifier = @"infoCenterCell";
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubviews];
    [self loadData];
}

- (void)loadData
{
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"JSHInfoEditSelection" ofType:@"plist"];
//    NSMutableArray *mutArray = [NSMutableArray array];
//    NSArray *array = [NSArray arrayWithContentsOfFile:path];
//    for (NSDictionary *dic in array) {
//        JSHSectionModel *sectionModel = [[JSHSectionModel alloc] initWithDic:dic];
//        [mutArray addObject:sectionModel];
//    }
//    _dataArray = [NSArray arrayWithArray:mutArray];
    
//    NSMutableDictionary *myDic = [NSMutableDictionary dictionary];
    
    NSString *userId = [JSHAccountManager sharedJSHAccountManager].userid;
    NSString *token = [JSHAccountManager sharedJSHAccountManager].token;
    JSHBaseInfo *localBaseInfo = [JSHStorage baseInfo];
    if ([localBaseInfo.phone isEqualToString:@"请编辑个人信息"]) {
        //获取个人信息
        [[ZKJSHTTPSessionManager sharedInstance] getUserInfo:userId token:token success:^(NSURLSessionDataTask *task, id responseObject) {
            JSHBaseInfo *baseInfo = [[JSHBaseInfo alloc] initWithDic:responseObject];
            //本地存储
            [JSHStorage saveBaseInfo:baseInfo];
            if (![responseObject[@"tagsid"] isKindOfClass:[NSNull class]]) {
                NSArray *abc = [NSString arrayWithSortedString:responseObject[@"tagsid"] dividedByString:@","];
                [JSHStorage saveLikeArray:abc];
            }
            //刷新frame
            _header.headerFrame.baseInfo = baseInfo;
            _header.headerFrame.Edit = YES;
            _header.headerFrame = _header.headerFrame;//类似于tableview reloadData，刷新界面
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }else {
        //取本地数据
        _header.headerFrame.baseInfo = [JSHStorage baseInfo];
        _header.headerFrame.Edit = YES;
        _header.headerFrame = _header.headerFrame;
    }
    
    
    // 取得标签
  /*
    NSMutableArray *myArray = [NSMutableArray array];
    [[ZKJSHTTPSessionManager sharedInstance] getTagsShowWithCallback:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@", responseObject);
        NSArray *array = (NSArray *)responseObject;
        for (NSDictionary *dic in array) {
            NSArray *array1 =[dic objectForKey:@"children"];
            for (NSDictionary *dic1 in array1) {
                NSMutableDictionary *myDic = [NSMutableDictionary dictionary];
                [myDic setObject:[NSString stringWithFormat:@"%@*%@",[dic objectForKey:@"tag"],[dic1 objectForKey:@"tag"]] forKey:@"tag"];
                
                NSMutableArray *mutArray = [NSMutableArray array];
                for (NSDictionary *dic2 in [dic1 objectForKey:@"children"]) {
                    JSHInfoEditLabelLevel1Model *model = [JSHInfoEditLabelLevel1Model objectWithKeyValues:dic2];
//                    JSHCellModel *model = [[JSHCellModel alloc] initWithDic:dic2];

                    [mutArray addObject:model];
                }
                 [myDic setObject:mutArray forKey:@"children"];
                [myArray addObject:myDic];
            }
        }
        _dataArray = [NSArray arrayWithArray:myArray];
        
        [_tableView reloadData];        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
*/
}

- (void)initSubviews
{
    //隐藏导航栏，因为增加了场景变换效果，加了button
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 20, 20, 40, 21)];
//    label.text = @"设置";
//    [self.view addSubview:label];
//    self.title = @"设置";
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(setting:)];
//    rightItem.tintColor = [UIColor whiteColor];
//    self.navigationItem.rightBarButtonItem = rightItem;

//    JSHBaseInfo *baseInfo = [[JSHBaseInfo alloc] init];
////    baseInfo.avatar = [UIImage imageNamed:@"ic_camera_nor"];
//    baseInfo.phone = @"18974968512";
//    baseInfo.username = @"脚本小子";
//    baseInfo.position = @"IT工程师";
//    baseInfo.company = @"360公司";

    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"星空_设置"]];
    bg.frame = self.view.bounds;
    [self.view addSubview:bg];
    JSHInfoEditHeaderFrame *headerFrame = [[JSHInfoEditHeaderFrame alloc] init];
//    headerFrame.baseInfo = baseInfo;
    headerFrame.Edit = YES;
    _header = [[JSHInfoEditHeader alloc] initWithFrame:CGRectZero];
    _header.headerFrame = headerFrame;
    [self.view addSubview:_header];
    
    //为了场景
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 20, 20, 40, 44)];
    label.text = @"设置";
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 30, 44)];
    [button2 setImage:[UIImage imageNamed:@"ic-fanhui-white"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(popout:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _header.bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - _header.bounds.size.height) style:UITableViewStylePlain];
//    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.bounces = NO;
//    _tableView.tableHeaderView = _editHeader;
//    [self.view addSubview:_tableView];
    _header.tableView = _tableView;
    _header.viewController = self;
    
//    _tableView.backgroundView = renderView;
    
//    _tableView.pagingEnabled = YES;
//    _tableView.contentInset = UIEdgeInsetsMake(490, 0, 0, 0);
  
  
  // Hanton
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  _tableView.backgroundColor = [UIColor blackColor];
    //hanton,替换navigationBar中的右侧按钮
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  [button addTarget:self
             action:@selector(setting:)
   forControlEvents:UIControlEventTouchUpInside];
  [button setTitle:@"完成" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
  [button sizeToFit];
  button.frame = CGRectMake(self.view.frame.size.width - button.frame.size.width - 20, 20, button.frame.size.width, 44);
  self.doneButton = button;
  [self.view addSubview:self.doneButton];
  self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.settingsButton.frame = CGRectMake(headerFrame.avatarButtonFrame.origin.x, headerFrame.avatarButtonFrame.origin.y, headerFrame.avatarButtonFrame.size.width, headerFrame.avatarButtonFrame.size.height);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)popViewController {
  
}

- (void)popout:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setting:(id)sender
{
    [ZKJSTool showLoading];
    NSString *userId = [JSHAccountManager sharedJSHAccountManager].userid;
    NSString *token = [JSHAccountManager sharedJSHAccountManager].token;
    //修改个人信息
    UIImage *image = _header.avatarButton.imageView.image;
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    JSHBaseInfo *baseInfo = _header.headerFrame.baseInfo;
  [[ZKJSHTTPSessionManager sharedInstance] updateUserInfoWithUserID:userId token:token username:baseInfo.username realname:nil imageData:imageData imageName:@"abc" sex:baseInfo.sex company:baseInfo.company occupation:baseInfo.position email:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject[@"set"] boolValue]) {
            
            [ZKJSTool hideHUD];
            //存储本地
            [JSHStorage saveBaseInfo:baseInfo];
            //jump
            if (self.navigationController.viewControllers.count > 1) {
                [self.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] removeObserver:_header];
            }else {
//                UINavigationController *navigationController = [UINavigationController new];
//                navigationController.navigationBarHidden = YES;
//                [navigationController setViewControllers:@[[JSHAccountVC new]] animated:NO];
//                [[UIApplication sharedApplication].windows[0] setRootViewController:navigationController];
              [[UIApplication sharedApplication].windows[0] setRootViewController:[[MainVC alloc] init]];
            }

        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [ZKJSTool showMsg:@"网络连接失败，请重试"];
    }];
    
    //上传标签
/*
    NSLog(@"%@",_dataArray);
    NSMutableArray *mutArray = [NSMutableArray array];
    NSMutableString *mutString = [[NSMutableString alloc] init];
    for (NSDictionary *dic in _dataArray) {
        for (JSHInfoEditLabelLevel1Model *model in dic[@"children"]) {
            if (model.isSelected) {
                if (mutString.length != 0) {
                    [mutString appendFormat:@",%@", model.tag];
                }else {
                    [mutString appendString:model.tag];
                }
                [mutArray addObject:model.tag];
            }
        }
    }
    
    [[ZKJSHTTPSessionManager sharedInstance] updateTagsWithUserID:userId token:token tags:mutString success:^(NSURLSessionDataTask *task, id responseObject) {
        //存储本地
        [JSHStorage saveLikeArray:mutArray];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
*/
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  
    self.navigationController.delegate = self;
}

#pragma mark - TableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellH;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
    JSHSectionModel *sectionModel = _dataArray[section];
    return sectionModel.itemsArray.count / 2 + sectionModel.itemsArray.count % 2;
     */

    return [_dataArray[section][@"children"] count] / 2 + [_dataArray[section][@"children"] count] % 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Hanton
  return 0;
//    return _dataArray ? _dataArray.count : 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kCellH;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    /*
    JSHSectionModel *sectionModel = _dataArray[section];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kCellH)];
    label.backgroundColor = [UIColor colorFromHexString:@"0x2a2b2f"];
    label.textColor = [UIColor whiteColor];
    label.text = sectionModel.sectionTitle;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    return label;
     */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kCellH)];
    label.backgroundColor = [UIColor colorFromHexString:@"0x2a2b2f"];
    label.textColor = [UIColor whiteColor];
    label.text = [_dataArray[section] objectForKey:@"tag"];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    return label;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    JSHInfoEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[JSHInfoEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    JSHSectionModel *sectionModel = _dataArray[indexPath.section];
    JSHCellModel *cellLeftModel = sectionModel.itemsArray[indexPath.row * 2];
    
    [cell.leftButton setTitle:cellLeftModel.itemTitle forState:UIControlStateNormal];
    cell.leftButton.tag = indexPath.row * 2;
    cell.leftButton.selected = cellLeftModel.isSelected;
    if (sectionModel.itemsArray.count > indexPath.row * 2 + 1) {
        JSHCellModel *cellRightModel = sectionModel.itemsArray[indexPath.row * 2 + 1];
        [cell.rightButton setTitle:cellRightModel.itemTitle forState:UIControlStateNormal];
        cell.rightButton.enabled = YES;
        cell.rightButton.tag = indexPath.row * 2 + 1;
        cell.rightButton.selected = cellRightModel.isSelected;
    }
    cell.section = (int)indexPath.section;
    cell.delegate = self;
    return cell;
     */
    JSHInfoEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[JSHInfoEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
//    JSHSectionModel *sectionModel = _dataArray[indexPath.section];
    NSDictionary *dic = _dataArray[indexPath.section];
    NSArray *arr = [dic objectForKey:@"children"];
    JSHInfoEditLabelLevel1Model *cellLeftModel = arr[indexPath.row * 2];
//    JSHInfoEditLabelLevel1Model *cellLeftModel = _dataArray[indexPath.section][@"children"][indexPath.row * 2];
    [cell.leftButton setTitle:cellLeftModel.tag forState:UIControlStateNormal];
    cell.leftButton.tag = indexPath.row * 2;
    cell.leftButton.selected = cellLeftModel.isSelected;
    if ([(_dataArray[indexPath.section][@"children"]) count] > indexPath.row * 2 + 1) {
        JSHInfoEditLabelLevel1Model *cellRightModel = _dataArray[indexPath.section][@"children"][indexPath.row * 2 + 1];
        [cell.rightButton setTitle:cellRightModel.tag forState:UIControlStateNormal];
        cell.rightButton.enabled = YES;
        cell.rightButton.tag = indexPath.row * 2 + 1;
        cell.rightButton.selected = cellRightModel.isSelected;
    }
    cell.section = (int)indexPath.section;
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - infoEditSelectionDelegate
- (void)seletButton:(int)itemIndex section:(int)itemSection
{
    /*
    JSHSectionModel *sectionModel = _dataArray[itemSection];
    for (int i = 0; i < sectionModel.itemsArray.count; i++) {
        JSHCellModel *cellModel = sectionModel.itemsArray[i];
        if (i == itemIndex) {
            cellModel.isSelected = YES;
        }else {
            cellModel.isSelected = NO;
        }
    }
    [_tableView reloadData];
     */
    
    _header.headerFrame.Edit = NO;
    [_header changeFrame];
    
    for (int i = 0; i < [_dataArray[itemSection][@"children"] count]; i++) {
        JSHInfoEditLabelLevel1Model *cellModel = _dataArray[itemSection][@"children"][i];
        if (i == itemIndex) {
            cellModel.isSelected = YES;
        }else {
            cellModel.isSelected = NO;
        }
    }
    [_tableView reloadData];
}

/* 场景转换效果，隐藏navigationbar
#pragma mark - navigationBar
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self translucentBar];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
  if (self.navigationController.delegate == self) {
    self.navigationController.delegate = nil;
  }
    [self opaqueBar];
}

#pragma mark - navigationBar setting
- (void)opaqueBar
{
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsCompact];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageResizedWithName:@"2*2PX橙色点"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.clipsToBounds = NO;
}

- (void)translucentBar
{
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"line_dot"] forBarMetrics:UIBarMetricsCompact];
    self.navigationController.navigationBar.clipsToBounds = YES;
}
*/

//hanton
#pragma mark - UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
  
//  if (operation == UINavigationControllerOperationPop) {
//    return [JSHAnimator new];
//  }
  return nil;
}

@end
