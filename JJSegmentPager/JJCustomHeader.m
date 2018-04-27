//
//  JJCustomHeader.m
//  JJSegmentPager
//
//  Created by Lance on 2018/4/27.
//  Copyright © 2018年 Lance. All rights reserved.
//

#import "JJCustomHeader.h"

@interface JJCustomHeader ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerImageH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerImageW;


@end


@implementation JJCustomHeader

- (void)updateHeaderImageWithOffsetY:(CGFloat)offsetY
{
    //80是头像默认大小，240是表头的高度，计算比例
    self.headerImageH.constant = offsetY / 240 * 80;
    self.headerImageW.constant = offsetY / 240 * 80;
}

@end
