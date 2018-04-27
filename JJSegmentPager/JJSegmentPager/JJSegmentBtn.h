//
//  JJSegmentBtn.h
//  JJSegmentPager
//
//  Created by Lance on 2018/4/27.
//  Copyright © 2018年 Lance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJSegmentBtn : UIButton

/**
 Description 点击状态
 */
@property (nonatomic, assign) BOOL hasSelected;

/**
 Description 按钮高亮背景色（默认透明）
 */
@property (nonatomic, strong) UIColor *highlightColor;

/**
 Description 初始化
 
 @param title 标题
 @return HTSegmentBtn
 */
- (instancetype)initWithTitle:(NSString *)title;

/**
 Description 设置颜色
 
 @param normalColor 标题正常颜色（默认黑色）
 @param selectColor 标题点击颜色（默认蓝色）
 */
- (void)setTitleNormalColor:(UIColor *)normalColor selectColor:(UIColor *)selectColor;

@end
