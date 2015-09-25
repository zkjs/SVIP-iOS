//
//  TSQCalendarRowCell.m
//  TimesSquare
//
//  Created by Jim Puls on 11/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQCalendarRowCell.h"
#import "TSQCalendarView.h"

#define kCellTextFontSize     15.f
@interface TSQCalendarRowCell ()

@property (nonatomic, strong) NSArray *dayButtons;
@property (nonatomic, strong) NSArray *notThisMonthButtons;
@property (nonatomic, strong) UIButton *todayButton;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *endButton;

@property (nonatomic, assign) NSInteger indexOfTodayButton;
//@property (nonatomic, assign) NSInteger indexOfSelectedButton;
@property (nonatomic, assign) NSInteger indexOfStartButton;
@property (nonatomic, assign) NSInteger indexOfEndButton;

@property (nonatomic, strong) NSDateFormatter *dayFormatter;
@property (nonatomic, strong) NSDateFormatter *accessibilityFormatter;

@property (nonatomic, strong) NSDateComponents *todayDateComponents;
@property (nonatomic) NSInteger monthOfBeginningDate;

@end


@implementation TSQCalendarRowCell

- (id)initWithCalendar:(NSCalendar *)calendar reuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [super initWithCalendar:calendar reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)configureButton:(UIButton *)button;
{
    button.titleLabel.font = [UIFont boldSystemFontOfSize:kCellTextFontSize];
    button.titleLabel.shadowOffset = self.shadowOffset;
    button.adjustsImageWhenDisabled = NO;
    [button setTitleColor:self.textColor forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)createDayButtons;
{
    NSMutableArray *dayButtons = [NSMutableArray arrayWithCapacity:self.daysInWeek];
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        UIButton *button = [[UIButton alloc] initWithFrame:self.contentView.bounds];
        [button addTarget:self action:@selector(dateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [dayButtons addObject:button];
        [self.contentView addSubview:button];
        [self configureButton:button];
        [button setTitleColor:[self.textColor colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];
    }
    self.dayButtons = dayButtons;
}

- (void)createNotThisMonthButtons;
{
    NSMutableArray *notThisMonthButtons = [NSMutableArray arrayWithCapacity:self.daysInWeek];
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        UIButton *button = [[UIButton alloc] initWithFrame:self.contentView.bounds];
        [notThisMonthButtons addObject:button];
        [self.contentView addSubview:button];
        [self configureButton:button];

        button.enabled = NO;
        UIColor *backgroundPattern = [UIColor colorWithPatternImage:[self notThisMonthBackgroundImage]];
        button.backgroundColor = backgroundPattern;
        button.titleLabel.backgroundColor = backgroundPattern;
    }
    self.notThisMonthButtons = notThisMonthButtons;
}

- (void)createTodayButton;
{
    self.todayButton = [[UIButton alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.todayButton];
    [self configureButton:self.todayButton];
    [self.todayButton addTarget:self action:@selector(todayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  
    [self.todayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.todayButton setBackgroundImage:[self todayBackgroundImage] forState:UIControlStateNormal];
    [self.todayButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.75f] forState:UIControlStateNormal];

    self.todayButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
    self.todayButton.backgroundColor = [UIColor whiteColor];
}

- (void)createSelectedButton;
{
  self.startButton = [[UIButton alloc] initWithFrame:self.contentView.bounds];
  [self.contentView addSubview:self.startButton];
  [self configureButton:self.startButton];

  
  [self.startButton setAccessibilityTraits:UIAccessibilityTraitSelected|self.startButton.accessibilityTraits];
  
  self.startButton.enabled = NO;
  [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//  self.startButton.layer.borderWidth = 1;
//  self.startButton.layer.borderColor = [UIColor redColor].CGColor;
  [self.startButton setBackgroundImage:[UIImage imageNamed:@"bt_ruzhu"] forState:UIControlStateNormal];
//  [self.startButton setImage:[UIImage imageNamed:@"bt_ruzhu"] forState:UIControlStateNormal];
//  [self.startButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.75f] forState:UIControlStateNormal];
  
  self.startButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
  self.indexOfStartButton = -1;

  
    self.endButton = [[UIButton alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.endButton];
    [self configureButton:self.endButton];
    
    [self.endButton setAccessibilityTraits:UIAccessibilityTraitSelected|self.endButton.accessibilityTraits];
    
    self.endButton.enabled = NO;
    [self.endButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.endButton setBackgroundImage:[UIImage imageNamed:@"bt_lidian"] forState:UIControlStateNormal];
//    [self.endButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.75f] forState:UIControlStateNormal];
  
    self.endButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
    self.indexOfEndButton = -1;
}

- (void)setBeginningDate:(NSDate *)date;
{
    _beginningDate = date;
    
    if (!self.dayButtons) {
        [self createDayButtons];
//        [self createNotThisMonthButtons];
        [self createTodayButton];
        [self createSelectedButton];
    }

    NSDateComponents *offset = [NSDateComponents new];
    offset.day = 1;

    self.todayButton.hidden = YES;
    self.indexOfTodayButton = -1;
//    self.selectedButton.hidden = YES;
//    self.indexOfSelectedButton = -1;
    self.startButton.hidden = YES;
    self.indexOfStartButton = -1;
    self.endButton.hidden = YES;
    self.indexOfEndButton = -1;
  
  
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        NSString *title = [self.dayFormatter stringFromDate:date];
        NSString *accessibilityLabel = [self.accessibilityFormatter stringFromDate:date];
        [self.dayButtons[index] setTitle:title forState:UIControlStateNormal];
        [self.dayButtons[index] setAccessibilityLabel:accessibilityLabel];
        [self.notThisMonthButtons[index] setTitle:title forState:UIControlStateNormal];
        [self.notThisMonthButtons[index] setTitle:title forState:UIControlStateDisabled];
        [self.notThisMonthButtons[index] setAccessibilityLabel:accessibilityLabel];
        
        NSDateComponents *thisDateComponents = [self.calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
        
        [self.dayButtons[index] setHidden:YES];
        [self.notThisMonthButtons[index] setHidden:YES];

        NSInteger thisDayMonth = thisDateComponents.month;
        if (self.monthOfBeginningDate != thisDayMonth) {
            [self.notThisMonthButtons[index] setHidden:NO];
        }else {
            if ([self.todayDateComponents isEqual:thisDateComponents]) {//今天
                self.todayButton.hidden = NO;
                [self.todayButton setTitle:@"今天" forState:UIControlStateNormal];
                [self.todayButton setAccessibilityLabel:accessibilityLabel];
                self.indexOfTodayButton = index;
            }else if (thisDateComponents.month == self.todayDateComponents.month && thisDateComponents.day < self.todayDateComponents.day) {//该月早于firstDage日期
              UIButton *button = self.dayButtons[index];
              button.enabled = NO;
              button.hidden = NO;
            }else {//其他
                UIButton *button = self.dayButtons[index];
                button.enabled = ![self.calendarView.delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)] || [self.calendarView.delegate calendarView:self.calendarView shouldSelectDate:date];
                button.hidden = NO;
            }
        }

        date = [self.calendar dateByAddingComponents:offset toDate:date options:0];
    }
}

- (void)setBottomRow:(BOOL)bottomRow;
{
    UIImageView *backgroundImageView = (UIImageView *)self.backgroundView;
    if ([backgroundImageView isKindOfClass:[UIImageView class]] && _bottomRow == bottomRow) {
        return;
    }

    _bottomRow = bottomRow;
    
    self.backgroundView = [[UIImageView alloc] initWithImage:self.backgroundImage];
    
    [self setNeedsLayout];
}

- (IBAction)dateButtonPressed:(id)sender;
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = [self.dayButtons indexOfObject:sender];
    NSDate *selectedDate = [self.calendar dateByAddingComponents:offset toDate:self.beginningDate options:0];
  [self.calendarView selectDate:selectedDate];
}

- (IBAction)todayButtonPressed:(id)sender;
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = self.indexOfTodayButton;
    NSDate *selectedDate = [self.calendar dateByAddingComponents:offset toDate:self.beginningDate options:0];
    [self.calendarView selectDate:selectedDate];
}

- (void)layoutSubviews;
{
    if (!self.backgroundView) {
        [self setBottomRow:NO];
    }
    
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
}

- (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect;
{
    UIButton *dayButton = self.dayButtons[index];
    UIButton *notThisMonthButton = self.notThisMonthButtons[index];
    
    dayButton.frame = rect;
    notThisMonthButton.frame = rect;

    if (self.indexOfTodayButton == (NSInteger)index) {
        self.todayButton.frame = rect;
    }
    if (self.indexOfStartButton == (NSInteger)index) {
//        self.startButton.frame = rect;
      if (rect.size.width> rect.size.height) {
        self.startButton.frame = (CGRect){CGPointZero, CGSizeMake(rect.size.height, rect.size.height)};
        self.startButton.center = CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
      }else {
        self.startButton.frame = (CGRect){CGPointZero, CGSizeMake(rect.size.width, rect.size.width)};
        self.startButton.center = CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
      }
    }
    if (self.indexOfEndButton == (NSInteger)index) {
//      self.endButton.frame = rect;
      if (rect.size.width> rect.size.height) {
        self.endButton.frame = (CGRect){CGPointZero, CGSizeMake(rect.size.height, rect.size.height)};
        self.endButton.center = CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
      }else {
        self.endButton.frame = (CGRect){CGPointZero, CGSizeMake(rect.size.width, rect.size.width)};
        self.endButton.center = CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
      }
    }
}

//- (void)selectColumnForDate:(NSDate *)date;
//{
////    if (!date && self.indexOfSelectedButton == -1) {
////        return;
////    }
//
//    NSInteger newIndexOfSelectedButton = -1;
//    if (date) {
//        NSInteger thisDayMonth = [self.calendar components:NSMonthCalendarUnit fromDate:date].month;
//        if (self.monthOfBeginningDate == thisDayMonth) {
//            newIndexOfSelectedButton = [self.calendar components:NSDayCalendarUnit fromDate:self.beginningDate toDate:date options:0].day;
//            if (newIndexOfSelectedButton >= (NSInteger)self.daysInWeek) {
//                newIndexOfSelectedButton = -1;
//            }
//        }
//    }
//
//    if (self.indexOfStartButton == -1) {
//      self.indexOfStartButton = newIndexOfSelectedButton;
//    }else if (self.indexOfStartButton )
//    {
//      self.indexOfEndButton = newIndexOfSelectedButton;
//    }
////    self.indexOfSelectedButton = newIndexOfSelectedButton;
//  
////    if (self.indexOfStartButton >= 0) {
////        self.startButton.hidden = NO;
////        NSString *newTitle = [self.dayButtons[self.indexOfStartButton] currentTitle];
////        [self.startButton setTitle:newTitle forState:UIControlStateNormal];
////        [self.startButton setTitle:newTitle forState:UIControlStateDisabled];
////        [self.startButton setAccessibilityLabel:[self.dayButtons[self.indexOfStartButton] accessibilityLabel]];
////    } else {
////        self.startButton.hidden = YES;
////    }
////
////    if (self.indexOfEndButton >= 0) {
////      self.endButton.hidden = NO;
////      NSString *newTitle = [self.dayButtons[self.indexOfEndButton] currentTitle];
////      [self.endButton setTitle:newTitle forState:UIControlStateNormal];
////      [self.endButton setTitle:newTitle forState:UIControlStateDisabled];
////      [self.endButton setAccessibilityLabel:[self.dayButtons[self.indexOfEndButton] accessibilityLabel]];
////    } else {
////      self.endButton.hidden = YES;
////    }
//  
//    [self setNeedsLayout];
//}

- (void)unselectStartColumn
{
  self.startButton.hidden = YES;
  self.indexOfStartButton = -1;
  [self setNeedsLayout];
}
- (void)unselectEndColumn
{
  self.endButton.hidden = YES;
  self.indexOfEndButton = -1;
  [self setNeedsLayout];
}

- (void)selectStartColumnForDate:(NSDate *)date
{
    NSInteger newIndexOfSelectedButton = -1;
    if (date) {
      NSInteger thisDayMonth = [self.calendar components:NSCalendarUnitMonth fromDate:date].month;
      if (self.monthOfBeginningDate == thisDayMonth) {
        newIndexOfSelectedButton = [self.calendar components:NSCalendarUnitDay fromDate:self.beginningDate toDate:date options:0].day;
        if (newIndexOfSelectedButton >= (NSInteger)self.daysInWeek) {
          newIndexOfSelectedButton = -1;
        }
      }
    }
    self.indexOfStartButton = newIndexOfSelectedButton;
    if (self.indexOfStartButton >= 0) {
      self.startButton.hidden = NO;
      NSString *newTitle = [self.dayButtons[self.indexOfStartButton] currentTitle];
      [self.startButton setTitle:newTitle forState:UIControlStateNormal];
      [self.startButton setTitle:newTitle forState:UIControlStateDisabled];
      [self.startButton setAccessibilityLabel:[self.dayButtons[self.indexOfStartButton] accessibilityLabel]];
    } else {
      self.startButton.hidden = YES;
    }
  [self setNeedsLayout];
}

- (void)selectEndColumnForDate:(NSDate *)date
{
  NSInteger newIndexOfSelectedButton = -1;
  if (date) {
    NSInteger thisDayMonth = [self.calendar components:NSCalendarUnitMonth fromDate:date].month;
    if (self.monthOfBeginningDate == thisDayMonth) {
      newIndexOfSelectedButton = [self.calendar components:NSCalendarUnitDay fromDate:self.beginningDate toDate:date options:0].day;
      if (newIndexOfSelectedButton >= (NSInteger)self.daysInWeek) {
        newIndexOfSelectedButton = -1;
      }
    }
  }
  self.indexOfEndButton = newIndexOfSelectedButton;
  if (self.indexOfEndButton >= 0) {
    self.endButton.hidden = NO;
    NSString *newTitle = [self.dayButtons[self.indexOfEndButton] currentTitle];
    [self.endButton setTitle:newTitle forState:UIControlStateNormal];
    [self.endButton setTitle:newTitle forState:UIControlStateDisabled];
    [self.endButton setAccessibilityLabel:[self.dayButtons[self.indexOfEndButton] accessibilityLabel]];
  } else {
    self.endButton.hidden = YES;
  }
  [self setNeedsLayout];
}
- (NSDateFormatter *)dayFormatter;
{
    if (!_dayFormatter) {
        _dayFormatter = [NSDateFormatter new];
        _dayFormatter.calendar = self.calendar;
        _dayFormatter.dateFormat = @"d";
    }
    return _dayFormatter;
}

- (NSDateFormatter *)accessibilityFormatter;
{
    if (!_accessibilityFormatter) {
        _accessibilityFormatter = [NSDateFormatter new];
        _accessibilityFormatter.calendar = self.calendar;
        _accessibilityFormatter.dateStyle = NSDateFormatterLongStyle;
    }
    return _accessibilityFormatter;
}

- (NSInteger)monthOfBeginningDate;
{
    if (!_monthOfBeginningDate) {
        _monthOfBeginningDate = [self.calendar components:NSCalendarUnitMonth fromDate:self.firstOfMonth].month;
    }
    return _monthOfBeginningDate;
}

- (void)setFirstOfMonth:(NSDate *)firstOfMonth;
{
    [super setFirstOfMonth:firstOfMonth];
    self.monthOfBeginningDate = 0;
}

- (NSDateComponents *)todayDateComponents;
{
    if (!_todayDateComponents) {
        self.todayDateComponents = [self.calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
    }
    return _todayDateComponents;
}

@end
