//
//  JJSegmentPager.m
//  JJSegmentPager
//
//  Created by Lance on 2018/4/27.
//  Copyright © 2018年 Lance. All rights reserved.
//

#import "JJSegmentPager.h"
#import "JJSegmentBar.h"
#import "JJSegmentHeader.h"
#import "JJSegmentScrollView.h"
#import "UIScrollView+JJRuntime.h"

#define JJ_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


typedef void(^UpdateSegmentTopInsetBlock)(CGFloat top);
typedef void(^SelectSegmentBarBlock)(NSInteger index);
typedef void(^ScrollViewDidEndDeceleratingBlock)(NSInteger currentPage);

const void *_JJSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWOFFSET = &_JJSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWOFFSET;
const void *_JJSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWINSET = &_JJSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWINSET;

@interface JJSegmentPager () <UIScrollViewDelegate>

@property (nonatomic, copy) UpdateSegmentTopInsetBlock updateSegmentTopInsetBlock;
@property (nonatomic, copy) SelectSegmentBarBlock selectSegmentBarBlock;
@property (nonatomic, copy) ScrollViewDidEndDeceleratingBlock scrollViewDidEndDeceleratingBlock;
@property (nonatomic, strong) JJSegmentBar *segmentBar;
@property (nonatomic, strong) JJSegmentScrollView *groundScrollView;//继承自定义ScrollView 防止控制器侧滑返回与ScrollView左右滑动产生冲突
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *segmentBarView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIScrollView *rootScrollView;
@property (nonatomic, strong) NSHashTable *hasShownControllers;
@property (nonatomic, assign) CGFloat segmentTopInset;
@property (nonatomic, assign) CGFloat originalTopInset;
@property (nonatomic, assign) CGFloat navTabBarHeight;
@property (nonatomic, assign) CGFloat bottomInset;
@property (nonatomic, assign) CGFloat currentOffsetY;
@property (nonatomic, assign) BOOL ignoreOffsetChanged;

@property (nonatomic, strong) NSLayoutConstraint *headerHeightCos;
@property (nonatomic, strong) NSLayoutConstraint *headerTopCos;

@end

@implementation JJSegmentPager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupDefaultParameter];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.subControllers.count == 0 || self.subControllers == nil) return;
    
    self.currentPage = (self.currentPage > self.subControllers.count - 1 || self.currentPage < 0) ? 0 : self.currentPage;
    self.ignoreOffsetChanged = !self.enableOffsetChanged;
    self.segmentTopInset = self.headerHeight;
    
    [self setupBaseConfigs];
}

#pragma mark - private methods

/**
 Description 初始化默认参数
 */
- (void)setupDefaultParameter
{
    self.needShadow = NO;
    self.ignoreOffsetChanged = YES;
    self.enableScrollViewDrag = NO;
    self.currentPage = 0;
    self.headerHeight = 0;
    self.footerHeight = 0;
    self.bottomInset = 0;
    self.segmentHeight = 44;
    self.barContentInset = UIEdgeInsetsZero;
    self.segmentTopInset = 0;
    self.segmentMiniTopInset = 0;
    self.hasShownControllers = [NSHashTable weakObjectsHashTable];
    self.barBackgroundColor = [UIColor whiteColor];
}

/**
 Description 初始化控件
 */
- (void)setupBaseConfigs
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([self.view respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.view.preservesSuperviewLayoutMargins = YES;
    }
    self.extendedLayoutIncludesOpaqueBars = NO;
    
    [self setupGroundScrollView];
    
    [self setupHeaderView];
    
    [self setupSegmentView];
    
    [self setupFooterView];
    
    [self updateCurrentControllerWithIndex:self.currentPage];
}

/**
 Description 初始化groundScrollView
 */
- (void)setupGroundScrollView
{
    self.rootScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_rootScrollView];
    
    //防止偏移
    if (@available(iOS 11.0, *)) {
        self.rootScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.groundScrollView = [[JJSegmentScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.navTabBarHeight)];
    self.groundScrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.subControllers.count, 0);
    self.groundScrollView.contentOffset = CGPointMake(self.view.frame.size.width * self.currentPage, 0);
    self.groundScrollView.backgroundColor = [UIColor whiteColor];
    self.groundScrollView.delegate = self;
    self.groundScrollView.tag = 100;
    self.groundScrollView.bounces = NO;
    self.groundScrollView.pagingEnabled = YES;
    self.groundScrollView.scrollEnabled = self.enableScrollViewDrag;
    self.groundScrollView.showsHorizontalScrollIndicator = NO;
    [self.rootScrollView addSubview:_groundScrollView];
    
    //防止偏移
    if (@available(iOS 11.0, *)) {
        self.groundScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

/**
 Description 初始化表头
 */
- (void)setupHeaderView
{
    self.headerView = [self defaultHeaderView];
//    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.headerHeight);

    self.headerView.clipsToBounds = YES;
    [self.rootScrollView addSubview:_headerView];
    
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    //高度约束
    NSLayoutConstraint *headerHeightCos = [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:self.headerHeight];

    [self.headerView addConstraint:headerHeightCos];
    self.headerHeightCos = headerHeightCos;

    //顶部约束
    NSLayoutConstraint *headerTopCos = [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];

    [self.view addConstraint:headerTopCos];
    self.headerTopCos = headerTopCos;

    //左边约束
    NSLayoutConstraint *headerLeftCos = [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];

    [self.view addConstraint:headerLeftCos];

    //右边约束
    NSLayoutConstraint *headerRightCos = [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];

    [self.view addConstraint:headerRightCos];
}

/**
 Description 初始化表尾
 */
- (void)setupFooterView
{
    self.footerView = [self defaultFooterView];
//    self.footerView.frame = CGRectMake(0, JJ_SCREEN_HEIGHT - self.navTabBarHeight - self.footerHeight, self.view.frame.size.width, self.footerHeight);
    self.footerView.clipsToBounds = YES;
    [self.rootScrollView addSubview:_footerView];
    
    self.footerView.translatesAutoresizingMaskIntoConstraints = NO;
    //高度约束
    NSLayoutConstraint *footerHeightCos = [NSLayoutConstraint constraintWithItem:self.footerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:self.footerHeight];
    
    [self.footerView addConstraint:footerHeightCos];
 
    //底部约束
    NSLayoutConstraint *footerBottomCos = [NSLayoutConstraint constraintWithItem:self.footerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    
    [self.view addConstraint:footerBottomCos];
    
    //左边约束
    NSLayoutConstraint *footerLeftCos = [NSLayoutConstraint constraintWithItem:self.footerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    
    [self.view addConstraint:footerLeftCos];
    
    //右边约束
    NSLayoutConstraint *footerRightCos = [NSLayoutConstraint constraintWithItem:self.footerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    [self.view addConstraint:footerRightCos];
}

/**
 Description 初始化按钮
 */
- (void)setupSegmentView
{
    self.segmentBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerHeight, self.view.frame.size.width, self.segmentHeight)];
    self.segmentBarView.backgroundColor = [UIColor whiteColor];
    
    [self.rootScrollView addSubview:_segmentBarView];
    [self.segmentBarView addSubview:[self defaultBarView]];
    
    //设置阴影
    if (!self.needShadow) return;
    
    self.segmentBarView.layer.shadowOffset = CGSizeMake(0, 0);
    self.segmentBarView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
    self.segmentBarView.layer.shadowOpacity = 0.5;
}

/**
 Description 默认表头
 
 @return JJSegmentHeader
 */
- (UIView *)defaultHeaderView
{
    if (self.customHeaderView) return self.customHeaderView;
    
    return [[JJSegmentHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.headerHeight)];
}

/**
 Description 默认表尾
 
 @return UIView
 */
- (UIView *)defaultFooterView
{
    if (self.customFooterView) return self.customFooterView;
    
    return [[UIView alloc] initWithFrame:CGRectMake(0, JJ_SCREEN_HEIGHT - self.navTabBarHeight - self.footerHeight, self.view.frame.size.width, self.footerHeight)];
}

/**
 Description 默认标签按钮
 
 @return JJSegmentBar
 */
- (UIView *)defaultBarView
{
    if (self.customBarView) {
        
        self.customBarView.frame = [self segmentBarRect];
        return self.customBarView;
    }
    
    return [self setupSegmentBar];
}


/**
 Description 初始化JJSegmentBar
 
 @return JJSegmentBar
 */
- (UIView *)setupSegmentBar
{
    NSMutableArray *titles = [NSMutableArray array];
    
    for (UIViewController *controller in self.subControllers) {
        
        [titles addObject:controller.title == nil ? @"--" : controller.title];
    }
    
    //创建
    self.segmentBar = [[JJSegmentBar alloc] initWithFrame:[self segmentBarRect]];
    
    self.segmentBar.titles = titles;
    self.segmentBar.backgroundColor = self.barBackgroundColor;
    self.segmentBar.highlightBackgroundColor = self.barHighlightBackgroundColor;
    self.segmentBar.indicatorColor = self.barIndicatorColor;
    self.segmentBar.normalColor = self.barNormalColor;
    self.segmentBar.selectColor = self.barSelectColor;
    self.segmentBar.normalFont = self.barNormalFont;
    self.segmentBar.selectFont = self.barSelectFont;
    self.segmentBar.currentPage = self.currentPage;
    self.segmentBar.indicatorHeight = self.barIndicatorHeight;
    self.segmentBar.indicatorWidth = self.barIndicatorWidth;
    self.segmentBar.indicatorCornerRadius = self.barIndicatorCornerRadius;
    
    //按钮点击回调
    __weak typeof(self) vc = self;
    [self.segmentBar selectedBlock:^(JJSegmentBtn *button) {
        
        NSLog(@"%ld", (long)button.tag);
        [vc segmentDidSelectedValue:button.tag];
        
        if (vc.selectSegmentBarBlock) {
            vc.selectSegmentBarBlock(button.tag);
        }
    }];
    
    //设置标签底部指示器宽度类型
    self.segmentBar.indicatorType = self.barIndicatorType == JJBarIndicatorSameWidthType ? JJIndicatorSameWidthType : JJIndicatorAutoWidthType;
    
    //设置标签按钮宽度类型
    if (self.barSegmentBtnWidthType == JJBarSegmentBtnSameWidthType) {
        self.segmentBar.segmentBtnType = JJSegmentBtnSameWidthType;
    } else if (self.barSegmentBtnWidthType == JJBarSegmentBtnAutoWidthType1) {
        self.segmentBar.segmentBtnType = JJSegmentBtnAutoWidthType1;
    } else if (self.barSegmentBtnWidthType == JJBarSegmentBtnAutoWidthType2) {
        self.segmentBar.segmentBtnType = JJSegmentBtnAutoWidthType2;
    }
    
    [self.segmentBar setupConfigureAppearance];
    
    return self.segmentBar;
}

/**
 Description 重新计算SegmentBar的尺寸
 
 @return CGRect
 */
- (CGRect)segmentBarRect
{
    CGFloat top = self.barContentInset.top;
    CGFloat left = self.barContentInset.left;
    CGFloat bottom = self.barContentInset.bottom;
    CGFloat right = self.barContentInset.right;
    
    return CGRectMake(0 + left, 0 + top, self.view.frame.size.width - left - right, self.segmentHeight - top - bottom);
}

/**
 Description 布局控件
 
 @param pageController 控制器
 */
- (void)layoutControllerWithController:(UIViewController<JJSegmentDelegate> *)pageController
{
    UIView *pageView = pageController.view;
    
    //如果已经存在，就不再添加
    if ([pageView isDescendantOfView:self.groundScrollView]) return;
    
    [self.groundScrollView insertSubview:pageView atIndex:0];
    [self addChildViewController:pageController];
    
    NSLog(@"添加了：%@", pageController.title);
    
//    NSLog(@"%f", [UIScreen mainScreen].bounds.size.height);
    
    pageView.frame = CGRectMake(self.currentPage * self.view.frame.size.width, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - self.navTabBarHeight - self.footerHeight);
    
    UIScrollView *scrollView = [self scrollViewInPageController:pageController];
    
    //防止偏移
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        pageController.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    if (scrollView) {
        
        scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - self.navTabBarHeight - self.footerHeight);
        
        scrollView.alwaysBounceVertical = YES;
        self.originalTopInset = self.headerHeight + self.segmentHeight;

        CGFloat bottomInset = self.bottomInset;
        
        [scrollView setContentInset:UIEdgeInsetsMake(self.originalTopInset, 0, bottomInset, 0)];
        [scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(self.originalTopInset, 0, bottomInset, 0)];
    
        if (![self.hasShownControllers containsObject:pageController]) {
            [self.hasShownControllers addObject:pageController];

            [scrollView setContentOffset:CGPointMake(0, -self.segmentTopInset - self.segmentHeight)];
        }
        
        self.currentOffsetY = -self.segmentTopInset - self.segmentHeight;
        
        if (self.enableOffsetChanged) {
            
            CGFloat screenH = JJ_SCREEN_HEIGHT - self.navTabBarHeight - self.segmentMiniTopInset - self.segmentHeight - self.footerHeight;
            
            scrollView.minContentSizeHeight = screenH;
            
            if (scrollView.contentSize.height < screenH) {
                scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, screenH);
            }
        }
        
    } else {
        
        pageView.frame = CGRectMake(self.currentPage * self.view.frame.size.width, self.segmentHeight + self.headerHeight, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - (self.segmentHeight + self.headerHeight) - self.navTabBarHeight - self.footerHeight - self.bottomInset);
    }
}

/**
 Description 获取控制器中的 UIScrollView
 
 @param controller controller
 @return UIScrollView
 */
- (UIScrollView *)scrollViewInPageController:(UIViewController<JJSegmentDelegate> *)controller
{
    if ([controller respondsToSelector:@selector(streachScrollView)]) {
        return [controller streachScrollView];
    } else if ([controller.view isKindOfClass:[UIScrollView class]]) {
        return (UIScrollView *)controller.view;
    } else {
        return nil;
    }
}

#pragma mark - add / remove obsever for page scrollView
- (void)addObserverForPageController:(UIViewController<JJSegmentDelegate> *)controller
{
    UIScrollView *scrollView = [self scrollViewInPageController:controller];
    if (scrollView != nil) {
        [scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&_JJSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWOFFSET];
        [scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentInset)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&_JJSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWINSET];
    }
}

- (void)removeObseverForPageController:(UIViewController<JJSegmentDelegate> *)controller
{
    UIScrollView *scrollView = [self scrollViewInPageController:controller];
    if (scrollView != nil) {
        @try {
            [scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
            [scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentInset))];
        } @catch (NSException *exception) {
            NSLog(@"exception is %@", exception);
        } @finally {
        }
    }
}

#pragma mark - obsever delegate methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //当表头高度为0时,不需要执行以下方法
    if (self.headerHeight == 0) return;
    //segmentMiniTopInset不可大于headerHeight
    if (self.segmentMiniTopInset > self.headerHeight) self.segmentMiniTopInset = self.headerHeight;
    
    if (context == _JJSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWOFFSET &&
        !_ignoreOffsetChanged) {
        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
        CGFloat offsetY = offset.y;
        CGPoint oldOffset = [change[NSKeyValueChangeOldKey] CGPointValue];
        CGFloat oldOffsetY = oldOffset.y;
        CGFloat deltaOfOffsetY = offset.y - oldOffsetY;
        CGFloat offsetYWithSegment = offset.y + self.segmentHeight;
        
        NSLog(@"%f", offsetY);
        NSLog(@"%f", oldOffsetY);
        NSLog(@"++++++%f", deltaOfOffsetY);

        if (deltaOfOffsetY > 0 &&
            offsetY >= -(self.headerHeight + self.segmentHeight)) {
            // 当滑动是向上滑动时且不是回弹
            // 跟随移动的偏移量进行变化
            // NOTE:直接相减有可能constant会变成负数，进而被系统强行移除，导致header悬停的位置错乱或者crash
            if (self.segmentTopInset - deltaOfOffsetY <= 0) {
                self.segmentTopInset = self.segmentMiniTopInset;
            } else {
                self.segmentTopInset -= deltaOfOffsetY;
            }
            // 如果到达顶部固定区域，那么不继续滑动
            if (self.segmentTopInset <= self.segmentMiniTopInset) {
                self.segmentTopInset = self.segmentMiniTopInset;
            }
        } else {
            // 当向下滑动时
            // 如果列表已经滚动到屏幕上方
            // 那么保持顶部栏在顶部
            if (offsetY > 0) {
                if (self.segmentTopInset <= self.segmentMiniTopInset) {
                    self.segmentTopInset = self.segmentMiniTopInset;
                }
            } else {
                
                // 如果列表顶部已经进入屏幕
                // 如果顶部栏已经到达底部
                if (self.segmentTopInset >= self.headerHeight) {
                    // 如果当前列表滚到了顶部栏的底部
                    // 那么顶部栏继续跟随变大，否这保持不变
                    if (-offsetYWithSegment > self.headerHeight &&
                        self.enableMaxHeaderHeight) {
                        self.segmentTopInset = -offsetYWithSegment;
                    } else {
                        self.segmentTopInset = self.headerHeight;
                    }
                } else {
                    // 在顶部拦未到达底部的情况下
                    // 如果列表还没滚动到顶部栏底部，那么什么都不做
                    // 如果已经到达顶部栏底部，那么顶部栏跟随滚动
                    
                    if (self.segmentTopInset < -offsetYWithSegment) {
                        self.segmentTopInset -= deltaOfOffsetY;
                    }
                }
            }
        }
        
//        NSLog(@"------%f", self.segmentTopInset);
        
        if (self.segmentTopInset <= self.headerHeight || self.enableMaxHeaderHeight) {

            self.segmentBarView.frame = CGRectMake(0, self.segmentTopInset, self.view.frame.size.width, self.segmentHeight);
            
            if (self.headerViewChangeType == JJHeaderViewSizeChangeType) {//改变尺寸

                self.headerHeightCos.constant = self.segmentTopInset;
            
            } else if (self.headerViewChangeType == JJHeaderViewPositionChangeType) {//改变位置

                self.headerTopCos.constant = self.segmentTopInset - self.headerHeight;
            }
        }
    
    } else if (context == _JJSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWINSET) {
        UIEdgeInsets insets = [object contentInset];
        if (fabs(insets.top - _originalTopInset) < 2) {
            self.ignoreOffsetChanged = !self.enableOffsetChanged;
        } else {
            self.ignoreOffsetChanged = YES;
        }
    }
    
    //保证侧滑切换页面时,即将出现的ScrollView显示正确位置
    if (self.segmentTopInset >= 0 && self.enableScrollViewDrag && self.enableOffsetChanged) {
        
        for (UIViewController<JJSegmentDelegate> *controller in self.subControllers) {
            
            if (![self.currentDisplayController isEqual:controller]) {
                
                UIScrollView *otherScrollView = [self scrollViewInPageController:controller];
                
                if (otherScrollView.contentOffset.y <= -self.segmentHeight) {
                    
                    otherScrollView.contentOffset = CGPointMake(0, -self.segmentHeight - self.segmentTopInset);
                }
            }
        }
    }
    
    //segmentTopInset回调
    if (self.updateSegmentTopInsetBlock && self.enableOffsetChanged) {
        self.updateSegmentTopInsetBlock(self.segmentTopInset);
    }
}

/**
 Description 按钮点击方法
 
 @param index 当前点击位置
 */
- (void)segmentDidSelectedValue:(NSInteger)index
{
    [self updateCurrentControllerWithIndex:index];
    [self.groundScrollView setContentOffset:CGPointMake(self.currentPage * self.view.frame.size.width, 0) animated:YES];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == 100) {
        
        CGFloat x = scrollView.contentOffset.x;
        NSInteger index = x / self.view.frame.size.width;
        
        [self.segmentBar switchBtnWithCurrentPage:index];
        
        if (self.scrollViewDidEndDeceleratingBlock) {
            self.scrollViewDidEndDeceleratingBlock(index);
        }
        //如果有自定义的标签按钮，更新界面，如果是默认的标签按钮，则直接返回
        if (!self.customBarView) return;
        
        [self segmentDidSelectedValue:index];
    }
}

/**
 Description 更新当前控制器
 
 @param index 当前位置
 */
- (void)updateCurrentControllerWithIndex:(NSInteger)index
{
    //移除
    [self removeObseverForPageController:self.currentDisplayController];
    
    UIViewController<JJSegmentDelegate> *controller = self.subControllers[index];
    
    self.currentPage = index;
    self.currentDisplayController = controller;
    
    //添加当前控制器
    [self layoutControllerWithController:controller];
    
    UIScrollView *scrollView = [self scrollViewInPageController:controller];

    //更新当前scrollView偏移量
    if (self.segmentTopInset != self.headerHeight) {

        if (scrollView.contentOffset.y >= -(self.segmentTopInset + self.headerHeight) && scrollView.contentOffset.y <= -self.segmentHeight) {
            [scrollView setContentOffset:CGPointMake( 0, -self.segmentHeight - self.segmentTopInset) animated:NO];
        }
    }
    //保存当前scrollView偏移量
    self.currentOffsetY = -(self.segmentTopInset + self.segmentHeight);
    //添加
    [self addObserverForPageController:controller];
    [scrollView setContentOffset:scrollView.contentOffset animated:YES];
    
}

#pragma mark - public methods

/**
 Description 添加父控制器
 
 @param viewController 控制器
 */
- (void)addParentController:(UIViewController *)viewController
{
    CGFloat navH = kNavHeight;
    
    self.navTabBarHeight = viewController.navigationController.navigationBar.translucent == YES ? 0 : navH;
    self.navTabBarHeight = viewController.navigationController.navigationBar.hidden == YES || viewController.navigationController.navigationBarHidden == YES ? 0 : self.navTabBarHeight;
    
    if (viewController.navigationController.viewControllers.count == 0 || viewController.navigationController ==  nil) {
        self.bottomInset = 0;
    } else if ([viewController.navigationController.viewControllers.firstObject isKindOfClass:[viewController class]]){
        self.bottomInset = viewController.tabBarController.tabBar.frame.size.height;
    }
    
    viewController.automaticallyAdjustsScrollViewInsets = NO;
    [viewController.view addSubview:self.view];
    [viewController addChildViewController:self];
}

#pragma mark - block methods

/**
 Description 列表滑动过程中偏移量数值回调（当自定义表头时,回调此偏移量,以供外界自定义表头使用）
 
 @param block block description
 */
- (void)updateSegmentTopInsetBlock:(void (^)(CGFloat))block
{
    if (block) {
        self.updateSegmentTopInsetBlock = block;
    }
}

/**
 Description 按钮点击回调
 
 @param block 按钮索引
 */
- (void)selectedSegmentBarBlock:(void (^)(NSInteger))block
{
    if (block) {
        self.selectSegmentBarBlock = block;
    }
}

/**
 Description scrollViewDidEndDecelerating代理回调
 
 @param block 当前页面位置
 */
- (void)scrollViewDidEndDeceleratingBlock:(void (^)(NSInteger))block
{
    if (block) {
        self.scrollViewDidEndDeceleratingBlock = block;
    }
}

/**
 Description 重新布局界面
 */
- (void)reloadViews
{
    UIScrollView *scrollView = [self scrollViewInPageController:self.currentDisplayController];
    
    if (scrollView.contentOffset.y <= -self.segmentHeight) {
        
        scrollView.contentOffset = CGPointMake(0, -self.segmentTopInset - self.segmentHeight);
        
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (self.headerViewChangeType == JJHeaderViewSizeChangeType) {//改变尺寸
            
            self.headerHeightCos.constant = self.segmentTopInset;
            
        } else if (self.headerViewChangeType == JJHeaderViewPositionChangeType) {//改变位置
            
            self.headerTopCos.constant = self.segmentTopInset - self.headerHeight;
        }
    });
}

/**
 Description 更新表头高度
 
 @param height 高度
 */
- (void)updateHeaderHeight:(CGFloat)height
{
    self.headerHeight = height;
    
    for (UIViewController<JJSegmentDelegate> *controller in self.subControllers) {
        
        
        UIScrollView *scrollView = [self scrollViewInPageController:controller];
        
        if (scrollView) {
            
            self.originalTopInset = self.headerHeight + self.segmentHeight;
            
            CGFloat bottomInset = self.bottomInset;
            
            [scrollView setContentInset:UIEdgeInsetsMake(self.originalTopInset, 0, bottomInset, 0)];
            [scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(self.originalTopInset, 0, bottomInset, 0)];
            
            if (![self.hasShownControllers containsObject:controller]) {
                [self.hasShownControllers addObject:controller];
                
                [scrollView setContentOffset:CGPointMake(0, -self.segmentTopInset - self.segmentHeight)];
                
                NSLog(@"%f", scrollView.contentOffset.y);
            }
        }
    }
    
    [self.headerView setNeedsLayout];
    [self.headerView layoutSubviews];
    [self.headerView layoutIfNeeded];
}


- (void)dealloc
{
    NSLog(@"控制器销毁了");
    [self removeObseverForPageController:self.currentDisplayController];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
