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
#import "UINavigationBar+JJAwesome.h"

#define NAVBAR_CHANGE_POINT 50
#define HEADER_HEIGHT 240

@interface JJCustomBarViewController ()

@property (nonatomic, strong) JJSegmentPager *pager;
@property (nonatomic, assign) NSInteger offsetY;

@end

@implementation JJCustomBarViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar jj_setBackgroundColor:[UIColor clearColor]];
    [self updateNavigationBarWithOffsetY:HEADER_HEIGHT - self.offsetY];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar jj_reset];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupSegmentPager];
}

- (void)setupSegmentPager
{
    //自定义标签按钮
    NSArray *segmentedArray = @[@"第一个", @"第二个", @"第三个"];
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:segmentedArray];
    
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
    
    pager.segmentMiniTopInset = kNavHeight;//segmentBar顶端距离控制器的最小边距，也就是列表向上滑动时，最高能滑动到的位置，默认0，默认可以滑动到最顶端
    pager.headerHeight = HEADER_HEIGHT;//表头高度，默认0
    pager.enableOffsetChanged = YES;//允许列表滑动时,同时改变表头偏移量，默认不允许NO
    pager.enableMaxHeaderHeight = YES;//允许列表下拉时,表头可以扩展到最大高度，默认不允许NO
    pager.enableContentSizeChanged = YES;//允许列表的数据源过小时,仍可向上滑动,来改变表头偏移量，默认不允许NO
    pager.enableScrollViewDrag = YES;//允许页面可以左右滑动切换，默认不允许NO
    pager.needShadow = YES;//设置segmentBar阴影
    pager.customBarView = segmentControl;//自定义标签按钮
    pager.enableScrollViewDrag = YES;
    [pager addParentController:self];
    self.pager = pager;
    
    
    __weak typeof(self) vc = self;
    //列表滑动过程中偏移量数值回调 返回bar到控制器顶端的距离
    [pager updateSegmentTopInsetBlock:^(CGFloat top) {
        
        //更新NavigationBar背景颜色
        [vc updateNavigationBarWithOffsetY:HEADER_HEIGHT - top];
        
        vc.offsetY = top;
        
        NSLog(@"%f", top);
    }];
    
    //scrollViewDidEndDecelerating代理回调 更改自定义标签按钮索引
    [pager scrollViewDidEndDeceleratingBlock:^(NSInteger currentPage) {
        
        segmentControl.selectedSegmentIndex = currentPage;
        
    }];
}

/**
 Description 标签按钮点击事件
 
 @param sender 点击位置
 */
- (void)segmentControlDidChangedValue:(UISegmentedControl *)sender
{
    NSInteger Index = sender.selectedSegmentIndex;
    //更换当前界面
    [self.pager segmentDidSelectedValue:Index];
    
}

- (void)updateNavigationBarWithOffsetY:(CGFloat)offsetY
{
    UIColor * color = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:0/255.0 alpha:1];
    if (offsetY > NAVBAR_CHANGE_POINT) {
        CGFloat alpha = MIN(1, 1 - ((NAVBAR_CHANGE_POINT + kNavHeight - offsetY) / kNavHeight));
        [self.navigationController.navigationBar jj_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
    } else {
        [self.navigationController.navigationBar jj_setBackgroundColor:[color colorWithAlphaComponent:0]];
    }
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
