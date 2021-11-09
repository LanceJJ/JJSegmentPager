//
//  JJSegmentBar.m
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//

#import "JJSegmentBar.h"

#define JJ_SegmentBar_BottomH 3.0
#define JJ_SegmentBar_Padding 24

@interface JJSegmentBar() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, assign) CGFloat viewWidth;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, assign) CGFloat contentWidth;

@end

@implementation JJSegmentBar

- (UIColor *)indicatorColor
{
    return _indicatorColor ? _indicatorColor : self.selectColor;
}

- (UIColor *)lineColor
{
    return _lineColor ? _lineColor : [UIColor colorWithRed:243.0 / 255.0 green:243.0 / 255.0 blue:243.0 / 255.0 alpha:1];
}

- (UIColor *)normalColor
{
    return _normalColor ? _normalColor : [UIColor blackColor];
}

- (UIColor *)selectColor
{
    return _selectColor ? _selectColor : [UIColor blueColor];
}

- (UIFont *)normalFont
{
    return _normalFont ? _normalFont : [UIFont systemFontOfSize:16];
}

- (UIFont *)selectFont
{
    return _selectFont ? _selectFont : [UIFont boldSystemFontOfSize:17];
}

- (CGFloat)itemPadding
{
    return _itemPadding <= 0 ? JJ_SegmentBar_Padding : _itemPadding;
}

- (NSInteger)currentPage
{
    return (_currentPage > self.titles.count - 1 || _currentPage < 0) ? 0 : _currentPage;;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];

        [self setupCollectionView];
        [self setupIndicatorView];
        [self setupLineView];
    }
    return self;
}

#pragma mark - private methods

- (void)setupLineView
{
    UIView *lineView = [[UIView alloc] init];
    lineView.hidden = YES;
    [self addSubview:lineView];
    
    self.lineView = lineView;
}

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
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:layout];
    
    collectionView.backgroundColor = [UIColor whiteColor];
    
    [collectionView registerClass:[PPSegmentBarCell class] forCellWithReuseIdentifier:@"PPSegmentBarCell"];
    
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.bounces = NO;
    
    [self addSubview:collectionView];
    
    self.collectionView = collectionView;
    
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
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
    if (self.itemType == JJSegmentItemAutoWidthType1 && self.contentWidth <= self.viewWidth) {

        return CGSizeMake(self.viewWidth / self.titles.count, self.itemHeight);

    } else {
        NSString *content = self.titles[indexPath.row];
        
        UIFont *font = self.currentPage == indexPath.row ? self.selectFont : self.normalFont;
        
        CGRect bounds = [content boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        
        return CGSizeMake(bounds.size.width + self.itemPadding, self.itemHeight);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger )section
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

    [self.collectionView reloadData];

    NSString *content = self.titles[self.currentPage];
    
    CGRect bounds = [content boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.selectFont} context:nil];
    
    CGFloat currentWidth = pose.frame.size.width - self.itemPadding;
    
    //如果设置的高度小于0，或者大于按钮高度的1/3，显示默认高度
    self.indicatorHeight = (self.indicatorHeight <= 0 || self.indicatorHeight > self.itemHeight / 3.0) ? JJ_SegmentBar_BottomH : self.indicatorHeight;
    //如果设置的宽度小于0，或者大于按钮宽度，显示默认宽度
    self.indicatorWidth = (self.indicatorWidth <= 0 || self.indicatorWidth > currentWidth) ? currentWidth : self.indicatorWidth;
    
    CGFloat titleWidth = bounds.size.width > currentWidth ? currentWidth : bounds.size.width;
    CGFloat indicatorWidth = self.indicatorType == JJIndicatorSameWidthType ? self.indicatorWidth : titleWidth;
    
    [UIView animateWithDuration:duration animations:^{
        
        self.indicatorView.frame = CGRectMake(0, 0, indicatorWidth, self.indicatorHeight);
        self.indicatorView.center = CGPointMake(pose.frame.origin.x + pose.frame.size.width / 2 , self.itemHeight - self.indicatorHeight / 2);
    }];
}

/// Description 初始化各项参数配置
- (void)setupConfigureAppearance
{
    if (!self.titles.count) {
        self.hidden = YES;
        return;
    }
    
    self.hidden = NO;
    
    [self.superview layoutIfNeeded];
    
    if (self.needLine && self.frame.size.height > 0.5) {
        self.lineView.hidden = NO;
        self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, self.contentInset.bottom + 0.7, self.contentInset.right);
    }
    
    if (self.needShadow && self.frame.size.height > 0.5) {
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
        self.layer.shadowOpacity = 0.5;
    }
    
    self.lineView.frame = CGRectMake(0, self.frame.size.height - 0.7, self.frame.size.width, 0.7);
    self.collectionView.frame = CGRectMake(self.contentInset.left, self.contentInset.top, self.frame.size.width - self.contentInset.left - self.contentInset.right, self.frame.size.height - self.contentInset.top - self.contentInset.bottom);

    self.viewWidth = self.frame.size.width - self.contentInset.left - self.contentInset.right;
    self.itemHeight = self.frame.size.height - self.contentInset.top - self.contentInset.bottom;
    
    NSLog(@"-----%f", self.frame.size.height);
    
    //计算内容总宽度
    CGFloat contentWidth = 0;
    for (NSInteger i = 0; i < self.titles.count; i++) {
        NSString *content = self.titles[i];
        
        UIFont *font = self.currentPage == i ? self.selectFont : self.normalFont;
        
        CGRect bounds = [content boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        
        contentWidth = contentWidth + bounds.size.width + self.itemPadding;
    }
    
    self.contentWidth = contentWidth;
    [self.collectionView reloadData];
    
    self.indicatorView.backgroundColor = self.indicatorColor;
    self.indicatorView.layer.cornerRadius = self.indicatorCornerRadius;
    self.lineView.backgroundColor = self.lineColor;
    
    //切换当前点击按钮
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self selectItemDuration:0];
    });
}

/// Description 切换当前点击位置
/// @param index 当前位置
- (void)switchItemWithIndex:(NSInteger)index
{
    self.currentPage = index;
    
    if (self.titles.count == 0 || self.titles.count - 1 < self.currentPage) return;
    
    [self selectItemDuration:0.2];
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
