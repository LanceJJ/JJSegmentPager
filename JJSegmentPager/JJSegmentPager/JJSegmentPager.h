//
//  JJSegmentPager.h
//  JJSegmentPager
//
//  Created by Lance on 2018/4/27.
//  Copyright © 2018年 Lance. All rights reserved.
//

#import <UIKit/UIKit.h>

#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define kNavHeight (iPhoneX ? 88 : 64)

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

 - JJBarSegmentBtnSameWidthType: 等宽类型（默认）
 - JJBarSegmentBtnAutoWidthType: 自动适应文字宽度类型
 */
typedef NS_ENUM(NSUInteger, JJBarSegmentBtnWidthType) {
    
    JJBarSegmentBtnSameWidthType,
    JJBarSegmentBtnAutoWidthType
};


@protocol JJSegmentDelegate <NSObject>

/**
 Description
 
 @return 获取当前控制器的ScrollView
 */
- (UIScrollView *)streachScrollView;

@end



@interface JJSegmentPager : UIViewController

/**
 Description 标签按钮底部指示器宽度类型设置 （默认等宽）
 */
@property (nonatomic, assign) JJBarIndicatorType barIndicatorType;

/**
 Description 标签按钮的宽度设置（默认等宽）
 */
@property (nonatomic, assign) JJBarSegmentBtnWidthType barSegmentBtnWidthType;

/**
 Description 当前子控制器
 */
@property (nonatomic, weak) UIViewController<JJSegmentDelegate> *currentDisplayController;

/**
 Description 子控制器(需要设置title)
 */
@property (nonatomic, strong) NSArray *subControllers;

/**
 Description 按钮高亮背景色（默认透明）
 */
@property (nonatomic, strong) UIColor *barHighlightBackgroundColor;

/**
 Description bar的背景色（默认白色）
 */
@property (nonatomic, strong) UIColor *barBackgroundColor;

/**
 Description 标题正常颜色（默认黑色）
 */
@property (nonatomic, strong) UIColor *barNormalColor;

/**
 Description 标题点击颜色（默认蓝色）
 */
@property (nonatomic, strong) UIColor *barSelectColor;

/**
 Description segmentBar的内边距（默认UIEdgeInsetsZero）
 */
@property (nonatomic, assign) UIEdgeInsets barContentInset;

/**
 Description 初始化按钮显示位置（默认0）
 */
@property (nonatomic, assign) NSInteger currentPage;

/**
 Description segmentBar高度（默认44）
 */
@property (nonatomic, assign) CGFloat segmentHeight;

/**
 Description segmentBar顶端距离控制器的最小边距（也就是列表向上滑动时，最高能滑动到的位置，默认0，默认可以滑动到最顶端）注:segmentMiniTopInset不可超过headerHeight
 */
@property (nonatomic, assign) CGFloat segmentMiniTopInset;

/**
 Description 表头高度（默认0）
 */
@property (nonatomic, assign) CGFloat headerHeight;

/**
 Description 表尾高度（默认0）
 */
@property (nonatomic, assign) CGFloat footerHeight;

/**
 Description 自定义表头
 */
@property (nonatomic, strong) UIView *customHeaderView;

/**
 Description 自定义表尾
 */
@property (nonatomic, strong) UIView *customFooterView;

/**
 Description 自定义标签按钮
 */
@property (nonatomic, strong) UIView *customBarView;

/**
 Description 允许列表下拉时,表头可以扩展到最大高度（默认不允许NO）
 */
@property (nonatomic, assign) BOOL enableMaxHeaderHeight;

/**
 Description 允许列表滑动时,同时改变表头偏移量（默认不允许NO）
 */
@property (nonatomic, assign) BOOL enableOffsetChanged;

/**
 Description 允许列表的数据源过小时,仍可向上滑动,来改变表头偏移量（默认不允许NO）
 */
@property (nonatomic, assign) BOOL enableContentSizeChanged;

/**
 Description 允许页面可以左右滑动切换（默认不允许NO）
 */
@property (nonatomic, assign) BOOL enableScrollViewDrag;

/**
 Description 设置segmentBar是否带阴影效果（默认不带NO）
 */
@property (nonatomic, assign) BOOL needShadow;

/**
 Description 添加父控制器
 
 @param viewController 控制器
 */
- (void)addParentController:(UIViewController *)viewController;

/**
 Description 按钮点击方法
 
 @param index 当前点击位置
 */
- (void)segmentDidSelectedValue:(NSInteger)index;

/**
 Description 列表滑动过程中偏移量数值回调（当自定义表头时,回调此偏移量,以供外界自定义表头使用）
 
 @param block block description
 */
- (void)updateSegmentTopInsetBlock:(void(^)(CGFloat top))block;

/**
 Description 按钮点击回调
 
 @param block 按钮索引
 */
- (void)selectedSegmentBarBlock:(void(^)(NSInteger index))block;

/**
 Description scrollViewDidEndDecelerating代理回调
 
 @param block 当前页面位置
 */
- (void)scrollViewDidEndDeceleratingBlock:(void(^)(NSInteger currentPage))block;

@end
