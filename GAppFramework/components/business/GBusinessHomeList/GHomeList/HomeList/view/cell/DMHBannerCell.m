//
//  DMHBannerCell.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/7/1.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMHBannerCell.h"
#import <GBaseLib/iCarousel.h>
#import <SMPageControl/SMPageControl.h>
#import "DMHListModel.h"
#import <GBaseLib/GConvenient.h>


#define kMER_WIDTH 120
#define kMER_PAD   12

@interface DMHBannerCell()<iCarouselDelegate, iCarouselDataSource>
///>  
@property (nonatomic, copy) AActionBlock actionBlock;
///> 
@property (nonatomic, strong) DMHPanelModel<DMHBannerItem *> *model;
///>  
@property (nonatomic, strong) NSIndexPath *path;

///> 视图: 标题 
@property (nonatomic, strong) UILabel *title;
///> 视图: 关闭 
@property (nonatomic, strong) UIImageView *close;
///> 视图: 底线 
@property (nonatomic, strong) UIView *line;
///>  
@property (nonatomic, strong) UILabel *brandName;
///>  
@property (nonatomic, strong) UILabel *brand;

///> 标题/内容 
@property (nonatomic, strong) iCarousel *icarousel;
///>  
@property(nonatomic, strong) SMPageControl *pageControl;
@end

@implementation DMHBannerCell

#pragma mark - DATA
///=============================================================================
/// @name DATA
///=============================================================================

- (void)viewModel:(RACTuple *)x action:(nullable AActionBlock)action {
    DMHPanelModel *model = x.first;
    _model = model;
    _path = x.second;
    _actionBlock = action;
    
    if (self.actionBlock) self.actionBlock(RACTuplePack(@"exposure", self.model, self.path, self.model.list[0], @(0)));
    
    _brandName.hidden = _brand.hidden = _model.list[0].type == 1;
    _brandName.text = _model.list[0].brandName;
    
    _line.frame = CGRectMake(16, model.cellHeight-0.5, SCREEN_WIDTH-32, HALFPixal);
    _brand.frame = CGRectMake(SCREEN_WIDTH-40, self.model.cellHeight-28, 26, 12);
    _brandName.frame = CGRectMake(16, self.model.cellHeight-28, SCREEN_WIDTH-76, 12);
    
    _icarousel.scrollEnabled = _model.list.count > 1;
    _line.hidden = (_path.row == REFRESH_POSITION);
    _pageControl.numberOfPages = _model.list.count;
    if (model.list.count>=1) _title.text = _model.list[0].title;
    [_icarousel reloadData];
}

#pragma mark - Instance
///=============================================================================
/// @name Instance
///=============================================================================

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        self.clipsToBounds = YES;
        [self addViews];
    }
    return self;
}

- (void)addViews {
    self.title = [self createLabel];
    self.brandName = [self createLightLabel];
    self.brand = [self createLightLabel];
    self.brand.text = @"广告";
    self.line  = [self createLine:HEX(@"e5e5e5", @"303033")];
    self.close = [[UIImageView alloc] initWithImage:IMAGE(@"home_close")];
    @weakify(self);
    [self.close addTapGesture:^(id x) {
        @strongify(self);
        if (self.actionBlock) self.actionBlock(RACTuplePack(@"interest", self.path, @42, self.model));
    }];
    [self.contentView addSubview:self.title];
    [self.contentView addSubview:self.close];
    [self.contentView addSubview:self.line];
    [self.contentView addSubview:self.icarousel];
    [self.contentView addSubview:self.pageControl];
    [self.contentView addSubview:self.brandName];
    [self.contentView addSubview:self.brand];
    
    _title.frame = CGRectMake(16, 20, SCREEN_WIDTH-68, 18);
    _close.frame = CGRectMake(SCREEN_WIDTH-36, 22, 20, 14);
}

#pragma mark - Carousel delegate
///=============================================================================
/// @name Carousel delegate
///=============================================================================

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return self.model.list.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index
         reusingView:(UIImageView *)view {
    if (!view) view = [[UIImageView alloc] initWithFrame:carousel.bounds];
    [view setImageWithURL:[NSURL URLWithString:self.model.list[index].image]];
    @weakify(self);
    [view addTapGesture:^{
        @strongify(self);
        if (self.actionBlock) self.actionBlock(RACTuplePack(@"banner", self.model.list[index], self.model));
    }];
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    if (option == iCarouselOptionWrap) return YES;
    return value;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    _pageControl.currentPage = carousel.currentItemIndex;
    _title.text = self.model.list[carousel.currentItemIndex].title;
    if (self.actionBlock) self.actionBlock(RACTuplePack(@"exposure", self.model, self.path, self.model.list[carousel.currentItemIndex], @(_pageControl.currentPage)));
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (self.actionBlock) {
        self.actionBlock(RACTuplePack(@"banner", self.model.list[index]));
    }
}


#pragma mark - Action
///=============================================================================
/// @name Action
///=============================================================================

- (void)pageControlTap {
    [_icarousel scrollToItemAtIndex:_pageControl.currentPage animated:YES];
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (UILabel *)createLabel {
    UILabel *label = [UILabel new];
    label.font = FONT_BOLD(16);
    label.textColor = HEX(@"404040", @"dddddd");
    return label;
}

- (UILabel *)createLightLabel {
    UILabel *label = [UILabel new];
    label.font = FONT(12);
    label.textColor = HEX(@"999999", @"989899");
    return label;
}

- (UIView *)createLine:(UIColor *)color {
    UIView *view = [UIView new];
    view.backgroundColor = color;
    return view;
}

#pragma mark - ScrollDelegate
///=============================================================================
/// @name ScrollDelegate
///=============================================================================

- (UIImage *)roundRectWithRadius:(CGFloat)r width:(CGFloat)w height:(CGFloat)h color:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, w, h);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 2.0);
    [[UIBezierPath bezierPathWithRoundedRect:rect
                                cornerRadius:r] addClip];
    [image drawInRect:rect];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (iCarousel *)icarousel {
    if (!_icarousel) {
        _icarousel = [[iCarousel alloc] initWithFrame:CGRectMake(16, 56, SCREEN_WIDTH-32, (SCREEN_WIDTH-32)*133.0/343)];
        _icarousel.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        _icarousel.type = iCarouselTypeLinear;
        _icarousel.delegate = self;
        _icarousel.dataSource = self;
        _icarousel.pagingEnabled = YES;
        _icarousel.bounceDistance = .2;
        _icarousel.clipsToBounds = YES;
    }
    return _icarousel;
}

- (SMPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[SMPageControl alloc] init];
        _pageControl.frame = CGRectMake(0, 0, SCREEN_WIDTH-48, 12);
        _pageControl.center = CGPointMake(SCREEN_WIDTH/2, self.icarousel.bottom-8);
        _pageControl.indicatorDiameter = 8;
        _pageControl.indicatorMargin = 5;
        _pageControl.alignment = SMPageControlAlignmentRight;
        _pageControl.hidesForSinglePage = YES;
        
        [_pageControl setCurrentPageIndicatorImage:[self roundRectWithRadius:2.5 width:15 height:5 color:HEX(@"FFD630", @"ffbb00")]];
        [_pageControl setPageIndicatorImage:[self roundRectWithRadius:2.5 width:15 height:5 color:HEX(@"e2e6e9")]];
        [_pageControl addTarget:self action:@selector(pageControlTap) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}

@end

