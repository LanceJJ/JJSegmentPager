//
//  UIScrollView+JJExchange.h
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (JJExchange)

@property (nonatomic, copy) void(^jj_replaceScrollViewDidScrollBlock)(UIScrollView *scrollView);

@end

NS_ASSUME_NONNULL_END
