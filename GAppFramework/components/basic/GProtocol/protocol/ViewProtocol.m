//
//  ProtocolExtend.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/15.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "ViewProtocol.h"
#import "ProtocolExtend.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

////////////////////////////////////////////////////////////////////////////////
#pragma mark - SZSViewDelegate
////////////////////////////////////////////////////////////////////////////////

@defs(GSViewDelegate)

- (UIScrollView *)scro {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setScro:(UIScrollView *)scro {
    objc_setAssociatedObject(self, @selector(scro), scro, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<NSString *> *)vdViewsArray {
    return @[];
}

- (CGFloat)vdPadding:(NSInteger)idx {
    return 0;
}

- (void)vdAddViews {
    if (![self respondsToSelector:@selector(vdViewsArray)]) return;
    UIView *view;
    
    if ([self isKindOfClass:[UIView class]]) {
        view = (UIView *)self;
    } else if ([self isKindOfClass:[UIViewController class]]) {
        view = [(UIViewController *)self view];
    } else return;
    BOOL isvc = [self isKindOfClass:[UIViewController class]];
    
    self.scro = [UIScrollView new];
    self.scro.scrollEnabled = YES;
    self.scro.alwaysBounceVertical = YES;
    self.scro.frame = view.bounds;
    
    [view addSubview:self.scro];
    [self.scro mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(view);
        if (isvc) make.bottom.equalTo([(UIViewController *)self mas_bottomLayoutGuideTop]);
        else make.bottom.equalTo([(UIView *)self mas_bottom]);
    }];
    
    UIView *con = [UIView new];
    con.userInteractionEnabled = YES;
    con.tag = 19910222;
    [self.scro addSubview:con];
    @weakify(self);
    [con mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self.scro);
    }];
    
    NSMutableArray *arr = @[].mutableCopy;
    
    [[self vdViewsArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BOOL isStr = [obj isKindOfClass:NSString.class];
        Class cls = NSClassFromString(isStr ? obj : obj[@"view"]);
        if ([cls conformsToProtocol:@protocol(ViewDelegate)]) {
            @strongify(self);
            id model = isStr ? ([self respondsToSelector:@selector(vdModel:)] ? [self vdModel:idx] : nil) : obj;
            UIView *temp = [(id<ViewDelegate>)cls viewWithModel:model action:^(RACTuple *tuple) {
                @strongify(self);
                if ([self respondsToSelector:@selector(vdTapAction:)]) [self vdTapAction:tuple];
            }];
            if ([self respondsToSelector:@selector(vdUIData:)] && [temp respondsToSelector:@selector(viewUIModel:)]) {
                [(id<ViewDelegate>)temp viewUIModel:[self vdUIData:idx]];
            }
            if (temp) {
                view.userInteractionEnabled = YES;
                [con addSubview:temp];
                [arr addObject:temp];
            }
        }
    }];
    [arr enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        UIView *preObj = idx==0 ? nil : arr[idx-1];
        [obj mas_updateConstraints:^(MASConstraintMaker *make) {
            CGFloat padding = [(id<GSViewDelegate>)self vdPadding:idx];
            make.top.equalTo(preObj?preObj.mas_bottom:con.mas_top).offset(padding);
            make.left.equalTo(con.mas_left);
            make.right.equalTo(con.mas_right);
            make.width.equalTo(@([UIScreen mainScreen].bounds.size.width));
            if (idx==(arr.count-1)) {
                make.bottom.equalTo(con.mas_bottom).offset(-30);
            }
        }];
    }];
}

- (void)vdUpdateLayout {
    UIView *con = [self.scro viewWithTag:19910222];
    [con.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj conformsToProtocol:@protocol(ViewDelegate)] &&
            [obj respondsToSelector:@selector(viewAction:)]) {
            id data = [self respondsToSelector:@selector(vdModel:)] ? [self vdModel:idx] : [RACTupleNil tupleNil];
            [(id<ViewDelegate>)obj viewAction:RACTuplePack(@"updateLayout", data)];
        }
    }];
    [self.scro.superview layoutIfNeeded];
}

@end

