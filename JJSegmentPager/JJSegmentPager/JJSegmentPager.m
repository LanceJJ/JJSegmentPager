//
//  JJSegmentPager.m
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//

#import "JJSegmentPager.h"
#import "JJSegmentBar.h"
#import "JJSegmentScrollView.h"
#import "JJSegmentPageView.h"

@interface JJSegmentPager () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, JJSegmentBarDelegate, JJSegmentPageViewDelegate>

@property (nonatomic, strong) UIScrollView *currentPageScrollView;

@property (nonatomic, strong) JJSegmentPageView *pageView;
@property (nonatomic, strong) JJSegmentBar *segmentBar;

@property (nonatomic, strong) NSMutableArray *pagesArray;

@property (nonatomic, assign) BOOL isMainCanScroll;//主列表是否滚动
@property (nonatomic, assign) BOOL isScrollToOriginal;//是否滚到原点
@property (nonatomic, assign) BOOL isScrollToCeiling;//是否滚到吸顶点
@property (nonatomic, assign) BOOL isBeginDragging;//是否开始拖拽

@end

@implementation JJSegmentPager

- (NSMutableArray *)pagesArray
{
    if (!_pagesArray) {
        _pagesArray = [NSMutableArray array];
    }
    return _pagesArray;
}

- (UIView *)customHeaderView
{
    if (!_customHeaderView) {
        _customHeaderView = [[UIView alloc] init];
    }
    return _customHeaderView;
}

- (UIView *)customFooterView
{
    if (!_customFooterView) {
        _customFooterView = [[UIView alloc] init];
    }
    return _customFooterView;
}

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
    
    [self.pagesArray addObjectsFromArray:self.subControllers];
    
    self.currentPage = (self.currentPage > self.pagesArray.count - 1 || self.currentPage < 0) ? 0 : self.currentPage;
    self.headerHeight = self.headerHeight > 0 ? self.headerHeight : 0.01;
    self.footerHeight = self.footerHeight > 0 ? self.footerHeight : 0;
    self.barHeight = self.barHeight > 0 ? self.barHeight : 0.0001;
    self.segmentMiniTopInset = self.segmentMiniTopInset > 0 ? self.segmentMiniTopInset : 0;
    self.segmentMiniTopInset = self.segmentMiniTopInset > self.headerHeight ? self.headerHeight : self.segmentMiniTopInset;
    
    [self setupBaseConfigs];
}

#pragma mark - private methods

/// Description 初始化默认参数
- (void)setupDefaultParameter
{
    self.enableSegmentBarCeilingScroll = YES;
    self.enableMainVerticalScroll = NO;
    self.enablePageHorizontalScroll = NO;
    self.isMainCanScroll = YES;
    self.needShadow = NO;
    self.needLine = NO;
    self.currentPage = 0;
    self.headerHeight = 0.01;
    self.footerHeight = 0;
    self.barHeight = 44;
    self.barContentInset = UIEdgeInsetsZero;
    self.segmentMiniTopInset = 0;
    self.barBackgroundColor = [UIColor whiteColor];
}

/// Description 初始化控件
- (void)setupBaseConfigs
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([self.view respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.view.preservesSuperviewLayoutMargins = YES;
    }
    self.extendedLayoutIncludesOpaqueBars = NO;
    
    [self setupTableView];
    
    [self setupFooterView];
}

/// Description 初始化表尾
- (void)setupFooterView
{
    [self.view addSubview:self.customFooterView];
    self.customFooterView.clipsToBounds = YES;
    
    self.customFooterView.frame = CGRectMake(0, self.frame.size.height - self.footerHeight, self.view.frame.size.width, self.footerHeight);

}

/// Description 初始化标签按钮承载界面
- (UIView *)setupSegmentView
{
    UIView *segmentBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.barHeight)];
    segmentBarView.backgroundColor = [UIColor whiteColor];
    [segmentBarView addSubview:[self setupSegmentBar]];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.barHeight - 0.7, self.view.frame.size.width, 0.7)];
    line.hidden = !self.needLine;
    line.backgroundColor = self.barLineColor ? self.barLineColor : [UIColor colorWithRed:243.0 / 255.0 green:243.0 / 255.0 blue:243.0 / 255.0 alpha:1];
    [segmentBarView addSubview:line];
    
    if (self.needLine) {
        self.barContentInset = UIEdgeInsetsMake(self.barContentInset.top, self.barContentInset.left, self.barContentInset.bottom + 0.7, self.barContentInset.right);
    }
    
    if (self.needShadow) {
        segmentBarView.layer.shadowOffset = CGSizeMake(0, 0);
        segmentBarView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
        segmentBarView.layer.shadowOpacity = 0.5;
    }
    
    return segmentBarView;
}

/// Description 初始化JJSegmentPageView
- (UIView *)setupPageView
{
    JJSegmentPageView *pageView = [[JJSegmentPageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.frame.size.height - self.segmentMiniTopInset - self.barHeight - self.footerHeight)];
    pageView.delegate = self;
    pageView.scrollView.scrollEnabled = self.enablePageHorizontalScroll;
    [pageView setPagesArray:self.pagesArray currentPage:self.currentPage];
    
    self.pageView = pageView;
    
    return pageView;
}

/// Description 初始化JJSegmentBar
- (UIView *)setupSegmentBar
{
    if (self.customBarView) {
        self.customBarView.frame = [self segmentBarRect];
        return self.customBarView;
    } else {
        NSMutableArray *titles = [NSMutableArray array];
        
        for (UIViewController *controller in self.pagesArray) {
            
            [titles addObject:controller.title == nil ? @"--" : controller.title];
        }
        
        //创建
        JJSegmentBar *segmentBar = [[JJSegmentBar alloc] initWithFrame:[self segmentBarRect]];
        
        segmentBar.delegate = self;
        segmentBar.titles = titles;
        segmentBar.backgroundColor = self.barBackgroundColor;
        segmentBar.indicatorColor = self.barIndicatorColor;
        segmentBar.normalColor = self.barNormalColor;
        segmentBar.selectColor = self.barSelectColor;
        segmentBar.normalFont = self.barNormalFont;
        segmentBar.selectFont = self.barSelectFont;
        segmentBar.currentPage = self.currentPage;
        segmentBar.indicatorHeight = self.barIndicatorHeight;
        segmentBar.indicatorWidth = self.barIndicatorWidth;
        segmentBar.indicatorCornerRadius = self.barIndicatorCornerRadius;

        //设置标签底部指示器宽度类型
        segmentBar.indicatorType = self.barIndicatorType == JJBarIndicatorSameWidthType ? JJIndicatorSameWidthType : JJIndicatorAutoWidthType;
        
        //设置标签按钮宽度类型
        if (self.barSegmentBtnWidthType == JJBarSegmentBtnAutoWidthType1) {
            segmentBar.segmentBtnType = JJSegmentBtnAutoWidthType1;
        } else if (self.barSegmentBtnWidthType == JJBarSegmentBtnAutoWidthType2) {
            segmentBar.segmentBtnType = JJSegmentBtnAutoWidthType2;
        }
        
        [segmentBar setupConfigureAppearance];
        
        self.segmentBar = segmentBar;
        
        return segmentBar;
    }
}

- (void)setupTableView
{
    JJSegmentTableView *mainTableView = [[JJSegmentTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.frame.size.height - self.footerHeight) style:UITableViewStyleGrouped];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.sectionHeaderHeight = 0.01;
    mainTableView.sectionFooterHeight = 0.01;
    mainTableView.backgroundColor = [UIColor whiteColor];
    mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    mainTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:mainTableView];
    
    _mainTableView = mainTableView;
    
    mainTableView.tableHeaderView = self.customHeaderView;
    
    UIView *headerView = mainTableView.tableHeaderView;
    headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.headerHeight);
    mainTableView.tableHeaderView = headerView;
    
    mainTableView.tableHeaderView.hidden = self.headerHeight == 0.01;
    
    if (@available(iOS 11.0, *)) {
        self.mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

#pragma mark table 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];

    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.hidden = YES;//适配iOS14
        
        [cell addSubview:[self setupPageView]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.frame.size.height - self.segmentMiniTopInset - self.barHeight - self.footerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.barHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"sectionHeader"];
    
    if (headerView == nil) {
        
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"sectionHeader"];
        
        [headerView addSubview:[self setupSegmentView]];
    
    }
    return headerView;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isBeginDragging = YES;
    self.isScrollToOriginal = NO;
    self.isScrollToCeiling = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        self.isBeginDragging = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isBeginDragging = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.isScrollToOriginal = NO;
    self.isScrollToCeiling = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //不允许主列表上下滑动改变表头偏移量
    if (self.enableMainVerticalScroll == NO) {
        scrollView.contentOffset = CGPointZero;
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(jj_segment_scrollViewDidVerticalScroll:)]) {
        [self.delegate jj_segment_scrollViewDidVerticalScroll:scrollView];
    }
    
    if (self.jj_segment_scrollViewDidVerticalScrollBlock) {
        self.jj_segment_scrollViewDidVerticalScrollBlock(scrollView);
    }
    
    //手动回到原点或吸顶点，不继续处理
    if (self.isScrollToOriginal || self.isScrollToCeiling) return;
    
    //不是手动拖拽，点击状态栏时滑动
    if (self.isBeginDragging == NO) {
    
        self.isMainCanScroll = YES;
        self.isScrollToOriginal = YES;
        
        for (UIScrollView *scrollView in self.pageView.subScrollViews) {
            if ([scrollView isKindOfClass:[UIScrollView class]]) {
                [scrollView setContentOffset:CGPointZero animated:YES];
            }
        }
        return;
    }
    
    CGFloat offsetY = scrollView.contentOffset.y;

    //吸顶点
    CGFloat ceilingPoint = [self.mainTableView rectForSection:0].origin.y - self.segmentMiniTopInset;
    
    //上滑到吸顶点后，固定其位置
    if (offsetY >= ceilingPoint) {

        scrollView.contentOffset = CGPointMake(0, ceilingPoint);
        self.isMainCanScroll = NO;//主列表固定位置，不可以滚动
        
    //主列表下滑到偏移量<0时
    } else if (offsetY < 0) {
        
        //如果不允许主列表下拉刷新，固定主列表的位置
        if (self.enableMainRefreshScroll == NO) {
            scrollView.contentOffset = CGPointZero;
        //如果允许主列表下拉刷新，不用固定位置
        } else {
            //子列表下滑过程中，但偏移量>0时，并且self.headerHeight == self.segmentMiniTopInset，固定位置
            if (self.currentPageScrollView.contentOffset.y > 0 && self.headerHeight == self.segmentMiniTopInset) {
                scrollView.contentOffset = CGPointZero;
            }
        }
    //主列表下滑偏移量>0时
    } else {
        
        // 主列表不可以滚动时，固定位置
        if (self.isMainCanScroll == NO) {
            scrollView.contentOffset = CGPointMake(0, ceilingPoint);
        }
    }
}

#pragma mark - JJSegmentPageViewDelegate

- (void)jj_segmentPageView_scrollViewDidVerticalScroll:(UIScrollView *)scrollView
{
    //不允许主列表上下滑动改变表头偏移量
    if (self.enableMainVerticalScroll == NO) return;
    
    //手动回到原点或吸顶点，不继续处理
    if (self.isScrollToOriginal || self.isScrollToCeiling) return;
    
    self.currentPageScrollView = scrollView;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    //主列表不可以滚动时
    if (self.isMainCanScroll == NO) {
        
        //当子列表下滑到偏移量<0时，并且enableSegmentBarCeilingScroll为允许时，让主列表跟随滑动，此时主列表可以滑动
        if (offsetY <= 0 && self.enableSegmentBarCeilingScroll == YES) {
            self.isMainCanScroll = YES;//主列表跟随滚动，可以滚动
        }
        
    //主列表可以滚动时
    } else {

        if ((self.enableMainRefreshScroll == NO) && self.mainTableView.contentOffset.y <= 0) {

        } else {
            scrollView.contentOffset = CGPointZero;
        }
    }
}

- (void)jj_segmentPageView_scrollViewDidEndDecelerating:(NSInteger)index
{
    if (!self.customBarView) {
        [self.segmentBar switchBtnWithCurrentPage:index];
    }
    
    if ([self.delegate respondsToSelector:@selector(jj_segment_scrollViewDidEndDecelerating:)]) {
        [self.delegate jj_segment_scrollViewDidEndDecelerating:index];
    }
    
    if (self.jj_segment_scrollViewDidEndDeceleratingBlock) {
        self.jj_segment_scrollViewDidEndDeceleratingBlock(index);
    }
}

- (void)jj_segmentPageView_scrollViewDidHorizontalScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(jj_segment_scrollViewDidHorizontalScroll:)]) {
        [self.delegate jj_segment_scrollViewDidHorizontalScroll:scrollView];
    }
    
    if (self.jj_segment_scrollViewDidHorizontalScrollBlock) {
        self.jj_segment_scrollViewDidHorizontalScrollBlock(scrollView);
    }
}

#pragma mark JJSegmentBarDelegate

- (void)jj_segmentBar_didSelected:(NSInteger)index
{
    [self.pageView switchPageViewWithIndex:index];
    
    if ([self.delegate respondsToSelector:@selector(jj_segment_didSelected:)]) {
        [self.delegate jj_segment_didSelected:index];
    }
    
    if (self.jj_segment_didSelectedBlock) {
        self.jj_segment_didSelectedBlock(index);
    }
}

/// Description 重新计算SegmentBar的尺寸
- (CGRect)segmentBarRect
{
    CGFloat top = self.barContentInset.top;
    CGFloat left = self.barContentInset.left;
    CGFloat bottom = self.barContentInset.bottom;
    CGFloat right = self.barContentInset.right;
    
    return CGRectMake(0 + left, 0 + top, self.view.frame.size.width - left - right, self.barHeight - top - bottom);
}

#pragma mark - public methods

/// Description 添加父控制器
/// @param viewController 控制器
- (void)addParentController:(UIViewController *)viewController
{
    self.frame = CGRectEqualToRect(self.frame, CGRectZero) || CGRectEqualToRect(self.frame, CGRectNull) ? CGRectMake(0, 0, viewController.view.frame.size.width, viewController.view.frame.size.height) : self.frame;

    viewController.automaticallyAdjustsScrollViewInsets = NO;
    [viewController.view addSubview:self.view];
    [viewController addChildViewController:self];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.view.frame = self.frame;
    });
}

/// Description 添加子控制器(需要设置title)，初始化之后，动态添加
/// @param viewController 控制器
- (void)addSubController:(UIViewController *)viewController
{
    //添加
    [self.pagesArray addObject:viewController];
    
    //跳转
    self.currentPage = self.pagesArray.count - 1;
    [self.pageView setPagesArray:self.pagesArray currentPage:self.currentPage];
    
    //如果不是自定义标签按钮，进行重置
    if (!self.customBarView) {
        //重置
        NSMutableArray *titles = [NSMutableArray array];
        
        for (UIViewController *controller in self.pagesArray) {
            
            [titles addObject:controller.title == nil ? @"--" : controller.title];
        }
        
        self.segmentBar.titles = titles;
        self.segmentBar.currentPage = self.currentPage;
        
        [self.segmentBar setupConfigureAppearance];
    }
}

/// Description 切换pageView
/// @param index 当前位置
- (void)switchPageViewWithIndex:(NSInteger)index
{
    [self.pageView switchPageViewWithIndex:index];
}

/// Description 滚动到原点
- (void)scrollToOriginalPoint
{
    self.isMainCanScroll = YES;
    self.isScrollToOriginal = YES;
    
    [self.mainTableView setContentOffset:CGPointZero animated:YES];
    
    for (UIScrollView *scrollView in self.pageView.subScrollViews) {
        if ([scrollView isKindOfClass:[UIScrollView class]]) {
            [scrollView setContentOffset:CGPointZero animated:YES];
        }
    }
}

/// Description 滚动到吸顶点
- (void)scrollToCeilingPoint
{
    self.isMainCanScroll = NO;
    self.isScrollToCeiling = YES;
    
    CGFloat criticalPoint = [self.mainTableView rectForSection:0].origin.y - self.segmentMiniTopInset;
    
    [self.mainTableView setContentOffset:CGPointMake(0, criticalPoint) animated:YES];
}

/// Description 更新表头高度
/// @param height 高度
- (void)updateHeaderHeight:(CGFloat)height
{
    self.headerHeight = height;

    UIView *headerView = self.mainTableView.tableHeaderView;
    headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.headerHeight);
    self.mainTableView.tableHeaderView = headerView;
    
    self.mainTableView.tableHeaderView.hidden = self.headerHeight == 0.01;
}

- (void)dealloc
{
    NSLog(@"控制器销毁了");
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
