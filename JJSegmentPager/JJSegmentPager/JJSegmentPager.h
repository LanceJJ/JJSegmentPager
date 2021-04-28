//
//  JJSegmentPager.h
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//  v2.1.0

#import <UIKit/UIKit.h>
#import "JJSegmentTableView.h"

/**
 Description 标签按钮底部指示器宽度类型

 - JJBarIndicatorSameWidthType: 等宽类型（默认）
 - JJBarIndicatorAutoWidthType: 自动适应文字宽度类型
 */
typedef NS_ENUM(NSUInteger, JJBarIndicatorType) {

    JJBarIndicatorSameWidthType,
    JJBarIndicatorAutoWidthType
};

/**
 Description 标签按钮宽度类型
 
 - JJBarSegmentBtnAutoWidthType1: 自动适应文字宽度类型(所有按钮宽度之和小于屏幕宽度是时，按钮均分)
 - JJBarSegmentBtnAutoWidthType2: 自动适应文字宽度类型(所有按钮宽度之和小于屏幕宽度是时，按钮从左侧依次布局)
 */
typedef NS_ENUM(NSUInteger, JJBarSegmentBtnWidthType) {
    
    JJBarSegmentBtnAutoWidthType1,
    JJBarSegmentBtnAutoWidthType2,
};

@protocol JJSegmentDelegate <NSObject>

@optional

- (UIScrollView *)jj_segment_obtainScrollView;//获取当前控制器的ScrollView，添加的分页子控制器一定要实现此代理

- (void)jj_segment_scrollViewDidVerticalScroll:(UIScrollView *)scrollView;//mainTableView纵向滑动回调，返回偏移量，用于实现导航栏渐变等动画
- (void)jj_segment_scrollViewDidHorizontalScroll:(UIScrollView *)scrollView;//pageView横向滑动回调，返回偏移量，可以更新第三方按钮的切换动画
- (void)jj_segment_scrollViewDidEndDecelerating:(NSInteger)index;//pageView滑动结束回调，返回当前位置，用于更新第三方标签按钮的点击位置
- (void)jj_segment_didSelected:(NSInteger)index;//标签按钮点击位置回调


@end

@interface JJSegmentPager : UIViewController

@property (nonatomic, weak) id<JJSegmentDelegate> delegate;

/// Description 标签按钮点击位置回调
@property (nonatomic, copy) void(^jj_segment_didSelectedBlock)(NSInteger index);

/// Description pageView滑动结束回调，返回当前位置，用于更新第三方标签按钮的点击位置
@property (nonatomic, copy) void(^jj_segment_scrollViewDidEndDeceleratingBlock)(NSInteger index);

/// Description pageView横向滑动回调，返回偏移量，可以更新第三方按钮的切换动画
@property (nonatomic, copy) void(^jj_segment_scrollViewDidHorizontalScrollBlock)(UIScrollView *scrollView);

/// Description mainTableView纵向滑动回调，返回偏移量，用于实现导航栏渐变等动画
@property (nonatomic, copy) void(^jj_segment_scrollViewDidVerticalScrollBlock)(UIScrollView *scrollView);

/// Description  主列表
@property (nonatomic, strong) JJSegmentTableView *mainTableView;

/// 标签按钮底部指示器宽度类型设置 （默认等宽）
@property (nonatomic, assign) JJBarIndicatorType barIndicatorType;

/// Description 标签按钮的宽度设置（默认JJBarSegmentBtnAutoWidthType1）
@property (nonatomic, assign) JJBarSegmentBtnWidthType barSegmentBtnWidthType;

/// Description 控件尺寸（默认父类控件尺寸，建议初始化时设置尺寸）
@property (nonatomic, assign) CGRect frame;

/// Description 子控制器(需要设置title)，初始化时就需要添加
@property (nonatomic, strong) NSArray *subControllers;

/// Description bar的背景色（默认白色）
@property (nonatomic, strong) UIColor *barBackgroundColor;

/// Description 标题正常颜色（默认黑色）
@property (nonatomic, strong) UIColor *barNormalColor;

/// Description 标题点击颜色（默认蓝色）
@property (nonatomic, strong) UIColor *barSelectColor;

/// Description 底部指示器颜色（默认标题点击颜色）
@property (nonatomic, strong) UIColor *barIndicatorColor;

/// Description segmentBar底部线条颜色（注：适用自定义标签按钮）
@property (nonatomic, strong) UIColor *barLineColor;

/// Description 标题正常尺寸（默认 [UIFont systemFontOfSize:16]）
@property (nonatomic, strong) UIFont *barNormalFont;

/// Description 标题点击尺寸（默认 [UIFont boldSystemFontOfSize:17]）
@property (nonatomic, strong) UIFont *barSelectFont;

/// Description 底部指示器高度（默认3，设置范围 0～按钮高度的1/3，超出范围显示默认值）
@property (nonatomic, assign) CGFloat barIndicatorHeight;

/// Description 底部指示器宽度（当 JJBarIndicatorType == JJBarIndicatorSameWidthType 时设置有效，设置范围 0～按钮宽度，超出范围显示默认值）
@property (nonatomic, assign) CGFloat barIndicatorWidth;

/// Description 底部指示器圆角（默认0）
@property (nonatomic, assign) CGFloat barIndicatorCornerRadius;

/// Description segmentBar的内边距（默认UIEdgeInsetsZero，注：适用自定义标签按钮）
@property (nonatomic, assign) UIEdgeInsets barContentInset;

/// Description 初始化按钮显示位置（默认0）
@property (nonatomic, assign) NSInteger currentPage;

/// Description segmentBar高度（默认44）
@property (nonatomic, assign) CGFloat barHeight;

/// Description segmentBar顶端距离控制器的最小边距（也就是列表向上滑动时，最高能滑动到的位置，默认0，默认可以滑动到最顶端）注：segmentMiniTopInset不可超过headerHeight
@property (nonatomic, assign) CGFloat segmentMiniTopInset;

/// Description 表头高度（默认0, 当headerHeight=segmentMiniTopInset时，表头固定不动）
@property (nonatomic, assign) CGFloat headerHeight;

/// Description 表尾高度（默认0）
@property (nonatomic, assign) CGFloat footerHeight;

/// Description 自定义表头
@property (nonatomic, strong) UIView *customHeaderView;

/// Description 自定义表尾
@property (nonatomic, strong) UIView *customFooterView;

/// Description 自定义标签按钮
@property (nonatomic, strong) UIView *customBarView;

/// Description 允许标签按钮吸顶时可以滚动（默认允许YES）
@property (nonatomic, assign) BOOL enableSegmentBarCeilingScroll;

/// Description 允许主列表下拉刷新（默认不允许NO）
@property (nonatomic, assign) BOOL enableMainRefreshScroll;

/// Description 允许主列表可以上下滑动，改变表头偏移量（默认不允许NO）
@property (nonatomic, assign) BOOL enableMainVerticalScroll;

/// Description 允许页面可以左右横向滑动切换（默认不允许NO）
@property (nonatomic, assign) BOOL enablePageHorizontalScroll;

/// Description 设置segmentBar是否带阴影效果（默认不带NO， 注：适用自定义标签按钮）
@property (nonatomic, assign) BOOL needShadow;

/// Description 设置segmentBar是否带底部线条效果（默认不带NO， 注：适用自定义标签按钮）
@property (nonatomic, assign) BOOL needLine;

/// Description 添加父控制器
/// @param viewController 控制器
- (void)addParentController:(UIViewController *)viewController;

/// Description 添加子控制器(需要设置title)，初始化之后，动态添加
/// @param viewController 控制器
- (void)addSubController:(UIViewController *)viewController;

/// Description 切换pageView
/// @param index 当前位置
- (void)switchPageViewWithIndex:(NSInteger)index;

/// Description 滚动到原点
- (void)scrollToOriginalPoint;

/// Description 滚动到吸顶点
- (void)scrollToCeilingPoint;

/// Description 更新表头高度
/// @param height 高度
- (void)updateHeaderHeight:(CGFloat)height;

@end
