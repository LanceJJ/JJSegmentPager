//
//  JJSegmentBtn.m
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//

#import "JJSegmentBtn.h"

@interface JJSegmentBtn()

@property (nonatomic, copy) NSString *title;

@end

@implementation JJSegmentBtn

/// Description 初始化
/// @param title 标题
- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    
    if (self) {
        
        self.highlightColor = [UIColor clearColor];
        self.selectColor = [UIColor blueColor];
        self.normalColor = [UIColor blackColor];
        self.selectFont = [UIFont boldSystemFontOfSize:17];
        self.normalFont = [UIFont systemFontOfSize:16];
        
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

/// Description 点击按钮区域外抬起调用
- (void)outAction:(UIButton *)button
{
    [UIView animateWithDuration:0.3 animations:^{
        [self setBackgroundColor:[UIColor clearColor]];
    }];
}

/// Description 点击按钮取消状态调用
- (void)cancelAction:(UIButton *)button
{
    [UIView animateWithDuration:0.3 animations:^{
        [self setBackgroundColor:[UIColor clearColor]];
    }];
}

/// Description 点击按钮按下状态调用
- (void)downAction:(UIButton *)button
{
    [UIView animateWithDuration:0.3 animations:^{
        [self setBackgroundColor:self.highlightColor];
    }];
}

/// Description 点击按钮抬起状态调用
- (void)upAction:(UIButton *)button
{
    [UIView animateWithDuration:0.3 animations:^{
        [self setBackgroundColor:[UIColor clearColor]];
    }];
}

/// Description 按钮是否点击
/// @param isSelect isSelect
- (void)setIsSelect:(BOOL)isSelect
{
    _isSelect = isSelect;
    
    if (isSelect) {
        
        [self setTitleColor:self.selectColor forState:UIControlStateNormal];
        self.titleLabel.font = self.selectFont;
        
    } else {
        
        [self setTitleColor:self.normalColor forState:UIControlStateNormal];
        self.titleLabel.font = self.normalFont;
    }
}

- (void)setHighlightColor:(UIColor *)highlightColor
{
    _highlightColor = highlightColor ? highlightColor : [UIColor clearColor];
}

- (void)setNormalFont:(UIFont *)normalFont
{
    _normalFont = normalFont ? normalFont : [UIFont systemFontOfSize:16];
}

- (void)setSelectFont:(UIFont *)selectFont
{
    _selectFont = selectFont ? selectFont : [UIFont boldSystemFontOfSize:17];
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor ? normalColor : [UIColor blackColor];
}

- (void)setSelectColor:(UIColor *)selectColor
{
    _selectColor = selectColor ? selectColor : [UIColor blueColor];
}

@end
