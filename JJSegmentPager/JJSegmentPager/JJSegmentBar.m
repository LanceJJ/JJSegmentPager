//
//  JJSegmentBar.m
//  JJSegmentPager
//
//  Created by Lance on 2018/4/27.
//  Copyright © 2018年 Lance. All rights reserved.
//

#import "JJSegmentBar.h"

#define HT_SegmentBar_ScrollviewH 44.0
#define HT_SegmentBar_BottomH 3.0
#define HT_SegmentBar_Edge 5
#define HT_SegmentBar_BtnCount 5
#define HT_SegmentBar_Padding 20

typedef void(^SelectedBlock) (JJSegmentBtn *button);

@interface JJSegmentBar()

@property (nonatomic, copy) SelectedBlock selectedBlock;
@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) NSMutableArray *titlesArray;
@property (nonatomic, strong) NSMutableArray *buttonsArray;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectColor;
@property (nonatomic, strong) NSArray *titles;

@end

static CGFloat viewWidth;
static CGFloat viewHeight;
@implementation JJSegmentBar

- (NSMutableArray *)titlesArray
{
    if (!_titlesArray) {
        _titlesArray = [NSMutableArray array];
    }
    return _titlesArray;
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
        
        viewWidth = self.frame.size.width;
        viewHeight = self.frame.size.height;
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
        self.scrollview.bounces = NO;
        self.scrollview.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollview];
        
    }
    return self;
}

#pragma mark - private methods

/**
 Description 设置按钮标题
 */
- (void)setupTitles
{
    [self.titlesArray removeAllObjects];
    [self.buttonsArray removeAllObjects];
    
    [self.titlesArray addObjectsFromArray:self.titles];
    
    for (NSString *title in self.titles) {
        
        JJSegmentBtn *button = [[JJSegmentBtn alloc] initWithTitle:title];
        [self.buttonsArray addObject:button];
        
        [button addTarget:self action:@selector(hasBeSelected:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = [self.buttonsArray indexOfObject:button];
        
    }
    
    CGFloat allWidth = [self updateButtonsFrame];
    
    self.scrollview.contentSize = CGSizeMake(allWidth, viewHeight);
}

/**
 Description 初始化控件
 
 @return 所有按钮宽度总和
 */
- (CGFloat)updateButtonsFrame
{
    
    if (self.segmentBtnType == JJSegmentBtnSameWidthType) {//等宽类型
        
        return [self setupSegmentBtnSameWidth];
        
    } else {//自动适应文字宽度类型
        
        CGFloat allWidth = 0;
        
        //计算所有按钮的宽度总和
        for (NSInteger i = 0; i < self.buttonsArray.count; i++) {
            
            JJSegmentBtn *button = self.buttonsArray[i];
            
            [button.titleLabel sizeToFit];
            
            allWidth = button.titleLabel.frame.size.width + HT_SegmentBar_Padding * 2 + allWidth;
        }
        
        //当所有按钮宽度总和小于屏幕宽度时，按钮还是等宽
        if (allWidth <= viewWidth) {
            
            return [self setupSegmentBtnSameWidth];
            
        } else {
            
            return [self setupSegmentBtnAutoWidth];
        }
    }
    return 0;
}

/**
 Description 标签按钮等宽宽度
 
 @return 所有按钮宽度总和
 */
- (CGFloat)setupSegmentBtnSameWidth
{
    NSInteger number = self.titles.count < HT_SegmentBar_BtnCount ? self.titles.count : HT_SegmentBar_BtnCount;
    
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


/**
 Description 标签按钮自动宽度
 
 @return 所有按钮宽度总和
 */
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
        CGFloat previousWidth = i == 0 ? 0 : previousBtn.titleLabel.frame.size.width + HT_SegmentBar_Padding * 2;
        
        //总宽度
        width = previousWidth + width;
        
        button.frame = CGRectMake(width, 0, button.titleLabel.frame.size.width + HT_SegmentBar_Padding * 2, height);
        
        [self.scrollview addSubview:button];
        
        if (i == self.buttonsArray.count - 1) {
            width = button.titleLabel.frame.size.width + HT_SegmentBar_Padding * 2 + width;
        }
    }
    
    JJSegmentBtn *oneBtn = self.buttonsArray[0];
    
    CGFloat oneBtnWidth = oneBtn.frame.size.width;
    
    [self addIndicatorViewWithWidth:oneBtnWidth];
    
    return width;
    
}

/**
 Description 添加标签底部指示器
 
 @param width 按钮宽度
 */
- (void)addIndicatorViewWithWidth:(CGFloat)width
{
    if (self.indicatorView) return;
    self.indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight - HT_SegmentBar_BottomH, width - HT_SegmentBar_Edge * 2, HT_SegmentBar_BottomH)];
    self.indicatorView.backgroundColor = self.selectColor;
    self.indicatorView.center = CGPointMake(width / 2, viewHeight - HT_SegmentBar_BottomH / 2);
    [self.scrollview addSubview:_indicatorView];
}

/**
 Description 按钮点击方法
 
 @param button HTSegmentBtn
 */
- (void)hasBeSelected:(JJSegmentBtn *)button
{
    if (button.hasSelected == NO) {
        
        for (JJSegmentBtn *allBtn in self.buttonsArray) {
            allBtn.hasSelected = NO;
        }
        
        button.hasSelected = YES;
        
        if (self.selectedBlock) {
            self.selectedBlock(button);
        }
        
        [button.titleLabel sizeToFit];
        
        CGFloat currentBtnWidth = button.frame.size.width - HT_SegmentBar_Edge * 2;
        
        
        CGFloat btnTitleWidth = button.titleLabel.frame.size.width > currentBtnWidth ? currentBtnWidth: button.titleLabel.frame.size.width;
        CGFloat indicatorWidth = self.indicatorType == JJIndicatorSameWidthType ? currentBtnWidth : btnTitleWidth;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.indicatorView.frame = CGRectMake(0, 0, indicatorWidth, HT_SegmentBar_BottomH);
            self.indicatorView.center = CGPointMake(button.center.x , viewHeight - HT_SegmentBar_BottomH / 2);
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
    
    if (scrollOffsetX > self.scrollview.contentSize.width - self.scrollview.frame.size.width) {
        scrollOffsetX = self.scrollview.contentSize.width - self.scrollview.frame.size.width;
    }
    
    [self.scrollview setContentOffset:CGPointMake(scrollOffsetX, 0) animated:YES];
}

#pragma mark - public methods

/**
 Description 设置参数
 
 @param titles 标题
 @param normalColor 标题正常颜色（默认黑色）
 @param selectColor 标题点击颜色（默认蓝色）
 @param currentPage 初始化按钮显示位置 (默认0)
 */
- (void)setTitles:(NSArray *)titles normalColor:(UIColor *)normalColor selectColor:(UIColor *)selectColor currentPage:(NSInteger)currentPage
{
    if (titles.count == 0 || titles == nil) return;
    
    self.titles = titles;
    
    [self setupTitles];
    
    self.selectColor = selectColor == nil ? [UIColor blueColor] : selectColor;
    self.normalColor = normalColor == nil ? [UIColor blackColor] : normalColor;
    self.highlightBackgroundColor = _highlightBackgroundColor == nil ? [UIColor clearColor] : _highlightBackgroundColor;
    
    self.indicatorView.backgroundColor = _selectColor;
    
    for (JJSegmentBtn *allBtn in self.buttonsArray) {
        
        [allBtn setTitleNormalColor:self.normalColor selectColor:self.selectColor];
    }
    self.currentPage = currentPage < titles.count ? currentPage : 0;
}

#pragma mark - set methods

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    
    if (self.buttonsArray.count == 0 || self.buttonsArray.count - 1 < currentPage) return;
    
    JJSegmentBtn *button = self.buttonsArray[currentPage];
    
    [self hasBeSelected:button];
}

- (void)setHighlightBackgroundColor:(UIColor *)highlightBackgroundColor
{
    _highlightBackgroundColor = highlightBackgroundColor;
    
    if (self.buttonsArray.count == 0 || self.buttonsArray == nil) return;
    
    for (JJSegmentBtn *allBtn in self.buttonsArray) {
        
        allBtn.highlightColor = _highlightBackgroundColor;
        
    }
}

- (void)setIndicatorType:(JJIndicatorWidthType)indicatorType
{
    _indicatorType = indicatorType;
    
    if (self.buttonsArray.count == 0 || self.buttonsArray == nil) return;
    
    if (indicatorType == JJIndicatorSameWidthType) return;
    
    for (NSInteger i = 0; i < self.buttonsArray.count; i++) {
        
        if (i == _currentPage) {
            
            JJSegmentBtn *currentBtn = self.buttonsArray[i];
            
            [currentBtn.titleLabel sizeToFit];
            
            CGFloat currentBtnWidth = currentBtn.frame.size.width - HT_SegmentBar_Edge * 2;
            
            CGFloat btnTitleWidth = currentBtn.titleLabel.frame.size.width > currentBtnWidth ? currentBtnWidth : currentBtn.titleLabel.frame.size.width;
            
            self.indicatorView.frame = CGRectMake(0, 0, btnTitleWidth, HT_SegmentBar_BottomH);
            self.indicatorView.center = CGPointMake(currentBtn.center.x , viewHeight - HT_SegmentBar_BottomH / 2);
        }
    }
}

- (void)setSegmentBtnType:(JJSegmentBtnWidthType)segmentBtnType
{
    _segmentBtnType = segmentBtnType;
    
    if (self.buttonsArray.count == 0 || self.buttonsArray == nil) return;
    
    if (segmentBtnType == JJSegmentBtnSameWidthType) return;
    
    [self updateButtonsFrame];
    
    for (NSInteger i = 0; i < self.buttonsArray.count; i++) {
        
        if (i == _currentPage) {
            
            JJSegmentBtn *currentBtn = self.buttonsArray[i];
            
            [currentBtn.titleLabel sizeToFit];
            
            CGFloat currentBtnWidth = currentBtn.frame.size.width - HT_SegmentBar_Edge * 2;
            
            CGFloat btnTitleWidth = currentBtn.titleLabel.frame.size.width > currentBtnWidth ? currentBtnWidth: currentBtn.titleLabel.frame.size.width;
            CGFloat indicatorWidth = self.indicatorType == JJIndicatorSameWidthType ? currentBtnWidth : btnTitleWidth;
            
            self.indicatorView.frame = CGRectMake(0, 0, indicatorWidth, HT_SegmentBar_BottomH);
            self.indicatorView.center = CGPointMake(currentBtn.center.x , viewHeight - HT_SegmentBar_BottomH / 2);
        }
    }
    
}

#pragma mark - block methods

/**
 Description 按钮点击回调
 
 @param block block description
 */
- (void)selectedBlock:(void(^)(JJSegmentBtn *button))block
{
    if (block) {
        self.selectedBlock = block;
    }
}


@end
