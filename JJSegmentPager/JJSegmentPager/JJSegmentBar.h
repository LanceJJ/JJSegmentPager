//
//  JJSegmentBar.h
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Description 标签底部指示器宽度类型

 - JJIndicatorSameWidthType: 等宽类型（默认）
 - JJIndicatorAutoWidthType: 自动适应文字宽度类型
 */
typedef NS_ENUM(NSUInteger, JJIndicatorWidthType) {
    
    JJIndicatorSameWidthType,
    JJIndicatorAutoWidthType
};

/**
 Description 标签按钮宽度类型
 
 - JJSegmentBtnAutoWidthType1: 自动适应文字宽度类型(所有按钮宽度之和小于屏幕宽度是时，按钮均分)
 - JJSegmentBtnAutoWidthType2: 自动适应文字宽度类型(所有按钮宽度之和小于屏幕宽度是时，按钮从左侧依次布局)
 */
typedef NS_ENUM(NSUInteger, JJSegmentBtnWidthType) {
    
    JJSegmentBtnAutoWidthType1,
    JJSegmentBtnAutoWidthType2
};

@protocol JJSegmentBarDelegate <NSObject>

- (void)jj_segmentBar_didSelected:(NSInteger)index;

@end

@interface JJSegmentBar : UIView

@property (nonatomic, weak) id<JJSegmentBarDelegate> delegate;

/// Description 标签底部指示器宽度类型设置 （默认等宽）
@property (nonatomic, assign) JJIndicatorWidthType indicatorType;

/// Description 标签按钮的宽度设置（默认等宽）
@property (nonatomic, assign) JJSegmentBtnWidthType segmentBtnType;

/// Description 标题数组
@property (nonatomic, strong) NSArray *titles;

/// Description 当前按钮位置
@property (nonatomic, assign) NSInteger currentPage;

/// Description 按钮之间的间距 默认24
@property (nonatomic, assign) CGFloat itemPadding;

/// Description 标题正常尺寸（默认 [UIFont systemFontOfSize:16]）
@property (nonatomic, strong) UIFont *normalFont;

/// Description 标题点击尺寸（默认 [UIFont boldSystemFontOfSize:17]）
@property (nonatomic, strong) UIFont *selectFont;

/// Description 标题正常颜色（默认黑色）
@property (nonatomic, strong) UIColor *normalColor;

/// Description 标题点击颜色（默认蓝色）
@property (nonatomic, strong) UIColor *selectColor;

/// Description 底部指示器颜色（默认标题点击颜色）
@property (nonatomic, strong) UIColor *indicatorColor;

/// Description 底部指示器高度（默认3，设置范围 0～按钮高度的1/3，超出范围显示默认值）
@property (nonatomic, assign) CGFloat indicatorHeight;

/// Description 底部指示器宽度（当 JJIndicatorWidthType == JJIndicatorSameWidthType 时设置有效，设置范围 0～按钮宽度，超出范围显示默认值）
@property (nonatomic, assign) CGFloat indicatorWidth;

/// Description 底部指示器圆角
@property (nonatomic, assign) CGFloat indicatorCornerRadius;

/// Description 初始化各项参数配置
- (void)setupConfigureAppearance;

/// Description 切换当前点击按钮位置
/// @param currentPage 当前按钮位置
- (void)switchBtnWithCurrentPage:(NSInteger)currentPage;

@end

@interface PPSegmentBarCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@end
