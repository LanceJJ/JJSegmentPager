//
//  JJCustomBarViewController.m
//  JJSegmentPager
//
//  Created by Lance on 2018/4/27.
//  Copyright © 2018年 Lance. All rights reserved.
//

#import "JJCustomBarViewController.h"
#import "JJTableViewController.h"
#import "JJSegmentPager.h"
#import "JJCustomHeader.h"
#import "JJNavigationView.h"


@interface JJCustomBarViewController () <JJSegmentDelegate>

@property (nonatomic, strong) JJNavigationView *navView;
@property (nonatomic, strong) JJSegmentPager *pager;
@property (nonatomic, strong) UISegmentedControl *segmentControl;

@end

@implementation JJCustomBarViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupSegmentPager];
    
    JJNavigationView *navView = [[[NSBundle mainBundle] loadNibNamed:@"JJNavigationView" owner:self options:nil] lastObject];
    navView.frame = CGRectMake(0, 0, self.view.frame.size.width, kNavHeight);
    navView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    navView.title = self.title;
    [self.view addSubview:navView];
    self.navView = navView;
    
    __weak typeof(self) vc = self;
    navView.backBlock = ^{
        [vc.navigationController popViewControllerAnimated:YES];
    };
}

- (void)setupSegmentPager
{
    //自定义表头
    JJCustomHeader *headerView = [[[NSBundle mainBundle] loadNibNamed:@"JJCustomHeader" owner:self options:nil] lastObject];
    
    //自定义标签按钮
    NSArray *segmentedArray = @[@"第一个", @"第二个", @"第三个"];
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:segmentedArray];
    
    self.segmentControl = segmentControl;
    segmentControl.selectedSegmentIndex = 0;
    [segmentControl
     addTarget:self
     action:@selector(segmentControlDidChangedValue:)
     forControlEvents:UIControlEventValueChanged];
    
    //第一个
    JJTableViewController *one = [[JJTableViewController alloc] init];
    one.title = @"第一个";
    
    //第二个
    JJTableViewController *two = [[JJTableViewController alloc] init];
    two.title = @"第二个";
    
    //第三个
    JJTableViewController *three = [[JJTableViewController alloc] init];
    three.title = @"第三个";
    
    //创建SegmentPager
    JJSegmentPager *pager = [[JJSegmentPager alloc] init];
    
    //参数设置
    pager.subControllers = @[one, two, three];
    
    pager.delegate = self;
    pager.segmentMiniTopInset = kNavHeight;//segmentBar顶端距离控制器的最小边距，也就是列表向上滑动时，最高能滑动到的位置，默认0，默认可以滑动到最顶端
    pager.headerHeight = HEADER_HEIGHT;//表头高度，默认0
    pager.barHeight = 44;//segmentBar高度（默认44）
    pager.currentPage = segmentControl.selectedSegmentIndex;
    pager.enableMainRefreshScroll = YES;//允许主列表下拉刷新，默认不允许NO
    pager.enableMainVerticalScroll = YES;//允许主列表可以上下滑动，改变表头偏移量（默认不允许NO）
    pager.enablePageHorizontalScroll = YES;//允许页面可以左右滑动切换，默认不允许NO
//    pager.enableSegmentBarCeilingScroll = NO;//允许标签按钮吸顶时可以滚动（默认允许YES）
    pager.customBarView = segmentControl;//自定义标签按钮
    pager.customHeaderView = headerView;//自定义表头
    [pager addParentController:self];
    self.pager = pager;
    
}

#pragma mark JJSegmentDelegate

- (void)jj_segment_scrollViewDidEndDecelerating:(NSInteger)index
{
    self.segmentControl.selectedSegmentIndex = index;
}

- (void)jj_segment_scrollViewDidVerticalScroll:(UIScrollView *)scrollView
{
    self.navView.backgroundColor = [UIColor colorWithWhite:1 alpha:scrollView.contentOffset.y / (HEADER_HEIGHT - kNavHeight)];
}

/**
 escription 标签按钮点击事件
 
 @param sender 点击位置
 */
- (void)segmentControlDidChangedValue:(UISegmentedControl *)sender
{
    NSInteger Index = sender.selectedSegmentIndex;
    //更换当前界面
    [self.pager switchPageViewWithIndex:Index];
    
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

