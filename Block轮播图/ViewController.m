//
//  ViewController.m
//  Block轮播图
//
//  Created by 叶星龙 on 15/5/29.
//  Copyright (c) 2015年 叶星龙. All rights reserved.
//

#import "ViewController.h"
#import "CycleScrollView.h"
static const NSInteger kTotalPageCount = 4;
@interface ViewController ()
@property (nonatomic ,strong) CycleScrollView *mainScorllView;
@end
//                                          屏幕大小
#define kWindowWidth                        ([[UIScreen mainScreen] bounds].size.width)
#define kWindowHeight                       ([[UIScreen mainScreen] bounds].size.height)
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //本地假数据
    NSMutableArray *viewsArray = [@[] mutableCopy];
        NSArray *colorArray = @[[UIColor cyanColor],[UIColor blueColor],[UIColor greenColor],[UIColor yellowColor],[UIColor purpleColor]];
    for (int i = 0; i < kTotalPageCount; ++i) {
                UIView *tempLabel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 200)];
                tempLabel.backgroundColor = [(UIColor *)[colorArray objectAtIndex:i] colorWithAlphaComponent:0.5];
        
        [viewsArray addObject:tempLabel];
    }
    
    _mainScorllView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 200, kWindowWidth, 200) animationDuration:3];
    //    self.mainScorllView.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.1];
    //数据源：获取总的page个数，如果少于2个，不自动滚动
    _mainScorllView.totalPagesCount = ^NSInteger(void){
        return viewsArray.count;
    };
    //数据源：获取第pageIndex个位置的contentView（这个必须调）
    _mainScorllView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return viewsArray[pageIndex];
    };
    //当点击的时候，执行的block
    __weak __typeof(&*self) weakVar = self;
    self.mainScorllView.TapActionBlock = ^(NSInteger pageIndex){
            NSLog(@"点击了第%ld个",pageIndex);
            [weakVar viewsArrayAdd:viewsArray];
        };
    [self.view addSubview:_mainScorllView];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewsArrayAdd:(NSMutableArray *)array{
    [array addObjectsFromArray:array];
    [self.mainScorllView refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
