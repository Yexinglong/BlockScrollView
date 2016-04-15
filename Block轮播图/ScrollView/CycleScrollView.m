//
//  CycleScrollView.m
//  YXLScrollView
//
//  Created by Yexinglong on 14/10/9.
//  Copyright (c) 2014年 Yexinglong. All rights reserved.
//

#import "CycleScrollView.h"

#import "NSTimer+Addition.h"
#import "MyPageControl.h"
//                                          屏幕大小
#define kWindowWidth                        ([[UIScreen mainScreen] bounds].size.width)
#define kWindowHeight                       ([[UIScreen mainScreen] bounds].size.height)
@interface CycleScrollView () <UIScrollViewDelegate>
{
    CGFloat scrollViewStartContentOffsetX;
}
@property (nonatomic , assign) NSInteger currentPageIndex;
@property (nonatomic , assign) NSInteger totalPageCount;
@property (nonatomic , strong) NSMutableArray *contentViews;
@property (nonatomic , strong) NSMutableArray *pageViews;

@property (nonatomic , strong) UIScrollView *scrollView;

@property (nonatomic , strong) NSTimer *animationTimer;
@property (nonatomic , assign) NSTimeInterval animationDuration;

@property (nonatomic , strong) MyPageControl *pageControl;

@end

@implementation CycleScrollView

- (MyPageControl *)pageControl
{
    //少于或者等于一页的话，没有必要显示pageControl
    if (self.totalPageCount > 1) {
        if (!_pageControl) {
            NSInteger totalPageCounts = self.totalPageCount;
            CGFloat dotGapWidth = 8.0;
            UIImage *normalDotImage = [UIImage imageNamed:@"page_state_normal"];
            UIImage *highlightDotImage = [UIImage imageNamed:@"page_state_highlight"];
            CGFloat pageControlWidth = totalPageCounts * normalDotImage.size.width + (totalPageCounts - 1) * dotGapWidth;
            CGRect pageControlFrame = CGRectMake(CGRectGetMidX(self.scrollView.frame) - 0.5 * pageControlWidth , 0.9 * CGRectGetHeight(self.scrollView.frame), pageControlWidth, normalDotImage.size.height);
            
            _pageControl = [[MyPageControl alloc] initWithFrame:pageControlFrame
                                                    normalImage:normalDotImage
                                               highlightedImage:highlightDotImage
                                                     dotsNumber:totalPageCounts sideLength:dotGapWidth dotsGap:dotGapWidth];
            _pageControl.hidden = NO;
        }
    }
    return _pageControl;
}

- (void)setTotalPagesCount:(NSInteger (^)(void))totalPagesCount
{
    _totalPagesCount=totalPagesCount;
    self.totalPageCount = totalPagesCount();
    if (self.totalPageCount > 0) {
        if (self.totalPageCount > 1) {
            self.scrollView.scrollEnabled = YES;
            self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
            [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
        } else {
            self.scrollView.scrollEnabled = NO;
        }
        [self configContentViews];
        
        [self addSubview:self.pageControl];
    }

}


- (void)setFetchContentViewAtIndex:(UIView *(^)(NSInteger index))fetchContentViewAtIndex
{
    _fetchContentViewAtIndex = fetchContentViewAtIndex;
    //加入第一页
    [self configContentViews];
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex
{
    _currentPageIndex = currentPageIndex;
    [self.pageControl setCurrentPage:_currentPageIndex];
}

- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration
{
    self = [self initWithFrame:frame];
    if (animationDuration > 0.0) {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(self.animationDuration = animationDuration)
                                                               target:self
                                                             selector:@selector(animationTimerDidFired:)
                                                             userInfo:nil
                                                              repeats:YES];
        [self.animationTimer pauseTimer];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView.showsHorizontalScrollIndicator = NO;
        // Initialization code
        self.autoresizesSubviews = YES;
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = 0xFF;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.contentMode = UIViewContentModeCenter;
        self.scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        [self addSubview:self.scrollView];
        self.currentPageIndex = 0;
        _pageViews =[NSMutableArray array];
    }
    return self;
}

#pragma mark -
#pragma mark - 私有函数

- (void)configContentViews
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setScrollViewContentDataSource];
    
    NSInteger counter = 0;
    for (UIView *contentView in self.contentViews) {
        contentView.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapGestureAction:)];
        [contentView addGestureRecognizer:longTapGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapAction:)];
        [contentView addGestureRecognizer:tapGesture];
        CGRect rightRect = contentView.frame;
        rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame) * (counter ++), 0);
        
        contentView.frame = rightRect;
        [self.scrollView addSubview:contentView];
    }
    if (self.totalPageCount > 1) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    }
}

/**
 *  设置scrollView的content数据源，即contentViews
 */
- (void)setScrollViewContentDataSource
{
    if (self.totalPagesCount) {
        self.totalPageCount=self.totalPagesCount();
        if (_pageControl.pageNumbers !=self.totalPageCount) {
            [_pageControl removeFromSuperview];
            _pageControl=nil;
            [self addSubview:self.pageControl];
            [_pageControl setCurrentPage:self.currentPageIndex];

        }
    }
    NSInteger previousPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
    NSInteger rearPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
    
    if (self.contentViews == nil) {
        self.contentViews = [@[] mutableCopy];
    }
    [self.contentViews removeAllObjects];
    
    if (self.fetchContentViewAtIndex) {
        id set = (self.totalPageCount == 1)?[NSSet setWithObjects:@(previousPageIndex),@(_currentPageIndex),@(rearPageIndex), nil]:@[@(previousPageIndex),@(_currentPageIndex),@(rearPageIndex)];
        for (NSNumber *tempNumber in set) {
            NSInteger tempIndex = [tempNumber integerValue];
            if ([self isValidArrayIndex:tempIndex]) {
                [self.contentViews addObject:self.fetchContentViewAtIndex(tempIndex)];
            }
        }
    }
}

- (BOOL)isValidArrayIndex:(NSInteger)index
{
    if (index >= 0 && index <= self.totalPageCount - 1) {
        return YES;
    } else {
        return NO;
    }
}

- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex;
{
    if(currentPageIndex == -1) {
        return self.totalPageCount - 1;
    } else if (currentPageIndex == self.totalPageCount) {
        return 0;
    } else {
        return currentPageIndex;
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollViewStartContentOffsetX = kWindowWidth;
    
    [self.animationTimer pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    scrollView.userInteractionEnabled=NO;
//    NSLog(@"%@",(NSStringFromCGRect(scrollView.frame)));
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    if (self.totalPageCount == 2) {
        if (scrollViewStartContentOffsetX < contentOffsetX) {
            UIView *tempView = (UIView *)[self.contentViews lastObject];
            tempView.frame = (CGRect){{2 * CGRectGetWidth(scrollView.frame),0},tempView.frame.size};
        } else if (scrollViewStartContentOffsetX > contentOffsetX) {
            UIView *tempView = (UIView *)[self.contentViews firstObject];
            tempView.frame = (CGRect){{0,0},tempView.frame.size};
        }
    }
    
    if(contentOffsetX >= (2 * CGRectGetWidth(scrollView.frame))) {
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
        //        NSLog(@"next，当前页:%d",self.currentPageIndex);
        [self configContentViews];
    }
    if(contentOffsetX <= 0) {
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
        //        NSLog(@"previous，当前页:%d",self.currentPageIndex);
        [self configContentViews];
    }
    scrollView.userInteractionEnabled=YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
}

#pragma mark -
#pragma mark - 响应事件

- (void)longTapGestureAction:(UILongPressGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateBegan) {
//        NSLog(@"UIGestureRecognizerStateBegan");
           [self.animationTimer pauseTimer];
      
    }
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        [self.animationTimer resumeTimer];
//        NSLog(@"UIGestureRecognizerStateEnded");
    }
    
}

- (void)animationTimerDidFired:(NSTimer *)timer
{
    
    CGPoint newOffset = CGPointMake( kWindowWidth *2, self.scrollView.contentOffset.y);

    [self.scrollView setContentOffset:newOffset animated:YES];
}

- (void)contentViewTapAction:(UITapGestureRecognizer *)tap
{
    if (self.TapActionBlock) {
        self.TapActionBlock(self.currentPageIndex);
    }
}

@end
