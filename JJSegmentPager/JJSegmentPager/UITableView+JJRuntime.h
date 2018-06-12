//
//  UITableView+JJRuntime.h
//  JJSegmentPager
//
//  Created by Lance on 2018/6/12.
//  Copyright © 2018年 Lance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (JJRuntime)

@property (nonatomic, copy) void(^didReloadData)(void);

@end

