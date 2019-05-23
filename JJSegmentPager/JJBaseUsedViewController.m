//
//  JJBaseUsedViewController.m
//  JJSegmentPager
//
//  Created by Lance on 2018/4/27.
//  Copyright © 2018年 Lance. All rights reserved.
//

#import "JJBaseUsedViewController.h"
#import "JJTableViewController.h"
#import "JJSegmentPager.h"

@interface JJBaseUsedViewController ()

@end

@implementation JJBaseUsedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupSegmentPager];
}

- (void)setupSegmentPager
{
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
    pager.subControllers = @[one, two, three];//添加页面子控制器
    pager.segmentMiniTopInset = 0;//segmentBar顶端距离控制器的最小边距，也就是列表向上滑动时，最高能滑动到的位置，默认0，默认可以滑动到最顶端
    pager.headerHeight = kNavHeight;//表头高度，默认0
//    pager.footerHeight = 40;//表尾高度，默认0
//    pager.barSegmentBtnWidthType = JJBarSegmentBtnAutoWidthType;//标签按钮宽度类型
//    pager.barIndicatorType = JJBarIndicatorAutoWidthType;//标签按钮底部指示器宽度类型
//    pager.headerViewChangeType = JJHeaderViewPositionChangeType;//表头随着偏移量改变的类型
//    pager.segmentHeight = 44;//标签按钮高度，默认44
//    pager.currentPage = 1;//当前标签按钮位置，默认0
//    pager.barContentInset = UIEdgeInsetsMake(0, 30, 0, 30);//segmentBar的内边距，默认UIEdgeInsetsZero
//    pager.barSelectColor = [UIColor blackColor];//标签按钮标题选中颜色，默认蓝色
//    pager.barNormalColor = [UIColor redColor];//标签按钮标题非点击颜色，默认黑色
//    pager.barBackgroundColor = [UIColor blueColor];//标签按钮背景色，默认白色
//    pager.barHighlightBackgroundColor = [UIColor lightGrayColor];//按钮点击高亮颜色，默认透明
//    pager.enableOffsetChanged = YES;//允许列表滑动时,同时改变表头偏移量，默认不允许NO
//    pager.enableMaxHeaderHeight = YES;//允许列表下拉时,表头可以扩展到最大高度，默认不允许NO
//    pager.enableScrollViewDrag = YES;//允许页面可以左右滑动切换，默认不允许NO
    pager.needShadow = YES;//设置segmentBar是否带阴影效果，默认不带NO
//    pager.customBarView = customBarView;//自定义标签按钮
//    pager.customHeaderView = customHeaderView;//自定义表头
//    pager.customFooterView = customFooterView;//自定义表尾
    [pager addParentController:self];
    
    
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
