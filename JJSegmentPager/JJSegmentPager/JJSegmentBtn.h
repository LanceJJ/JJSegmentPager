//
//  JJSegmentBtn.h
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJSegmentBtn : UIButton

/// Description 点击状态
@property (nonatomic, assign) BOOL isSelect;

/// Description 按钮高亮背景色（默认透明）
@property (nonatomic, strong) UIColor *highlightColor;

/// Description 标题点击颜色（默认蓝色）
@property (nonatomic, strong) UIColor *selectColor;

/// Description 标题正常颜色（默认黑色）
@property (nonatomic, strong) UIColor *normalColor;

/// Description 标题点击尺寸（默认 [UIFont boldSystemFontOfSize:17]）
@property (nonatomic, strong) UIFont *selectFont;

/// Description 标题正常尺寸（默认 [UIFont systemFontOfSize:16]）
@property (nonatomic, strong) UIFont *normalFont;

/// Description 初始化
/// @param title 标题
- (instancetype)initWithTitle:(NSString *)title;


@end
