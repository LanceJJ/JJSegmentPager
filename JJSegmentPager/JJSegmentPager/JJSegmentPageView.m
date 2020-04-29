//
//  JJSegmentPageView.m
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//

#import "JJSegmentPageView.h"
#import "JJSegmentPager.h"
#import "UIScrollView+JJExchange.h"

@interface JJSegmentPageView () <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *subControllers;
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation JJSegmentPageView

- (NSMutableArray *)subScrollViews
{
    if (!_subScrollViews) {
        _subScrollViews = [NSMutableArray array];
    }
    return _subScrollViews;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    JJSegmentScrollView *scrollView = [[JJSegmentScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

    scrollView.delegate = self;
    scrollView.bounces = NO;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview:scrollView];
    
    self.scrollView = scrollView;
    
    //防止偏移
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)setSubControllers:(NSArray *)subControllers currentPage:(NSInteger)currentPage
{
    self.subControllers = subControllers;
    self.currentPage = currentPage;
    
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width * subControllers.count, self.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.frame.size.width * currentPage, 0);
    
    [self switchPageViewWithIndex:currentPage];
}

/// Description 更新PageView
/// @param index 当前位置
- (void)switchPageViewWithIndex:(NSInteger)index
{
    [self layoutControllerWithIndex:index];
    [self.scrollView setContentOffset:CGPointMake(self.currentPage * self.frame.size.width, 0) animated:YES];
}

/// Description 布局控件
/// @param index 当前位置
- (void)layoutControllerWithIndex:(NSInteger)index
{
    self.currentPage = index;
    
    UIViewController<JJSegmentDelegate> *pageController = self.subControllers[index];
    
    UIView *pageView = pageController.view;
    
    //如果已经存在，就不再添加
    if ([pageView isDescendantOfView:self.scrollView]) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        pageView.frame = CGRectMake(self.currentPage * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
        
        [self.scrollView insertSubview:pageView atIndex:0];
        
        JJSegmentPager *pager = (JJSegmentPager *)[self getCurrentViewController];
        [pager addChildViewController:pageController];
        
        NSLog(@"添加了：%@", pageController.title);
    
        UIScrollView *scrollView = [self scrollViewInPageController:pageController];
        
        //防止偏移
        if (@available(iOS 11.0, *)) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            pageController.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        if (scrollView) {
            
            [self.subScrollViews addObject:scrollView];
            
            __weak typeof(self) weakSelf = self;
            scrollView.jj_replaceScrollViewDidScrollBlock = ^(UIScrollView * _Nonnull scrollView) {
               
                [weakSelf scrollViewContentOffset:scrollView];
                
            };
        }
    });
}

/// Description 获取当前view所在的viewController
- (UIViewController *)getCurrentViewController
{
    //获取当前view的superView对应的控制器
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

- (void)scrollViewContentOffset:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(jj_segmentPageView_scrollViewDidVerticalScroll:)]) {
        [self.delegate jj_segmentPageView_scrollViewDidVerticalScroll:scrollView];
    }
}

/// Description 获取控制器中的 UIScrollView
/// @param controller controller
- (UIScrollView *)scrollViewInPageController:(UIViewController<JJSegmentDelegate> *)controller
{
    if ([controller respondsToSelector:@selector(jj_segment_obtainScrollView)]) {
        return [controller jj_segment_obtainScrollView];
    } else if ([controller.view isKindOfClass:[UIScrollView class]]) {
        return (UIScrollView *)controller.view;
    } else {
        return nil;
    }
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat x = scrollView.contentOffset.x;
    NSInteger index = x / self.frame.size.width;
    
    [self layoutControllerWithIndex:index];
    
    if ([self.delegate respondsToSelector:@selector(jj_segmentPageView_scrollViewDidEndDecelerating:)]) {
        [self.delegate jj_segmentPageView_scrollViewDidEndDecelerating:index];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(jj_segmentPageView_scrollViewDidHorizontalScroll:)]) {
        [self.delegate jj_segmentPageView_scrollViewDidHorizontalScroll:scrollView];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
