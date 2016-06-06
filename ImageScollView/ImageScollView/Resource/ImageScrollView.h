//
//  ImageScrollView.h
//  Oil
//
//  Created by mac1 on 16/5/16.
//  Copyright © 2016年 jyf. All rights reserved.
//  图片轮播器

#import <UIKit/UIKit.h>
#import "UIView+Category.h"
#import "UIImageView+WebCache.h"
#import "UIGestureRecognizer+BlocksKit.h"

@class ImageScrollView;

@protocol ImageScrollViewDelegate <NSObject>

@optional

/**
 *  最后的一张iamge的显示时候
 *
 *  @param imageScrollView 
 */
- (void)imageScrollViewDidAppearWhenEnterLastImage:(ImageScrollView *)imageScrollView ;
/**
 *  最后的一张iamge的消失时候
 *
 *  @param imageScrollView 
 */
- (void)imageScrollViewDidDisAppearWhenEnterLastImage:(ImageScrollView *)imageScrollView;

/**
 *  点击图片时响应
 *
 *  @param index 点击的图片下标，第一张为0
 */
- (void)imageScrollViewDidTapImage:(NSInteger)index;

@end


@interface ImageScrollView : UIView

/**
 *  初始化图片轮播器View(image：填充)
 *
 *  @param frame  frame
 *  @param images 一个图片的数组（NSString地址 或 本地image）
 *  @param isWeb  图片是否是来自数据请求： YES：是网络请求；  NO：本地图片
 *
 *  @return 返回ImageScrollView对象
 */
- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images fromeWeb:(BOOL)isWeb;


@property (nonatomic, weak) id<ImageScrollViewDelegate> delegate;

/** 是否显示PageContrl （默认YES）  */
@property (nonatomic)BOOL showPageContrl;
/** 时间控制器是否开启（默认关闭）  */
@property (nonatomic, assign) BOOL timerStart;
/** 点击图片后能否显示大的滚动图片(默认Yes)  */
@property (nonatomic, getter=canShowGigImage)BOOL showGigImage;



/** images 一个图片的数组（Web:NSString 或 本地:image）  */
@property (nonatomic, strong, readonly) NSMutableArray *images;
/** 图片数量  */
@property (nonatomic, assign, readonly) NSInteger count;
/** 是否来自web  */
@property (nonatomic, readonly, getter=isFormeWeb) BOOL formeWeb;
/** 当前页点的颜色  */
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;
/** 未选择页点的颜色  */
@property (nonatomic, strong) UIColor *pageIndicatorTintColor;




@end
