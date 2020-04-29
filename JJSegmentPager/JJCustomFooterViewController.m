//
//  JJCustomFooterViewController.m
//  JJSegmentPager
//
//  Created by Lance on 2018/5/7.
//  Copyright © 2018年 Lance. All rights reserved.
//

#import "JJCustomFooterViewController.h"
#import "JJTableViewController.h"
#import "JJSegmentPager.h"
#import "JJCustomHeader.h"
#import "JJNavigationView.h"

@interface JJCustomFooterViewController () <JJSegmentDelegate>

@property (nonatomic, strong) JJNavigationView *navView;
@property (nonatomic, strong) JJSegmentPager *pager;
@property (nonatomic, strong) UISegmentedControl *segmentControl;

@end

@implementation JJCustomFooterViewController

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
    CGFloat footerH = 44.0;
    
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
    
    //自定义表尾
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, footerH)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = footerView.bounds;
    button.backgroundColor = [UIColor orangeColor];
    [button setTitle:@"回到原点" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:button];
    
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
    pager.footerHeight = footerH;//设置表尾高度，默认0
    pager.enableMainRefreshScroll = YES;//允许主列表下拉刷新，默认不允许NO
    pager.enablePageHorizontalScroll = YES;//允许页面可以左右滑动切换，默认不允许NO
//    pager.enableSegmentBarCeilingScroll = NO;//允许标签按钮吸顶时可以滚动（默认允许YES）
    pager.customHeaderView = headerView;//自定义表头
    pager.customBarView = segmentControl;//自定义标签按钮
    pager.customFooterView = footerView;//自定义表尾
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

- (void)click
{
    [self.pager scrollToOriginalPoint];
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
