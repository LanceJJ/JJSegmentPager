//
//  JJSegmentBar.m
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//

#import "JJSegmentBar.h"

#define JJ_SegmentBar_ScrollviewH 44.0
#define JJ_SegmentBar_BottomH 3.0
#define JJ_SegmentBar_Edge 5
#define JJ_SegmentBar_BtnCount 5
#define JJ_SegmentBar_Padding 20

@interface JJSegmentBar() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) CGFloat viewWidth;
@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, assign) CGFloat contentWidth;

@property (nonatomic, strong) UIView *indicatorView;

@end

@implementation JJSegmentBar

- (UIColor *)indicatorColor
{
    if (!_indicatorColor) {
        _indicatorColor = self.selectColor ? self.selectColor : [UIColor blueColor];
    }
    return _indicatorColor;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, self.frame.size.height);
        self.clipsToBounds = YES;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        self.viewWidth = self.frame.size.width;
        self.viewHeight = self.frame.size.height;
        self.itemHeight = self.frame.size.height;
        
        self.selectColor = [UIColor blueColor];
        self.normalColor = [UIColor blackColor];
        self.selectFont = [UIFont boldSystemFontOfSize:17];
        self.normalFont = [UIFont systemFontOfSize:16];
        
        [self setupCollectionView];
        [self setupIndicatorView];
    }
    return self;
}

#pragma mark - private methods

- (void)setupIndicatorView
{
    UIView *indicatorView = [[UIView alloc] init];
    [self.collectionView addSubview:indicatorView];
    
    self.indicatorView = indicatorView;
}

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, self.itemHeight) collectionViewLayout:layout];
    
    collectionView.backgroundColor = [UIColor whiteColor];
    
    [collectionView registerClass:[PPSegmentBarCell class] forCellWithReuseIdentifier:@"PPSegmentBarCell"];
    
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:collectionView];
    
    self.collectionView = collectionView;
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PPSegmentBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PPSegmentBarCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = self.titles[indexPath.row];
    
    if (self.currentPage == indexPath.row) {
        cell.titleLabel.textColor = self.selectColor;
        cell.titleLabel.font = self.selectFont;
    } else {
        cell.titleLabel.textColor = self.normalColor;
        cell.titleLabel.font = self.normalFont;
    }

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.titles.count == 0) return CGSizeMake(0, self.itemHeight);
    
    //当所有按钮宽度总和小于屏幕宽度时，按钮还是等宽
    if (self.segmentBtnType == JJSegmentBtnAutoWidthType1 && self.contentWidth <= self.viewWidth && self.contentWidth != 0) {

        return CGSizeMake(self.viewWidth / self.titles.count, self.itemHeight);

    } else {
        NSString *content = self.titles[indexPath.row];
        
        UIFont *font = self.currentPage == indexPath.row ? self.selectFont : self.normalFont;
        
        CGRect bounds = [content boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        
        return CGSizeMake(bounds.size.width + JJ_SegmentBar_Padding * 2, self.itemHeight);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:( NSInteger )section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentPage == indexPath.row) return;
    
    if ([self.delegate respondsToSelector:@selector(jj_segmentBar_didSelected:)]) {
        [self.delegate jj_segmentBar_didSelected:indexPath.row];
    }
    
    self.currentPage = indexPath.row;
    
    [self selectItemDuration:0.2];
}

- (void)selectItemDuration:(NSTimeInterval)duration
{
    //确保获取的位置正确
    [self.collectionView reloadData];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

    //当前item的位置
    UICollectionViewLayoutAttributes *pose = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPage inSection:0]];
    
//    NSLog(@"%@", NSStringFromCGRect(pose.frame));

//    // scroll view 当前偏移量
//    CGFloat scrollOffsetX = self.collectionView.contentOffset.x;
//    // 屏幕中显示的位置
//    CGFloat screenX = self.frame.size.width / 2;
//    // 在当前屏幕中偏移量
//    CGFloat selectOffsetX = cell.frame.origin.x - self.collectionView.contentOffset.x;
//
//    if (selectOffsetX < screenX) {
//        scrollOffsetX -= screenX - selectOffsetX;
//    }else{
//        scrollOffsetX += selectOffsetX - screenX;
//    }
//
//    if (scrollOffsetX < 0) {
//        scrollOffsetX = 0;
//    }
//
//    if (self.collectionView.contentSize.width - self.collectionView.frame.size.width < 0) {
//        scrollOffsetX = 0;
//    } else if (scrollOffsetX > self.collectionView.contentSize.width - self.collectionView.frame.size.width) {
//        scrollOffsetX = self.collectionView.contentSize.width - self.collectionView.frame.size.width;
//    } else {
////        scrollOffsetX = 0;
//    }
//
//    [self.collectionView setContentOffset:CGPointMake(scrollOffsetX, 0) animated:YES];
    [self.collectionView reloadData];

    NSString *content = self.titles[self.currentPage];
    
    CGRect bounds = [content boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.selectFont} context:nil];
    
    CGFloat currentWidth = pose.frame.size.width - JJ_SegmentBar_Edge * 2;
    
    //如果设置的高度小于0，或者大于按钮高度的1/3，显示默认高度
    self.indicatorHeight = (self.indicatorHeight <= 0 || self.indicatorHeight > self.viewHeight / 3.0) ? JJ_SegmentBar_BottomH : self.indicatorHeight;
    //如果设置的宽度小于0，或者大于按钮宽度，显示默认宽度
    self.indicatorWidth = (self.indicatorWidth <= 0 || self.indicatorWidth > currentWidth) ? currentWidth : self.indicatorWidth;
    
    CGFloat titleWidth = bounds.size.width > currentWidth ? currentWidth: bounds.size.width;
    CGFloat indicatorWidth = self.indicatorType == JJIndicatorSameWidthType ? self.indicatorWidth : titleWidth;
    
    [UIView animateWithDuration:duration animations:^{
        
        self.indicatorView.frame = CGRectMake(0, 0, indicatorWidth, self.indicatorHeight);
        self.indicatorView.center = CGPointMake(pose.frame.origin.x + pose.frame.size.width / 2 , self.viewHeight - self.indicatorHeight / 2);
    }];
}

/// Description 初始化各项参数配置
- (void)setupConfigureAppearance
{
    if (self.titles.count == 0 || self.titles == nil) return;
    
    self.currentPage = (self.currentPage > self.titles.count - 1 || self.currentPage < 0) ? 0 : self.currentPage;

    //用于获取collectionViewContentSize
    self.contentWidth = 0;
    [self.collectionView reloadData];

    //根据类型进行布局
    self.contentWidth = self.collectionView.collectionViewLayout.collectionViewContentSize.width;
    [self.collectionView reloadData];
    
    self.indicatorView.backgroundColor = self.indicatorColor;
    self.indicatorView.layer.cornerRadius = self.indicatorCornerRadius;
    
    //切换当前点击按钮
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self selectItemDuration:0];
    });
}

/// Description 切换当前点击按钮位置
/// @param currentPage 当前按钮位置
- (void)switchBtnWithCurrentPage:(NSInteger)currentPage
{
    self.currentPage = (currentPage > self.titles.count - 1 || currentPage < 0) ? 0 : currentPage;
    
    if (self.titles.count == 0 || self.titles.count - 1 < self.currentPage) return;
    
    [self selectItemDuration:0.2];
}

- (void)setNormalFont:(UIFont *)normalFont
{
    _normalFont = normalFont ? normalFont : [UIFont systemFontOfSize:16];
}

- (void)setSelectFont:(UIFont *)selectFont
{
    _selectFont = selectFont ? selectFont : [UIFont boldSystemFontOfSize:17];
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor ? normalColor : [UIColor blackColor];
}

- (void)setSelectColor:(UIColor *)selectColor
{
    _selectColor = selectColor ? selectColor : [UIColor blueColor];
}

@end

@implementation PPSegmentBarCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupSubViews];
        
    }
    return self;
}

- (void)setupSubViews
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    
    self.titleLabel = titleLabel;
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *indexCenterY = [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self addConstraint:indexCenterY];
    
    NSLayoutConstraint *indexCenterX = [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self addConstraint:indexCenterX];
}

@end
