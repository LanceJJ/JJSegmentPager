//
//  JJSegmentBar.m
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//

#import "JJSegmentBar.h"

#define JJ_SegmentBar_ScrollviewH 44.0
#define JJ_SegmentBar_BottomH 3.0
#define JJ_SegmentBar_Edge 5
#define JJ_SegmentBar_BtnCount 5
#define JJ_SegmentBar_Padding 20


@interface JJSegmentBar()

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) NSMutableArray *buttonsArray;
@property (nonatomic, strong) UIView *indicatorView;

@end

@implementation JJSegmentBar
{
    CGFloat viewWidth;
    CGFloat viewHeight;
}

- (UIColor *)indicatorColor
{
    if (!_indicatorColor) {
        _indicatorColor = self.selectColor ? self.selectColor : [UIColor blueColor];
    }
    return _indicatorColor;
}

- (NSMutableArray *)buttonsArray
{
    if (!_buttonsArray) {
        _buttonsArray = [NSMutableArray array];
    }
    return _buttonsArray;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, self.frame.size.height);
        self.clipsToBounds = YES;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        viewWidth = self.frame.size.width;
        viewHeight = self.frame.size.height;
        
        [self setupScrollview];
        
    }
    return self;
}

#pragma mark - private methods

- (void)setupScrollview
{
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    scrollview.bounces = NO;
    scrollview.showsHorizontalScrollIndicator = NO;
    [self addSubview:scrollview];
    
    self.scrollview = scrollview;
}

/// Description 初始化按钮
- (void)setupSegmentBtn
{
    [self.buttonsArray removeAllObjects];
    
    for (NSString *title in self.titles) {
        
        JJSegmentBtn *button = [[JJSegmentBtn alloc] initWithTitle:title];
        [self.buttonsArray addObject:button];
        
        button.normalColor = self.normalColor;
        button.selectColor = self.selectColor;
        button.normalFont = self.normalFont;
        button.selectFont = self.selectFont;
        button.highlightColor = self.highlightBackgroundColor;
        
        [button addTarget:self action:@selector(segmentBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = [self.buttonsArray indexOfObject:button];
        
    }
    
    CGFloat allWidth = [self updateButtonsFrame];
    
    self.scrollview.contentSize = CGSizeMake(allWidth, viewHeight);
}

/// Description 更新按钮位置尺寸
- (CGFloat)updateButtonsFrame
{
    CGFloat allWidth = 0;
    
    //计算所有按钮的宽度总和
    for (NSInteger i = 0; i < self.buttonsArray.count; i++) {
        
        JJSegmentBtn *button = self.buttonsArray[i];
        
        [button.titleLabel sizeToFit];
        
        allWidth = button.titleLabel.frame.size.width + JJ_SegmentBar_Padding * 2 + allWidth;
    }
    
    //当所有按钮宽度总和小于屏幕宽度时，按钮还是等宽
    if (allWidth <= viewWidth && self.segmentBtnType == JJSegmentBtnAutoWidthType1) {
        
        return [self setupSegmentBtnSameWidth];
        
    } else {
        
        return [self setupSegmentBtnAutoWidth];
    }
}

/// Description 标签按钮等宽宽度
- (CGFloat)setupSegmentBtnSameWidth
{
    NSInteger number = self.titles.count < JJ_SegmentBar_BtnCount ? self.titles.count : JJ_SegmentBar_BtnCount;
    
    CGFloat width = CGRectGetWidth(self.frame) / number;
    CGFloat height = viewHeight;
    
    for (NSInteger i = 0; i < self.buttonsArray.count; i++) {
        
        JJSegmentBtn *button = self.buttonsArray[i];
        [button.titleLabel sizeToFit];
        
        button.frame = CGRectMake(i * width, 0, width, height);
        
        [self.scrollview addSubview:button];
    }
    
    [self addIndicatorViewWithWidth:width];
    
    return width * self.titles.count;
}

/// Description 标签按钮自动宽度
- (CGFloat)setupSegmentBtnAutoWidth
{
    CGFloat width = 0;
    CGFloat height = viewHeight;
    
    for (NSInteger i = 0; i < self.buttonsArray.count; i++) {
        
        //前一个按钮
        JJSegmentBtn *previousBtn = i == 0 ? nil : self.buttonsArray[i - 1];
        //当前按钮
        JJSegmentBtn *button = self.buttonsArray[i];
        
        [button.titleLabel sizeToFit];
        [previousBtn.titleLabel sizeToFit];
        
        //前一个按钮的宽度
        CGFloat previousWidth = i == 0 ? 0 : previousBtn.titleLabel.frame.size.width + JJ_SegmentBar_Padding * 2;
        
        //总宽度
        width = previousWidth + width;
        
        button.frame = CGRectMake(width, 0, button.titleLabel.frame.size.width + JJ_SegmentBar_Padding * 2, height);
        
        [self.scrollview addSubview:button];
        
        if (i == self.buttonsArray.count - 1) {
            width = button.titleLabel.frame.size.width + JJ_SegmentBar_Padding * 2 + width;
        }
    }
    
    JJSegmentBtn *oneBtn = self.buttonsArray[0];
    
    CGFloat oneBtnWidth = oneBtn.frame.size.width;
    
    [self addIndicatorViewWithWidth:oneBtnWidth];
    
    return width;
}

/// Description 添加标签底部指示器
/// @param width 按钮宽度
- (void)addIndicatorViewWithWidth:(CGFloat)width
{
    if (self.indicatorView) return;
    
    UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight - JJ_SegmentBar_BottomH, width - JJ_SegmentBar_Edge * 2, JJ_SegmentBar_BottomH)];
    indicatorView.backgroundColor = self.indicatorColor;
    indicatorView.center = CGPointMake(width / 2, viewHeight - JJ_SegmentBar_BottomH / 2);
    indicatorView.layer.cornerRadius = self.indicatorCornerRadius;
    [self.scrollview addSubview:indicatorView];
    
    self.indicatorView = indicatorView;
}

/// Description 按钮点击方法
/// @param button JJSegmentBtn
- (void)segmentBtnAction:(JJSegmentBtn *)button
{
    [self segmentBtnSelected:button duration:0.3 isSelect:YES];
}

/// Description 切换按钮状态
/// @param button 按钮
/// @param duration 动画时间
/// @param isSelect 是否点击按钮
- (void)segmentBtnSelected:(JJSegmentBtn *)button duration:(NSTimeInterval)duration isSelect:(BOOL)isSelect
{
    if (button.isSelect == NO) {
        
        for (JJSegmentBtn *segmentBtn in self.buttonsArray) {
            segmentBtn.isSelect = NO;
        }
        
        button.isSelect = YES;
        
        if (isSelect &&[self.delegate respondsToSelector:@selector(jj_segmentBar_buttonDidSelected:)]) {
            [self.delegate jj_segmentBar_buttonDidSelected:button.tag];
        }
    
        [button.titleLabel sizeToFit];
        
        CGFloat currentBtnWidth = button.frame.size.width - JJ_SegmentBar_Edge * 2;
        
        //如果设置的高度小于0，或者大于按钮高度的1/3，显示默认高度
        self.indicatorHeight = (self.indicatorHeight <= 0 || self.indicatorHeight > viewHeight / 3.0) ? JJ_SegmentBar_BottomH : self.indicatorHeight;
        //如果设置的宽度小于0，或者大于按钮宽度，显示默认宽度
        self.indicatorWidth = (self.indicatorWidth <= 0 || self.indicatorWidth > currentBtnWidth) ? currentBtnWidth : self.indicatorWidth;
        
        CGFloat btnTitleWidth = button.titleLabel.frame.size.width > currentBtnWidth ? currentBtnWidth: button.titleLabel.frame.size.width;
        CGFloat indicatorWidth = self.indicatorType == JJIndicatorSameWidthType ? self.indicatorWidth : btnTitleWidth;
        
        [UIView animateWithDuration:duration animations:^{
            
            self.indicatorView.frame = CGRectMake(0, 0, indicatorWidth, self.indicatorHeight);
            self.indicatorView.center = CGPointMake(button.center.x , viewHeight - self.indicatorHeight / 2);
        }];
    }
    
    // scroll view 当前偏移量
    CGFloat scrollOffsetX = self.scrollview.contentOffset.x;
    // 屏幕中显示的位置
    CGFloat screenX = self.frame.size.width / 2;
    // 在当前屏幕中偏移量
    CGFloat selectOffsetX = button.frame.origin.x - self.scrollview.contentOffset.x;
    
    if (selectOffsetX < screenX) {
        scrollOffsetX -= screenX - selectOffsetX;
    }else{
        scrollOffsetX += selectOffsetX - screenX;
    }
    
    if (scrollOffsetX < 0) {
        scrollOffsetX = 0;
    }

    if (self.scrollview.contentSize.width - self.scrollview.frame.size.width < 0) {
        scrollOffsetX = 0;
    } else if (scrollOffsetX > self.scrollview.contentSize.width - self.scrollview.frame.size.width) {
        scrollOffsetX = self.scrollview.contentSize.width - self.scrollview.frame.size.width;
    } else {
//        scrollOffsetX = 0;
    }
    
    [self.scrollview setContentOffset:CGPointMake(scrollOffsetX, 0) animated:YES];
}

/// Description 初始化各项参数配置
- (void)setupConfigureAppearance
{
    if (self.titles.count == 0 || self.titles == nil) return;
    
    [self setupSegmentBtn];

    self.currentPage = (self.currentPage > self.titles.count - 1 || self.currentPage < 0) ? 0 : self.currentPage;
    
    JJSegmentBtn *button = self.buttonsArray[self.currentPage];
    
    [self segmentBtnSelected:button duration:0.0 isSelect:NO];
    
}

/// Description 切换当前点击按钮位置
/// @param currentPage 当前按钮位置
- (void)switchBtnWithCurrentPage:(NSInteger)currentPage
{
    self.currentPage = (currentPage > self.titles.count - 1 || currentPage < 0) ? 0 : currentPage;
    
    if (self.buttonsArray.count == 0 || self.buttonsArray.count - 1 < self.currentPage) return;
    
    JJSegmentBtn *button = self.buttonsArray[self.currentPage];
    
    [self segmentBtnSelected:button duration:0.3 isSelect:NO];
}

@end
