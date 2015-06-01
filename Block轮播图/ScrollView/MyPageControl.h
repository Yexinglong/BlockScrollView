//
//  MyPageControl.h
//  YXLScrollView
//
//  Created by Yexinglong on 14/10/9.
//  Copyright (c) 2014年 Yexinglong. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MyPageControlDelegate <NSObject>

@optional

- (void)pageControlDidStopAtIndex:(NSInteger)index;

@end

@interface MyPageControl : UIView


@property (nonatomic , assign)NSInteger pageNumbers;
@property (nonatomic , weak)  id<MyPageControlDelegate> delegate;
- (id)initWithFrame:(CGRect)frame
        normalImage:(UIImage *)nImage
   highlightedImage:(UIImage *)hImage
         dotsNumber:(NSInteger)pageNum
         sideLength:(NSInteger)size
            dotsGap:(NSInteger)gap;

- (void)setCurrentPage:(NSInteger)pages;

@end

