//
//  ImageScrollView.m
//  Oil
//
//  Created by mac1 on 16/5/16.
//  Copyright © 2016年 jyf. All rights reserved.
//

#import "ImageScrollView.h"
#import "UIView+Category.h"
#import "UIImageView+WebCache.h"
#import "UIGestureRecognizer+BlocksKit.h"

@interface ImageScrollView () <UIScrollViewDelegate>{

    NSTimer *_timer;//定时器，控制图片切换
    UIScrollView *_windowScrollView;//window上的容器；
    UIPageControl *_windowPageControll;//window上的页点
    NSInteger tapDoubleImageIndex;//双击点击的哪一张图片
    NSMutableArray  *windowImages;//保存window上的imageView
}
/** 容器  */
@property (nonatomic, strong) UIScrollView *containerView;
/** 页点  */
@property (nonatomic, strong) UIPageControl *pageControll;
/** 将当前的imageView收集起来，可以设置状态  */
@property (nonatomic, strong) NSMutableArray *icons;

#define Duration 2.5  //定时器时间
#define AnimationDuration 0.3 //window的image双击动画效果
#define MaxZoomScale 2 //最大的放大
#define MinZoomScale 1 //最小的的放大

#define kWeakSelf __weak typeof(self) weakSelf = self;
#define kWindowH   [UIScreen mainScreen].bounds.size.height
#define kWindowW    [UIScreen mainScreen].bounds.size.width

@end

@implementation ImageScrollView


- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images fromeWeb:(BOOL)isWeb{
    
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        
        //初始化
        _count = images.count;
        _images = [NSMutableArray array];
        _showGigImage = YES;
        [_images addObjectsFromArray:images];
        _formeWeb  = isWeb;
        self.showPageContrl = YES;
        self.imageContentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:self.containerView];
        self.containerView.frame = self.bounds;
        self.containerView.contentSize = CGSizeMake(frame.size.width * _count, 0);
        if (isWeb) {
            [self setWebImages];
        }else{
            [self setLocationImages];
        }
    }
    return self;
}


- (void)openTimer{
    if (self.timerStart) {
        [self timeBegain];
    }
}

- (void)closeTimer{
    [self timeCancle];
}

- (void)setShowGigImage:(BOOL)showGigImage{
    _showGigImage = showGigImage;
    
    if (showGigImage) {
        for (UIImageView *imageView in self.icons) {
            imageView.userInteractionEnabled = YES;
        }
    }else{//不能点击肯定是不能显示的
        for (UIImageView *imageView in self.icons) {
            imageView.userInteractionEnabled = NO;
        }
    }
}

- (void)setCirculate:(BOOL)circulate{
    _circulate = circulate;
    
    if (_circulate) {
        //1.scrollView.offSize.width =+ 2 * width;
        //2.在第一个image中添加view
        _containerView.contentSize = CGSizeMake( (self.count + 2) * kWindowW, 0);
        CGFloat width = _containerView.width;
        CGFloat height = _containerView.height;
        _containerView.contentOffset = CGPointMake(width, 0);
        _pageControll.currentPage = 0;

        for(int i = 0; i < self.count + 2; i ++){
            
            if (i == 0) {
                UIImageView *lastImageView = [[UIImageView alloc] init];
                lastImageView.contentMode = self.imageContentMode;//填充整个frame
                if (self.formeWeb) {
                    [lastImageView sd_setImageWithURL:[NSURL URLWithString:_images.lastObject]];
                }else{
                    lastImageView.image = [UIImage imageNamed:_images.lastObject];
                }
                [_containerView addSubview:lastImageView];
                lastImageView.frame = CGRectMake(0, 0, width, height);
            }
            else if (i == self.count + 1) {
                UIImageView *firstImageView = [[UIImageView alloc] init];
                firstImageView.contentMode = self.imageContentMode;//填充整个frame
                if (self.formeWeb) {
                    [firstImageView sd_setImageWithURL:[NSURL URLWithString:_images.firstObject]];
                }else{
                    firstImageView.image = [UIImage imageNamed:_images.firstObject];
                }
                [_containerView addSubview:firstImageView];
                firstImageView.frame = CGRectMake(width * self.count + width, 0, width, height);
                continue;
            }
            else {
            UIImageView *icon = self.icons[i-1];
            icon.frame = CGRectMake(width * i, 0, width, height);
            }
        }
    }
}

- (void)setTimerStart:(BOOL)timerStart{
    _timerStart = timerStart;
    
    if (_timerStart) {
        [self timeBegain];
    }else{
        [self timeCancle];
    }
}

- (void)setShowPageContrl:(BOOL)showPageContrl{
    _showPageContrl = showPageContrl;
    
    if (_showPageContrl) {
        self.pageControll.alpha = 1;
    }else{
        self.pageControll.alpha = 0;
    }
}

- (void)setImageContentMode:(UIViewContentMode)imageContentMode{
    _imageContentMode = imageContentMode;
    
    for (UIImageView *imageView in self.icons) {
        imageView.contentMode = imageContentMode;
    }
}



#pragma mark - private methed

- (void)timeBegain{
    
    if (self.timerStart) {
        [self timeCancle];
        _timer = [NSTimer timerWithTimeInterval:Duration target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)timeCancle{
    [_timer invalidate];
}

- (void)updateTimer
{
    //默认向右切换
    CGFloat location = self.containerView.contentOffset.x;
    NSInteger index  = location / self.containerView.frame.size.width;

    if (!self.isCirculate) {
        if (index == _count - 1)
            index = 0;
        else
            index++;
    }
    
    else {
        if (index == _count + 1)
            index = 1;
        else
            index++;
    }

    
    [self.containerView setContentOffset:CGPointMake(self.containerView.frame.size.width * index, 0) animated:YES];
}

- (void)setWebImages{
    
    [self.icons removeAllObjects];

    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    for(int i = 0; i < _count; i ++){
        UIImageView *icon = [[UIImageView alloc] init];
        icon.userInteractionEnabled = YES;
        icon.contentMode = UIViewContentModeScaleAspectFit;//填充整个frame
        [icon sd_setImageWithURL:[NSURL URLWithString:self.images[i]]];
        icon.frame = CGRectMake(i * width, 0, width, height);
        [self.containerView addSubview:icon];
        
        if (_showGigImage) {
            kWeakSelf
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
                
                [weakSelf timeCancle];
                [weakSelf createImageScroolViewInWindow];
                [weakSelf showInImageOfIndex:i];
                
                //传递点击事件
                if ([self.delegate respondsToSelector:@selector(imageScrollViewDidTapImage:)]) {
                    [self.delegate imageScrollViewDidTapImage:i];
                }
            }];
            [icon addGestureRecognizer:tap];
            tap.numberOfTapsRequired = 1;
        }
        
        [self.icons addObject:icon];
    }
    
    [self addSubview:self.pageControll];
    self.pageControll.frame = CGRectMake(0, 0, _count * 10 + 5, 10);
    self.pageControll.center = self.containerView.center;
    self.pageControll.y = self.containerView.frame.size.height - 20;
}


- (void)setLocationImages{
    
    [self.icons removeAllObjects];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    for(int i = 0; i < _count; i ++){
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_images[i]]];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.frame = CGRectMake(i * width, 0, width, height);
        icon.userInteractionEnabled = YES;
        [self.containerView addSubview:icon];
        NSLog(@"icon frame - %@", NSStringFromCGRect(icon.frame));
        if (_showGigImage) {
            kWeakSelf
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
                [weakSelf timeCancle];
                [weakSelf createImageScroolViewInWindow];
                [weakSelf showInImageOfIndex:i];

                //传递点击事件
                if ([self.delegate respondsToSelector:@selector(imageScrollViewDidTapImage:)]) {
                    [self.delegate imageScrollViewDidTapImage:i];
                }
            }];
            [icon addGestureRecognizer:tap];
            tap.numberOfTapsRequired = 1;
        }
        
        [self.icons addObject:icon];
    }
    
    [self addSubview:self.pageControll];
    self.pageControll.frame = CGRectMake(0, 0, _count * 10 + 5, 10);
    self.pageControll.center = self.containerView.center;
    self.pageControll.y = self.containerView.frame.size.height - 20;
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor{
    _pageControll.pageIndicatorTintColor = pageIndicatorTintColor;
    _windowPageControll.pageIndicatorTintColor = pageIndicatorTintColor;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor{
    _pageControll.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    _windowPageControll.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    for (UIImageView *imageView in self.icons) {
        NSLog(@"icon frame - %@", NSStringFromCGRect(imageView.frame));
        NSLog(@"image frame - %@", NSStringFromCGSize(imageView.image.size));
    }
}


#pragma mark - 下面开始就是关于 模仿微信图片轮播器的设置了-----点击图片后图片，放大显示在整个界面的，背景黑色，模仿微信的图片轮播器。Image的等比例缩放
/**
 单击：缩小；
 双击：扩大；
 捏合：放大；
 */

/**
 * 初始化图片轮播器View(image等比例显示 UIViewContentMode = UIViewContentModeScaleAspectFit)
 */
- (void)createImageScroolViewInWindow{
    
    CGRect defaultFrame = CGRectMake(0, 0, kWindowW, kWindowH);
    _windowScrollView = [[UIScrollView alloc] init];
    _windowScrollView.delegate = self;
    _windowScrollView.backgroundColor = [UIColor blackColor];
    
    [_windowScrollView setMaximumZoomScale:2.0];
    [_windowScrollView setMinimumZoomScale:1.0];
    
    // 设置滚动视图不可以弹跳
    _windowScrollView.bounces = NO;
    // 设置滚动视图整页滚动
    _windowScrollView.pagingEnabled = YES;
    // 设置滚动视图的水平、垂直滚动提示不可见
    _windowScrollView.showsHorizontalScrollIndicator = NO;
    _windowScrollView.showsVerticalScrollIndicator = NO;
    _windowScrollView.frame = defaultFrame;
    _windowScrollView.contentSize = CGSizeMake(defaultFrame.size.width * _count, _windowScrollView.size.height);
    
    _windowPageControll = [[UIPageControl alloc] init];
    _windowPageControll.numberOfPages = _count;
    _windowPageControll.hidesForSinglePage = YES;
    _windowPageControll.currentPageIndicatorTintColor = _currentPageIndicatorTintColor;
    _windowPageControll.pageIndicatorTintColor = _pageIndicatorTintColor;
    //默认取消用户交互功能
    _windowPageControll.userInteractionEnabled = YES;
    _windowPageControll.frame = CGRectMake(0, 0, _count * 10 + 5, 10);
    _windowPageControll.center = _windowScrollView.center;
    _windowPageControll.y = _windowScrollView.frame.size.height - 40;
    
    
    windowImages = [NSMutableArray array];
    
    if (_formeWeb) {
        [self setWebImagesInWindow];
    }else{
        [self setLocationImagesInWindow];
    }
}


/**
 *  显示图片轮播器，并且显示的是点击的那张图片
 *
 *  @param index 从第index张图片开始显示,0是第一张
 */
- (void)showInImageOfIndex:(NSUInteger)index{
    
    _windowScrollView.contentOffset = CGPointMake(_windowScrollView.frame.size.width * index, 0);
    _windowPageControll.currentPage = index;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:_windowScrollView];
    [keyWindow addSubview:_windowPageControll];
    _windowScrollView.alpha = 0.9;
    _windowPageControll.alpha = 0.9;
    [UIView animateWithDuration:0.5 animations:^{
        _windowScrollView.alpha = 1;
        _windowPageControll.alpha = 1;
    }];
}


/**
 *  隐藏大的轮播器
 */
- (void)hide{

    kWeakSelf
    [UIView animateWithDuration:0.5 animations:^{
        _windowScrollView.alpha = 0;
        _windowPageControll.alpha = 0;
    } completion:^(BOOL finished) {
        
        [_windowPageControll removeFromSuperview];
        [_windowScrollView removeFromSuperview];
        [weakSelf timeBegain];
    }];
}

- (void)setWebImagesInWindow{
    
    kWeakSelf
    
    CGFloat width = _windowScrollView.frame.size.width;
    CGFloat height = _windowScrollView.frame.size.height;
    for(int i = 0; i < _count; i ++){
        
        UIScrollView *imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 300, 400)];   //添加一个UIView
        
        [_windowScrollView addSubview:imageScrollView];
        imageScrollView.delegate = self;                                   //实现Scrollview的代理，需要在.h 文件中添加
        imageScrollView.showsHorizontalScrollIndicator=NO;
        imageScrollView.showsVerticalScrollIndicator=NO;
        imageScrollView.bounces=NO;
        imageScrollView.bouncesZoom=NO;
        imageScrollView.minimumZoomScale=0.5;
        imageScrollView.maximumZoomScale=2;
        imageScrollView.contentSize = CGSizeMake(300 , 400);
        imageScrollView.frame = CGRectMake(i * width, 0, width, height);
        imageScrollView.delegate = self;
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            tapDoubleImageIndex = i;
            float offX = kWindowW/2 + (location.x - imageScrollView.width/2);
            float offY = kWindowH/2 + (location.y - imageScrollView.height/2);
            CGPoint offPoint = CGPointMake(offX > 0 ? offX : 0, offY > 0 ? offY : 0);
            
            if (imageScrollView.zoomScale > 1) {
                [UIView animateWithDuration:AnimationDuration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    [imageScrollView setZoomScale:MinZoomScale];
                    [imageScrollView setContentOffset:CGPointZero];
                } completion:nil];
            }else{
                [UIView animateWithDuration:AnimationDuration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    [imageScrollView setZoomScale:MaxZoomScale];
                    [imageScrollView setContentOffset:offPoint];
                } completion:nil];
            }
        }];
        doubleTap.numberOfTapsRequired = 2;
        [imageScrollView addGestureRecognizer:doubleTap];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            [weakSelf hide];
            [weakSelf.containerView setContentOffset:CGPointMake(weakSelf.containerView.frame.size.width *  (weakSelf.isCirculate ? i+1 : i), 0) animated:NO];
            weakSelf.pageControll.currentPage = i;
            
        }];
        singleTap.numberOfTapsRequired = 1;
        [imageScrollView addGestureRecognizer:singleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];  //当判断双击失效后才进行单击
        
        //scrollview上添加图片
        UIImageView *icon = [[UIImageView alloc] init];
        [icon sd_setImageWithURL:self.images[i]];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.frame = CGRectMake(0, 0, width, height);
        icon.backgroundColor = [UIColor blackColor];
        icon.userInteractionEnabled = NO;
        [windowImages addObject:icon];
        
        [imageScrollView addSubview:icon];
    }
}

- (void)setLocationImagesInWindow{
    
    kWeakSelf

    CGFloat width = _windowScrollView.frame.size.width;
    CGFloat height = _windowScrollView.frame.size.height;
    for(int i = 0; i < _count; i ++){
        
        UIScrollView *imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 300, 400)];   //添加一个UIView
        
        [_windowScrollView addSubview:imageScrollView];
        imageScrollView.delegate = self;                                   //实现Scrollview的代理，需要在.h 文件中添加
        imageScrollView.showsHorizontalScrollIndicator=NO;
        imageScrollView.showsVerticalScrollIndicator=NO;
        imageScrollView.bounces=NO;
        imageScrollView.bouncesZoom=NO;
        imageScrollView.minimumZoomScale=0.5;
        imageScrollView.maximumZoomScale=2;
        imageScrollView.contentSize = CGSizeMake(300 , 400);
        imageScrollView.frame = CGRectMake(i * width, 0, width, height);
        imageScrollView.delegate = self;
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            tapDoubleImageIndex = i;
            float offX = kWindowW/2 + (location.x - imageScrollView.width/2);
            float offY = kWindowH/2 + (location.y - imageScrollView.height/2);
            CGPoint offPoint = CGPointMake(offX > 0 ? offX : 0, offY > 0 ? offY : 0);
            
            if (imageScrollView.zoomScale > 1) {
                [UIView animateWithDuration:AnimationDuration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    [imageScrollView setZoomScale:MinZoomScale];
                    [imageScrollView setContentOffset:CGPointZero];
                } completion:nil];
            }else{
                [UIView animateWithDuration:AnimationDuration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    [imageScrollView setZoomScale:MaxZoomScale];
                    [imageScrollView setContentOffset:offPoint];
                } completion:nil];
            }
        }];
        doubleTap.numberOfTapsRequired = 2;
        [imageScrollView addGestureRecognizer:doubleTap];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            [weakSelf hide];
            [weakSelf.containerView setContentOffset:CGPointMake(weakSelf.containerView.frame.size.width * (weakSelf.isCirculate ? i+1 : i), 0) animated:NO];
            weakSelf.pageControll.currentPage =  i;
        }];
        singleTap.numberOfTapsRequired = 1;
        [imageScrollView addGestureRecognizer:singleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];  //当判断双击失效后才进行单击
        
        //scrollview上添加图片
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_images[i]]];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.frame = CGRectMake(0, 0, width, height);
        icon.backgroundColor = [UIColor blackColor];
        icon.userInteractionEnabled = NO;
        [windowImages addObject:icon];
        
        [imageScrollView addSubview:icon];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{

    /** 修改pageControll  */
    CGPoint movePoint = scrollView.contentOffset;
    CGFloat index = movePoint.x/scrollView.frame.size.width;
    if (scrollView == self.containerView){
        int page = (int)(index+0.5);
        if (self.circulate) {
            if (page == 0){
                page = (int)self.count + 1;
                [_containerView setContentOffset:CGPointMake(_containerView.width * self.count , 0) animated:NO];
            }
            else if (page == self.count + 1){
                page = 0;
                [_containerView setContentOffset:CGPointMake(_containerView.width , 0) animated:NO];
            }
            else
                page --;
        }
        self.pageControll.currentPage = page;
    }
    else if (scrollView == _windowScrollView)
        _windowPageControll.currentPage =(int)(index+0.5);
    else
        return;
    
    /** 方法代理  */
    if (self.pageControll.currentPage == self.count - 1) {
        if ([self.delegate respondsToSelector:@selector(imageScrollViewDidAppearWhenEnterLastImage:)]) {
            [self.delegate imageScrollViewDidAppearWhenEnterLastImage:self];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(imageScrollViewDidDisAppearWhenEnterLastImage:)]) {
            [self.delegate imageScrollViewDidDisAppearWhenEnterLastImage:self];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    /** 修改pageControll  */
    CGPoint movePoint = scrollView.contentOffset;
    CGFloat index = movePoint.x/scrollView.frame.size.width;
    if (scrollView == self.containerView){
        int page = (int)(index+0.5);
        if (self.circulate) {
            if (page == 0){
                page = (int)self.count + 1;
                [_containerView setContentOffset:CGPointMake(_containerView.width * self.count, 0) animated:NO];
            }
            else if (page == self.count + 1){
                page = 0;
                [_containerView setContentOffset:CGPointMake(_containerView.width , 0) animated:NO];
            }
            else
                page --;
        }
        self.pageControll.currentPage = page;
    }
//    if (scrollView == self.containerView)
//        self.pageControll.currentPage =(int)(index+0.5);
    else if (scrollView == _windowScrollView)
        _windowPageControll.currentPage =(int)(index+0.5);
    else
        return;
    
    /** 方法代理  */
    if (self.pageControll.currentPage == self.count - 1) {
        if ([self.delegate respondsToSelector:@selector(imageScrollViewDidAppearWhenEnterLastImage:)]) {
            [self.delegate imageScrollViewDidAppearWhenEnterLastImage:self];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(imageScrollViewDidDisAppearWhenEnterLastImage:)]) {
            [self.delegate imageScrollViewDidDisAppearWhenEnterLastImage:self];
        }
    }
    
}

#pragma mark - UIScrollViewDelegate（和widow大图的缩放有关）
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)tmpScrollView
{
    if (tmpScrollView != self.containerView  && tmpScrollView != _containerView) {
        return windowImages[tapDoubleImageIndex];
    }
    return nil;
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    if (scale < 1) {
        [scrollView setZoomScale:1 animated:YES];
    }
}



#pragma mark - lazy load
- (UIScrollView *)containerView {
    if(_containerView == nil) {
        _containerView = [[UIScrollView alloc] init];
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.delegate = self;
        // 设置滚动视图不可以弹跳
        _containerView.bounces = NO;
        // 设置滚动视图整页滚动
        _containerView.pagingEnabled = YES;
        // 设置滚动视图的水平、垂直滚动提示不可见
        _containerView.showsHorizontalScrollIndicator = NO;
        _containerView.showsVerticalScrollIndicator = NO;
    }
    return _containerView;
}

- (UIPageControl *)pageControll {
    if(_pageControll == nil) {
        _pageControll = [[UIPageControl alloc] init];
        _pageControll.numberOfPages = _count;
        _pageControll.hidesForSinglePage = YES;
        _pageControll.currentPageIndicatorTintColor = [UIColor redColor];
        _pageControll.pageIndicatorTintColor = [UIColor whiteColor];
        //取消用户交互功能
        _pageControll.userInteractionEnabled = YES;
    }
    return _pageControll;
}

- (NSMutableArray *)icons {
	if(_icons == nil) {
		_icons = [NSMutableArray array];
	}
	return _icons;
}

@end
