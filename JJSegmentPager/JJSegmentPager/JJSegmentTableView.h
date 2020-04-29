//
//  JJSegmentTableView.h
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JJSegmentTableView;

NS_ASSUME_NONNULL_BEGIN

@protocol JJSegmentTableViewGestureDelegate <NSObject>

@optional

- (BOOL)jj_segmentTableView:(JJSegmentTableView *)tableView gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;

- (BOOL)jj_segmentTableView:(JJSegmentTableView *)tableView gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

@end

@interface JJSegmentTableView : UITableView <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<JJSegmentTableViewGestureDelegate> gestureDelegate;

@end

NS_ASSUME_NONNULL_END
