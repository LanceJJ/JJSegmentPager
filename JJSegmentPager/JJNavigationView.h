//
//  JJNavigationView.h
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJNavigationView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) void(^backBlock)(void);

@end

NS_ASSUME_NONNULL_END
