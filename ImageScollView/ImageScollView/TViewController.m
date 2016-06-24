//
//  TViewController.m
//  OilProject
//
//  Created by mac1 on 16/6/3.
//  Copyright © 2016年 jyf. All rights reserved.
//

#import "TViewController.h"
#import "ImageScrollView.h"


@implementation TViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //本地
    ImageScrollView *view = [[ImageScrollView alloc] initWithFrame:CGRectMake(100, 100, 200, 400) images:@[@"icon1.jpg", @"icon2.jpg", @"icon3.jpg", @"icon4.jpg"] fromeWeb:NO];
    //网络
    view = [[ImageScrollView alloc] initWithFrame:CGRectMake(100, 100, 200, 400) images:@[
                                                                                          @"http://store.storeimages.cdn-apple.com/8748/as-images.apple.com/is/image/AppleInc/aos/published/images/H/GD/HGDH2/HGDH2_FV202?wid=1440&hei=1440&fmt=jpeg&qlt=80&op_sharpen=0&resMode=bicub&op_usm=0.5,0.5,0,0&iccEmbed=0&layer=comp&.v=dzql71",
                                                                                          
                                                                                          @"http://store.storeimages.cdn-apple.com/8748/as-images.apple.com/is/image/AppleInc/aos/published/images/M/LL/MLLG2/MLLG2_FV202?wid=1440&hei=1440&fmt=jpeg&qlt=80&op_sharpen=0&resMode=bicub&op_usm=0.5,0.5,0,0&iccEmbed=0&layer=comp&.v=1462234420077",
                                                                                          
                                                                                          @"http://store.storeimages.cdn-apple.com/8748/as-images.apple.com/is/image/AppleInc/aos/published/images/H/F1/HF113/HF113_FV202?wid=1440&hei=1440&fmt=jpeg&qlt=80&op_sharpen=0&resMode=bicub&op_usm=0.5,0.5,0,0&iccEmbed=0&layer=comp&.v=cJAll1",
                                                                                          
                                                                                          @"http://store.storeimages.cdn-apple.com/8748/as-images.apple.com/is/image/AppleInc/aos/published/images/H/JV/HJV72/HJV72_FV202?wid=1440&hei=1440&fmt=jpeg&qlt=80&op_sharpen=0&resMode=bicub&op_usm=0.5,0.5,0,0&iccEmbed=0&layer=comp&.v=IQjlp2"
                                                                                          ]
                                         fromeWeb:YES];
    
    view.showGigImage = YES;
    view.showPageContrl = YES;
    view.timerStart = YES;
    view.currentPageIndicatorTintColor = [UIColor redColor];
    view.pageIndicatorTintColor = [UIColor whiteColor];
    view.circulate = YES;
    
    view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:view];
}

@end
