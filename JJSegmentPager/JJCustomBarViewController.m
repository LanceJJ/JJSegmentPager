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
    
    pager.segmentMiniTopInset = kNavHeight;
    pager.headerHeight = HEADER_HEIGHT;
    pager.enableOffsetChanged = YES;
    pager.enableMaxHeaderHeight = YES;
    pager.enableContentSizeChanged = YES;
    pager.enableScrollViewDrag = YES;
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
