//
//  GRefreshHeader.m
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/9/7.
//

#import "GRefreshHeader.h"

@interface GRefreshHeader()
///>  
@property (nonatomic, strong) UIImageView *img;
@end

@implementation GRefreshHeader

- (void)prepare {
    [super prepare];
    self.mj_h = MJRefreshHeaderHeight;

    self.img = [UIImageView new];
    self.img.image = [UIImage imageNamed:@"loading"];
    [self addSubview:self.img];
}

- (void)placeSubviews {
    [super placeSubviews];
    self.img.frame = CGRectMake(self.bounds.size.width/2.0-11, self.bounds.size.height/2-11, 22, 22);
}

- (void)setPullingPercent:(CGFloat)pullingPercent {
    [super setPullingPercent:pullingPercent];
    if (self.state != MJRefreshStateIdle || !self.img) return;
}

- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState
    if (state == MJRefreshStateRefreshing) {
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
        rotationAnimation.duration = 0.8;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = MAXFLOAT;
        rotationAnimation.removedOnCompletion = NO;
        [self.img.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
}

@end
