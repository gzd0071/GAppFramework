//
//  DMHHotCell.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/21.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMHHotCell.h"
#import "DMHListModel.h"
#import <GBaseLib/GConvenient.h>

@interface DMHHotCell ()
///>  
@property (nonatomic, strong) NSMutableArray<UIButton *> *btns;
///>  
@property (nonatomic, strong) NSIndexPath *path;
///> 视图: 关闭 
@property (nonatomic, strong) UIImageView *close;
///>  
@property (nonatomic, copy) AActionBlock actionBlock;
///>  
@property (nonatomic, strong) id model;
@end

@implementation DMHHotCell

#pragma mark - DATA
///=============================================================================
/// @name DATA
///=============================================================================

- (void)viewModel:(RACTuple *)x action:(nullable AActionBlock)action {
    DMHPanelModel *model = x.first;
    _model = model;
    _path = x.second;
    _actionBlock = action;
    
    if (self.actionBlock) self.actionBlock(RACTuplePack(@"exposure", self.model, self.path, model.list[0], @0));
    
    [self addItems:model.list];
}

#pragma mark - Instance
///=============================================================================
/// @name Instance
///=============================================================================

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = HEX(@"f7f7f7", @"000000");
        self.btns = @[].mutableCopy;
        [self.contentView addSubview:[self hot]];
        
        _close = [[UIImageView alloc] initWithImage:IMAGE(@"home_close")];
        [self.contentView addSubview:self.close];
        @weakify(self);
        _close.frame = CGRectMake(SCREEN_WIDTH-36, 16, 20, 14);
        [_close addTapGesture:^(id x) {
            @strongify(self);
            if (self.actionBlock) self.actionBlock(RACTuplePack(@"interest", self.path, @38, self.model));
        }];
    }
    return self;
}

#pragma mark - GETTER
///=============================================================================
/// @name GETTER
///=============================================================================

- (UIImageView *)hot {
    UIImageView *tag = [[UIImageView alloc] initWithImage:IMAGE(@"home_hot")];
    tag.frame = CGRectMake(16, 30, 40, 40);
    return tag;
}

- (void)addItems:(NSArray<DMHHot *> *)array  {
    @weakify(self);
    [array enumerateObjectsUsingBlock:^(DMHHot *obj, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        UIButton *btn;
        if (idx < self.btns.count) {
            btn = self.btns[idx];
            [btn setTitle:obj.word forState:UIControlStateNormal];
        } else {
            btn = [self btn:obj.word];
            CGFloat w = (SCREEN_WIDTH - 68)/4;
            CGFloat x = ((idx+1)%4)*(w+12) + ((idx<3)?(56-w):12);
            CGFloat y = ((idx+1)/4)*56 + 30;
            btn.frame = CGRectMake(x, y, w, 40);
            [self.contentView addSubview:btn];
            [self.btns addObject:btn];
        }
        [btn addTapGesture:^{
            if (self.actionBlock) self.actionBlock(RACTuplePack(@"hot", obj, self.path, self.model));
        }];
        NSInteger tag = 1234;
        if (obj.isHot && ![btn viewWithTag:tag]) {
            UIImageView *hot = [[UIImageView alloc] initWithImage:IMAGE(@"home_hottag")];
            hot.frame = CGRectMake(63, -4, 22, 12);
            hot.tag = tag;
            [btn addSubview:hot];
        } else if (!obj.isHot && [btn viewWithTag:tag]) {
            [[btn viewWithTag:tag] removeFromSuperview];
        }
    }];
    NSArray *mut = self.btns.copy;
    for (NSInteger i=array.count; i<mut.count; i++) {
        UIButton *btn = mut[i];
        [btn removeFromSuperview];
        [self.btns removeObject:btn];
    }
}

- (UIButton *)btn:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = 2;
    btn.clipsToBounds = NO;
    btn.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    btn.titleLabel.font = FONT(14);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:HEX(@"404040", @"dddddd") forState:UIControlStateNormal];
    return btn;
}

@end
