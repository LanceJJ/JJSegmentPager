# JJSegmentPager

## 选项卡控制器

* 简单使用标签控制器
* 自带标签按钮样式设置
* 自定义表头
* 自定义标签按钮
* 自定义表尾
* 可以单独使用自带的标签按钮JJSegmentBar，自己实现页面切换


## 使用方法

### 基本用法（简单的标签控制器）

```objc
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
    [pager addParentController:self];
```	

* `标签子控制器内部一定要实现JJSegmentDelegate代理的方法`
```objc
    
    - (UIScrollView *)jj_segment_obtainScrollView
    {
        return self.tableView;
    }
    
```	

### 自带标签按钮样式设置

* 可以更改标签按钮样式，满足业务需求

```objc
    
    pager.currentPage = 1; //初始化按钮显示位置（默认0）
    pager.barIndicatorType = JJBarIndicatorAutoWidthType;//标签按钮底部指示器宽度类型设置 （默认等宽）
    pager.barSegmentBtnWidthType = JJBarSegmentBtnAutoWidthType2;//标签按钮的宽度设置（默认JJBarSegmentBtnAutoWidthType1）
    pager.barHeight = 46; //segmentBar高度（默认44）
    pager.barSelectColor = [UIColor orangeColor];//标题点击颜色（默认蓝色）
    pager.barNormalColor = [UIColor lightGrayColor];//标题正常颜色（默认黑色）
    pager.barSelectFont = [UIFont boldSystemFontOfSize:14];//标题点击尺寸（默认 [UIFont boldSystemFontOfSize:17]）
    pager.barNormalFont = [UIFont systemFontOfSize:13];//标题正常尺寸（默认 [UIFont systemFontOfSize:16]）
    pager.barHighlightBackgroundColor = [UIColor blueColor];//按钮高亮背景色（默认透明）
    pager.barBackgroundColor = [UIColor greenColor];//bar的背景色（默认白色）
    pager.barIndicatorColor = [UIColor redColor];//底部指示器颜色（默认标题点击颜色）
    pager.barIndicatorHeight = 4;//底部指示器高度（默认3，设置范围 0～按钮高度的1/3，超出范围显示默认值）
    pager.barIndicatorWidth = 16;//底部指示器宽度（当 JJBarIndicatorType == JJBarIndicatorSameWidthType 时设置有效，设置范围 0～按钮宽度，超出范围显示默认值）
    pager.barIndicatorCornerRadius = 2;//底部指示器圆角（默认0）
    pager.barContentInset = UIEdgeInsetsMake(0, 15, 0, 15);//segmentBar的内边距（默认UIEdgeInsetsZero，注：适用自定义标签按钮）
    pager.barLineColor = [UIColor redColor];//segmentBar底部线条颜色（注：适用自定义标签按钮）
    pager.needLine = YES;//设置segmentBar是否带底部线条效果（默认不带NO， 注：适用自定义标签按钮）
    pager.needShadow = YES;//设置segmentBar是否带阴影效果（默认不带NO， 注：适用自定义标签按钮）
    
```    

### 自定义表头

* 自定义表头，创建表头，之后赋值给customHeaderView，通过滑动的偏移量回调，来实现表头内部控件的动画效果

```objc

    //创建一个自定义表头
    JJCustomHeader *headerView = [[[NSBundle mainBundle] loadNibNamed:@"JJCustomHeader" owner:self options:nil] lastObject];
    
    //改变这两个参数，获得自己想要的高度，以及表头滑动范围
    pager.segmentMiniTopInset = kNavHeight;
    pager.headerHeight = HEADER_HEIGHT;
    
    pager.enableMainRefreshScroll = YES;//允许主列表下拉刷新（默认不允许NO）
    pager.enableMainVerticalScroll = YES;//允许主列表可以上下滑动，改变表头偏移量（默认不允许NO）
    pager.enablePageHorizontalScroll = YES;//允许页面可以左右滑动切换，默认不允许NO
    
    //赋值自定义表头
    pager.customHeaderView = headerView;
    
    __weak typeof(self) vc = self;
    //列表滑动过程中偏移量数值回调 返回bar到控制器顶端的距离 通过返回的数值，可以自己实现NavigationBar颜色渐变等动画效果，以及自定义表头里面控件的动画效果

    pager.jj_segment_scrollViewDidVerticalScrollBlock = ^(UIScrollView *scrollView) {
        NSLog(@"=====================%f", scrollView.contentOffset.y);
        
        vc.navView.backgroundColor = [UIColor colorWithWhite:1 alpha:scrollView.contentOffset.y / (HEADER_HEIGHT - kNavHeight)];
        
    };
   
```	

### 自定义标签按钮

* 如果觉得自带的标签按钮满足不了需求，可以自己自定义一个，现拿系统的UISegmentedControl为例
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
//    pager.barHeight = 44;//标签按钮高度，默认44

    //赋值自定义标签按钮
    pager.customBarView = segmentControl;//自定义标签按钮
    
```	
* 1.需要实现scrollViewDidEndDecelerating代理回调 更改自定义标签按钮索引（提供代理与block两种回调）

```objc
    //需要实现scrollViewDidEndDecelerating代理回调 更改自定义标签按钮索引
    - (void)jj_segment_scrollViewDidEndDecelerating:(NSInteger)index
    {
        self.segmentControl.selectedSegmentIndex = index;
    }

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
        [self.pager switchPageViewWithIndex:Index];
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


