//
//  JJSegmentPageView.h
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJSegmentScrollView.h"
@class JJSegmentPager;

NS_ASSUME_NONNULL_BEGIN

@protocol JJSegmentPageViewDelegate <NSObject>

- (void)jj_segmentPageView_scrollViewDidVerticalScroll:(UIScrollView *)scrollView;
- (void)jj_segmentPageView_scrollViewDidHorizontalScroll:(UIScrollView *)scrollView;
- (void)jj_segmentPageView_scrollViewDidEndDecelerating:(NSInteger)index;

@end

@interface JJSegmentPageView : UIView

@property (nonatomic, weak) id<JJSegmentPageViewDelegate> delegate;
@property (nonatomic, strong) JJSegmentScrollView *scrollView;//继承自定义ScrollView 防止控制器侧滑返回与ScrollView左右滑动产生冲突
@property (nonatomic, strong) NSMutableArray *subScrollViews;

- (void)setSubControllers:(NSArray *)subControllers currentPage:(NSInteger)currentPage;

/// Description 更新PageView
/// @param index 当前位置
- (void)switchPageViewWithIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
