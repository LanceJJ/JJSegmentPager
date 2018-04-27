//
//  JJSegmentBar.h
//  JJSegmentPager
//
//  Created by Lance on 2018/4/27.
//  Copyright © 2018年 Lance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJSegmentBtn.h"

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

 - JJSegmentBtnSameWidthType: 等宽类型（默认）
 - JJSegmentBtnAutoWidthType: 自动适应文字宽度类型
 */
typedef NS_ENUM(NSUInteger, JJSegmentBtnWidthType) {
    
    JJSegmentBtnSameWidthType,
    JJSegmentBtnAutoWidthType
};


@interface JJSegmentBar : UIView

/**
 Description 标签底部指示器宽度类型设置 （默认等宽）
 */
@property (nonatomic, assign) JJIndicatorWidthType indicatorType;

/**
 Description 标签按钮的宽度设置（默认等宽）
 */
@property (nonatomic, assign) JJSegmentBtnWidthType segmentBtnType;

/**
 Description 当前按钮位置
 */
@property (nonatomic, assign) NSInteger currentPage;

/**
 Description 按钮高亮背景色（默认透明）
 */
@property (nonatomic, strong) UIColor *highlightBackgroundColor;

/**
 Description 设置参数
 
 @param titles 标题
 @param normalColor 标题正常颜色（默认黑色）
 @param selectColor 标题点击颜色（默认蓝色）
 @param currentPage 初始化按钮显示位置 (默认0)
 */
- (void)setTitles:(NSArray *)titles normalColor:(UIColor *)normalColor selectColor:(UIColor *)selectColor currentPage:(NSInteger)currentPage;

/**
 Description 按钮点击回调
 
 @param block block description
 */
- (void)selectedBlock:(void(^)(JJSegmentBtn *button))block;

@end
