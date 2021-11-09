//
//  JJChangeBarStyleViewController.m
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//

#import "JJChangeBarStyleViewController.h"
#import "JJTableViewController.h"

#import "JJSegmentPager.h"

@interface JJChangeBarStyleViewController ()

@end

@implementation JJChangeBarStyleViewController

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
    pager.segmentMiniTopInset = kNavHeight;//segmentBar顶端距离控制器的最小边距，也就是列表向上滑动时，最高能滑动到的位置，默认0，默认可以滑动到最顶端
    pager.headerHeight = kNavHeight;//表头高度，默认0
    
    pager.currentPage = 1; //初始化按钮显示位置（默认0）
//    pager.barIndicatorType = JJBarIndicatorAutoWidthType;//标签按钮底部指示器宽度类型设置 （默认等宽）
//    pager.barSegmentBtnWidthType = JJBarSegmentBtnAutoWidthType2;//标签按钮的宽度设置（默认JJBarSegmentBtnAutoWidthType1）
    pager.barHeight = 46; //segmentBar高度（默认44）
    pager.segmentBar.selectColor = [UIColor orangeColor];//标题点击颜色（默认蓝色）
    pager.segmentBar.normalColor = [UIColor lightGrayColor];//标题正常颜色（默认黑色）
    pager.segmentBar.selectFont = [UIFont boldSystemFontOfSize:21];//标题点击尺寸（默认 [UIFont boldSystemFontOfSize:17]）
    pager.segmentBar.normalFont = [UIFont systemFontOfSize:13];//标题正常尺寸（默认 [UIFont systemFontOfSize:16]）
//    pager.barBackgroundColor = [UIColor greenColor];//bar的背景色（默认白色）
    pager.segmentBar.indicatorColor = [UIColor redColor];//底部指示器颜色（默认标题点击颜色）
    pager.segmentBar.indicatorHeight = 4;//底部指示器高度（默认3，设置范围 0～按钮高度的1/3，超出范围显示默认值）
    pager.segmentBar.indicatorWidth = 16;//底部指示器宽度（当 JJBarIndicatorType == JJBarIndicatorSameWidthType 时设置有效，设置范围 0～按钮宽度，超出范围显示默认值）
    pager.segmentBar.indicatorCornerRadius = 2;//底部指示器圆角（默认0）
    pager.segmentBar.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);//segmentBar的内边距（默认UIEdgeInsetsZero，注：适用自定义标签按钮）
    pager.segmentBar.lineColor = [UIColor redColor];//segmentBar底部线条颜色（注：适用自定义标签按钮）
    pager.segmentBar.needLine = YES;//设置segmentBar是否带底部线条效果（默认不带NO， 注：适用自定义标签按钮）
    pager.segmentBar.needShadow = YES;//设置segmentBar是否带阴影效果（默认不带NO， 注：适用自定义标签按钮）
    
    pager.enablePageHorizontalScroll = YES;//允许页面可以左右横向滑动切换（默认不允许NO）
    
    [pager addParentController:self];
    
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
