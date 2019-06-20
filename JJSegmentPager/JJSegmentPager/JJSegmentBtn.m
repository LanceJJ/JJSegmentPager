//
//  JJSegmentBtn.m
//  JJSegmentPager
//
//  Created by Lance on 2018/4/27.
//  Copyright © 2018年 Lance. All rights reserved.
//

#import "JJSegmentBtn.h"


#define JJ_SegmentBtn_NormalBtn_Font 16
#define JJ_SegmentBtn_SelectedBtn_Font 17

@interface JJSegmentBtn()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIFont *selectedFont;
@property (nonatomic, strong) UIFont *normalFont;

@end

@implementation JJSegmentBtn

/**
 Description 初始化
 
 @param title 标题
 @return HTSegmentBtn
 */
- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    
    if (self) {
        
        self.title = title;
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitleColor:self.normalColor forState:UIControlStateNormal];
        
        [self addTarget:self action:@selector(downAction:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(upAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchCancel];
        [self addTarget:self action:@selector(outAction:) forControlEvents:UIControlEventTouchUpOutside];
        
        
    }
    return self;
}

/**
 Description 点击按钮区域外抬起调用
 
 @param button UIButton
 */
- (void)outAction:(UIButton *)button
{
    [UIView animateWithDuration:0.3 animations:^{
        [self setBackgroundColor:[UIColor clearColor]];
    }];
}

/**
 Description 点击按钮取消状态调用
 
 @param button UIButton
 */
- (void)cancelAction:(UIButton *)button
{
    [UIView animateWithDuration:0.3 animations:^{
        [self setBackgroundColor:[UIColor clearColor]];
    }];
}

/**
 Description 点击按钮按下状态调用
 
 @param button button
 */
- (void)downAction:(UIButton *)button
{
    [UIView animateWithDuration:0.3 animations:^{
        [self setBackgroundColor:self.highlightColor];
    }];
}

/**
 Description 点击按钮抬起状态调用
 
 @param button button
 */
- (void)upAction:(UIButton *)button
{
    [UIView animateWithDuration:0.3 animations:^{
        [self setBackgroundColor:[UIColor clearColor]];
    }];
}

/**
 Description 按钮是否点击
 
 @param hasSelected hasSelected
 */
- (void)setHasSelected:(BOOL)hasSelected
{
    _hasSelected = hasSelected;
    
    if (hasSelected) {
        
        [self setTitleColor:self.selectedColor forState:UIControlStateNormal];
        self.titleLabel.font = self.selectedFont;
        
    } else {
        
        [self setTitleColor:self.normalColor forState:UIControlStateNormal];
        self.titleLabel.font = self.normalFont;
    }
}

/**
 Description 设置颜色
 
 @param normalColor 标题正常颜色（默认黑色）
 @param selectColor 标题点击颜色（默认蓝色）
 */
- (void)setTitleNormalColor:(UIColor *)normalColor selectColor:(UIColor *)selectColor
{
    self.selectedColor = selectColor == nil ? [UIColor blueColor] : selectColor;
    self.normalColor = normalColor == nil ? [UIColor blackColor] : normalColor;
    
    self.hasSelected = NO;
}

/**
 Description 设置字体尺寸
 
 @param normalFont 标题正常尺寸
 @param selectFont 标题点击尺寸
 */
- (void)setTitleNormalFont:(UIFont *)normalFont selectFont:(UIFont *)selectFont
{
    self.selectedFont = selectFont == nil ? [UIFont boldSystemFontOfSize:JJ_SegmentBtn_SelectedBtn_Font] : selectFont;
    self.normalFont = normalFont == nil ? [UIFont systemFontOfSize:JJ_SegmentBtn_NormalBtn_Font] : normalFont;
    
    self.hasSelected = NO;
}

@end
