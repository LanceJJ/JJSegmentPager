# JJSegmentPager

## 选项卡控制器

* 简单使用标签控制器
* 自定义表头
* 自定义标签按钮
* 自定义表尾
* 可以单独使用自带的标签按钮JJSegmentBar，自己实现页面切换


## 使用方法

### 基本用法（简单的标签控制器）

```objc
    //创建需要的标签控制器，需要赋值控制器的title，此值为标签按钮的标题
    
    //第一个
    JJTableViewController *one = [[JJTableViewController alloc] init];
    one.title = @"第一个";
    
    //第二个
    JJTableViewController *two = [[JJTableViewController alloc] init];
    two.title = @"第二个";
    
    //第三个
    JJTableViewController *three = [[JJTableViewController alloc] init];
    three.title = @"第三个";
    
    //创建SegmentPager控制器
    JJSegmentPager *pager = [[JJSegmentPager alloc] init];
    
    //参数设置（根据需要设置参数，如果注释中的参数不设置，则是一个简单的标签按钮控制页面）
    pager.subControllers = @[one, two, three];//添加页面子控制器

    pager.subControllers = @[one, two, three];//添加页面子控制器
    pager.segmentMiniTopInset = 0;//segmentBar顶端距离控制器的最小边距，也就是列表向上滑动时，最高能滑动到的位置，默认0，默认可以滑动到最顶端
    pager.headerHeight = kNavHeight;//表头高度，默认0
//    pager.footerHeight = 40;//表尾高度，默认0
//    pager.barSegmentBtnWidthType = JJBarSegmentBtnAutoWidthType;//标签按钮宽度类型
//    pager.barIndicatorType = JJBarIndicatorAutoWidthType;//标签按钮底部指示器宽度类型
//    pager.segmentHeight = 44;//标签按钮高度，默认44
//    pager.currentPage = 1;//当前标签按钮位置，默认0
//    pager.barContentInset = UIEdgeInsetsMake(0, 30, 0, 30);//segmentBar的内边距，默认UIEdgeInsetsZero
//    pager.barSelectColor = [UIColor blackColor];//标签按钮标题选中颜色，默认蓝色
//    pager.barNormalColor = [UIColor redColor];//标签按钮标题非点击颜色，默认黑色
//    pager.barBackgroundColor = [UIColor blueColor];//标签按钮背景色，默认白色
//    pager.barHighlightBackgroundColor = [UIColor lightGrayColor];//按钮点击高亮颜色，默认透明
//    pager.enableOffsetChanged = YES;//允许列表滑动时,同时改变表头偏移量，默认不允许NO
//    pager.enableMaxHeaderHeight = YES;//允许列表下拉时,表头可以扩展到最大高度，默认不允许NO
//    pager.enableContentSizeChanged = YES;//允许列表的数据源过小时,仍可向上滑动,来改变表头偏移量，默认不允许NO
//    pager.enableScrollViewDrag = YES;//允许页面可以左右滑动切换，默认不允许NO
    pager.needShadow = YES;//设置segmentBar是否带阴影效果，默认不带NO
//    pager.customBarView = customBarView;//自定义标签按钮
//    pager.customHeaderView = customHeaderView;//自定义表头
//    pager.customFooterView = customFooterView;//自定义表尾

    //添加JJSegmentPager
    [pager addParentController:self];
```	

* `标签子控制器内部一定要实现JJSegmentDelegate代理的方法`
```objc
    
    - (UIScrollView *)streachScrollView
    {
        return self.tableView;
    }
    
```	


### 带默认表头

* 基本创建步骤都是一样的，改变以下参数就可以

```objc

    //改变这两个参数，获得自己想要的高度，以及表头滑动范围
    pager.segmentMiniTopInset = kNavHeight;
    pager.headerHeight = HEADER_HEIGHT;
    
    //需要允许列表滑动时,同时改变表头偏移量，否则表头是固定大小的
    pager.enableOffsetChanged = YES;
    
```	

### 自定义表头

* 自定义表头，创建表头，之后赋值给customHeaderView，通过滑动的偏移量回调，来实现表头内部控件的动画效果

```objc

    //创建一个自定义表头
    JJCustomHeader *headerView = [[[NSBundle mainBundle] loadNibNamed:@"JJCustomHeader" owner:self options:nil] lastObject];
    
    //改变这两个参数，获得自己想要的高度，以及表头滑动范围
    pager.segmentMiniTopInset = kNavHeight;
    pager.headerHeight = HEADER_HEIGHT;
    
    //需要允许列表滑动时,同时改变表头偏移量，否则表头是固定大小的
    pager.enableOffsetChanged = YES;
    
    //赋值自定义表头
    pager.customHeaderView = headerView;
    
    __weak typeof(self) vc = self;
    //列表滑动过程中偏移量数值回调 返回bar到控制器顶端的距离 通过返回的数值，可以自己实现NavigationBar颜色渐变等动画效果，以及自定义表头里面控件的动画效果
    [pager updateSegmentTopInsetBlock:^(CGFloat top) {
        
        //更新NavigationBar背景颜色
        [vc updateNavigationBarWithOffsetY:HEADER_HEIGHT - top];
        
        //更新自定义表头控件
        [headerView updateHeaderImageWithOffsetY:top];
        
        vc.offsetY = top;
        
        NSLog(@"%f", top);
    }];
   
```	

### 自定义标签按钮

* 如果觉得自带的标签按钮不好，可以自己自定义一个，现拿系统的UISegmentedControl为例
* 创建标签按钮，赋值给customBarView，同时要实现两个方法

```objc

    //创建一个自定义按钮
    NSArray *segmentedArray = @[@"第一个", @"第二个", @"第三个"];
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:segmentedArray];
    
    segmentControl.selectedSegmentIndex = 0;
    [segmentControl
     addTarget:self
     action:@selector(segmentControlDidChangedValue:)
     forControlEvents:UIControlEventValueChanged];

    //按钮高度默认44，可以不进行设置，如需改变高度，可设置此参数
//    pager.segmentHeight = 44;//标签按钮高度，默认44

    //赋值自定义标签按钮
    pager.customBarView = segmentControl;//自定义标签按钮
    
```	
* 1.需要实现scrollViewDidEndDecelerating代理回调 更改自定义标签按钮索引

```objc
    //需要实现scrollViewDidEndDecelerating代理回调 更改自定义标签按钮索引
    [pager scrollViewDidEndDeceleratingBlock:^(NSInteger currentPage) {
        
        segmentControl.selectedSegmentIndex = currentPage;
        
    }];
```	

* 2.需要实现标签按钮点击的方法，用来切换当前页面

```objc

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
    
```	

### 自定义表尾

* 自定义表尾，创建表尾，之后赋值给customFooterView，表尾固定在尾部，不可随着列表滑动而改变什么，可根据业务在表尾自定义一些控件


```objc

    //创建一个自定义表尾
    CGFloat footerH = 44.0;
    
    //自定义表尾
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, footerH)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = footerView.bounds;
    button.backgroundColor = [UIColor orangeColor];
    [button setTitle:@"点击" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:button];

    //设置表尾高度
    pager.footerHeight = footerH;//设置表尾高度，默认是0

    //赋值自定义表尾
    pager.customFooterView = footerView;//自定义表尾
    
```	


## 效果图

### 基本用法与默认表头
![](https://github.com/LanceJJ/JJSegmentPager/raw/master/JJSegmentPager/Image/ezgif.com-optimize.gif)

### 自定义标签按钮与自定义表头
![](https://github.com/LanceJJ/JJSegmentPager/raw/master/JJSegmentPager/Image/ezgif.com-optimize-1.gif)
