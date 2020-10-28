//
//  DMDingyueCell.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/9/3.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMDingyueCell.h"
#import "DMHListModel.h"
#import <GBaseLib/GConvenient.h>

@interface DMDingyueCell()
///> 
@property (nonatomic, strong) UIImageView *img;
///>  
@property (nonatomic, strong) AActionBlock action;
@end

@implementation DMDingyueCell

#pragma mark - Data
- (void)viewModel:(RACTuple *)x action:(nullable AActionBlock)action {
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
        [self addViews];
    }
    return self;
}

- (void)addViews {
    self.img       = [UIImageView new];
    self.img.frame = CGRectMake(16, 12, SCREEN_WIDTH-32, (SCREEN_WIDTH-32) * 0.1);
    self.img.image = IMAGE(@"home_dingyue");
    [self.contentView addSubview:self.img];
}

@end
