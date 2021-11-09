//
//  JJSegmentPager.h
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//  v2.1.3

#import <UIKit/UIKit.h>
#import "JJSegmentTableView.h"
#import "JJSegmentBar.h"

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

/// Description 标签按钮
@property (nonatomic, strong) JJSegmentBar *segmentBar;

/// Description 控件尺寸（默认父类控件尺寸，建议初始化时设置尺寸）
@property (nonatomic, assign) CGRect frame;

/// Description 子控制器(需要设置title)，初始化时就需要添加
@property (nonatomic, strong) NSArray *subControllers;

/// Description 初始化按钮显示位置（默认0）
@property (nonatomic, assign) NSInteger currentPage;

/// Description segmentBar顶端距离控制器的最小边距（也就是列表向上滑动时，最高能滑动到的位置，默认0，默认可以滑动到最顶端）注：segmentMiniTopInset不可超过headerHeight
@property (nonatomic, assign) CGFloat segmentMiniTopInset;

/// Description 表头高度（默认0, 当headerHeight=segmentMiniTopInset时，表头固定不动）
@property (nonatomic, assign) CGFloat headerHeight;

/// Description 表尾高度（默认0）
@property (nonatomic, assign) CGFloat footerHeight;

/// Description segmentBar高度（默认44）
@property (nonatomic, assign) CGFloat barHeight;

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
