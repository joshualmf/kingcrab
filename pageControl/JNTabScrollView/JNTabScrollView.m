//
//  JNTabScrollView.m
//  pageControl
//
//  Created by Joshua on 16/8/4.
//  Copyright © 2016年 Apple Inc. All rights reserved.
//

#import "JNTabScrollView.h"

#define SCREEN_WIDTH        ([UIScreen mainScreen].bounds.size.width)

@interface JNTabScrollView ()

@property (nonatomic, strong) UIScrollView  *titleTab;
@property (nonatomic, strong) UIView        *selectedUnderLine;
@property (nonatomic, strong) UIScrollView  *contentView;

@end

@interface JNTabScrollView ()
{
    CGFloat     _tabButtonWidth;
}
@end

@implementation JNTabScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleTab = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 40)];
        _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, SCREEN_WIDTH, 440)];
        _contentView.delegate = self;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self setBackgroundColor:[UIColor blueColor]];
    [_titleTab setBackgroundColor:[UIColor yellowColor]];
    //[_titleTab setPagingEnabled:YES];
    [_contentView setBackgroundColor:[UIColor greenColor]];
    [_contentView setPagingEnabled:YES];
    
    [self setupTabs];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self addSubview:_titleTab];
    [self addSubview:_contentView];
}

- (void)setupTabs
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfTabs)]) {
        NSInteger tabNum = [_dataSource numberOfTabs];
        CGFloat visibleNum = MIN(5.5, tabNum);
        _tabButtonWidth = SCREEN_WIDTH / visibleNum;
        
        [self drawSelectedUnderlineWithSize:CGSizeMake(_tabButtonWidth, 2)];
        
        for (int i = 0; i < tabNum; i++) {
            NSString *title = [_dataSource titleOfTabAtIndex:i];
            UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [titleButton setTitle:title forState:UIControlStateNormal];
            titleButton.frame = CGRectMake(i * _tabButtonWidth, 5, _tabButtonWidth, 30);
            titleButton.tag = i;
            [titleButton addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_titleTab addSubview:titleButton];
        }
        [_titleTab setContentSize:CGSizeMake(tabNum * _tabButtonWidth, 30)];
        
        for (int i = 0; i < tabNum; i++) {
            UIView *view = [_dataSource viewForTabAtIndex:i];
            view.frame = CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, _contentView.frame.size.height);
            [_contentView addSubview:view];
        }
        [_contentView setContentSize:CGSizeMake(tabNum *SCREEN_WIDTH, _contentView.frame.size.height)];
    }
}

- (void)drawSelectedUnderlineWithSize:(CGSize)lineSize
{
    CGFloat lineHeight = _titleTab.frame.size.height - lineSize.height;
    _selectedUnderLine = [[UIView alloc] initWithFrame:CGRectMake(0, lineHeight, lineSize.width, lineSize.height)];
    [_selectedUnderLine setBackgroundColor:[UIColor redColor]];
    [_titleTab addSubview:_selectedUnderLine];
}

- (void)tabButtonClicked:(UIButton *)button
{
    if (button) {
        if (button.tag >= 0) {
            [self switchToIndex:button.tag];
        }
    }
}

- (void)switchToIndex:(NSInteger)index
{
    [self moveUnderlineToIndex:index];
    [self scrollContentToIndex:index];
}

- (void)moveUnderlineToIndex:(NSInteger)index
{
    CGRect pastRect = _selectedUnderLine.frame;
    
    CGRect nextRect = pastRect;
    nextRect.origin.x = index * _tabButtonWidth;
    
    [UIView animateWithDuration:0.5f animations:^{
        _selectedUnderLine.frame = nextRect;
    }];
    
    if (nextRect.origin.x + nextRect.size.width > _titleTab.contentOffset.x + SCREEN_WIDTH) {
        // 下划线游标超过屏幕最右侧
        [_titleTab setContentOffset:CGPointMake(nextRect.origin.x + _tabButtonWidth - SCREEN_WIDTH, _titleTab.contentOffset.y) animated:YES];
    } else if (_titleTab.contentOffset.x > nextRect.origin.x) {
        // 下划线游标超过屏幕最左侧
        [_titleTab setContentOffset:CGPointMake(nextRect.origin.x, _titleTab.contentOffset.y) animated:YES];
    }
}

- (void)scrollContentToIndex:(NSInteger)index
{
    [_contentView setContentOffset:CGPointMake(index * SCREEN_WIDTH, 0) animated:YES];
}


#pragma mark - scrollview scroll delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSInteger index = _contentView.contentOffset.x / SCREEN_WIDTH;
    [self switchToIndex:index];
}
@end
