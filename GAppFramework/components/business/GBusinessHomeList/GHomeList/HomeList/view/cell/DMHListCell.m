//
//  DMHListCell.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/19.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMHListCell.h"
#import "DMHListModel.h"
#import "DMHFilterModel.h"
#import <GBaseLib/GConvenient.h>
#import <ReactiveObjC/RACSignal+Operations.h>
#import <ReactiveObjC/UITableViewCell+RACSignalSupport.h>
#import <ReactiveObjC/NSObject+RACPropertySubscribing.h>

@interface DMHListCell()
///> 位置信息 
@property (nonatomic, strong) UILabel *postArea;
///> 职位名称 
@property (nonatomic, strong) UILabel *jobStr;
///> 工资信息 
@property (nonatomic, strong) UILabel *salary;
///> 工资单位 
@property (nonatomic, strong) UILabel *salaryUnit;
///> 职位标题 
@property (nonatomic, strong) UILabel *title;
///> 
@property (nonatomic, strong) UIImageView *image;
///> 商家头像 
@property (nonatomic, strong) UIImageView *merIcon;
///> 商家名称 
@property (nonatomic, strong) UILabel *merName;
///> 商家分隔 
@property (nonatomic, strong) UIView *merLine;
///> 商家职称 
@property (nonatomic, strong) UILabel *merManager;
///> 商家VIP 
@property (nonatomic, strong) UIImageView *merVip;
///> 按钮    
@property (nonatomic, strong) UIButton *btn;
///> 底线    
@property (nonatomic, strong) UIView *line;
///> 标签列表 
@property (nonatomic, strong) UIView *tagsView;
///> 
@property (nonatomic, strong) DMHListItem *model;
///> 亮点 
@property (nonatomic, strong) UILabel *postNote;
///> 标签 
@property (nonatomic, strong) UILabel *tagLabel;

///>  
@property (nonatomic, strong) UIView *imgShadow;
///>  
@property (nonatomic, strong) AActionBlock action;
@end

@implementation DMHListCell

#pragma mark - Data
- (void)viewModel:(RACTuple *)x action:(nullable AActionBlock)action {
    RACTupleUnpack(DMHListItem *model, NSIndexPath *path, NSNumber *count, NSNumber *isLast, NSString *key) = x;
    _model = model;
    _action = action;
    
    BOOL isDing = [key isEqualToString:FMV_DINGYUE];
    BOOL isFeature = [key isEqualToString:FMV_FEATURE];
    _line.hidden = (path.row == REFRESH_POSITION-1 && ![isLast boolValue] && !isDing) || (path.row == [count intValue]-1 && [isLast boolValue]);
    _title.text = model.title;
    _postArea.text = model.disArea;
    _jobStr.text = model.auditAt.length?FORMAT(@"%@发布·%@",model.auditAt, model.jobTypeStr):model.jobTypeStr;
    _salary.text = model.salary;
    _salaryUnit.text = model.isSalaryNego ? @"" : model.salaryUnitStr;
    _merName.text = model.merchant.name;
    _merVip.hidden = !model.merchant.isAuth;
    _merManager.text = model.merchant.position;
    _image.hidden = !model.showImg;
    _imgShadow.hidden = !model.showImg;
    _postNote.attributedText = [_model postAttri];
    _merLine.hidden = !(model.merchant.position.length);
    self.btn.hidden = isFeature;
    
    @weakify(self);
    [[RACObserve(model, canApply) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        @strongify(self);
        NSString *title = model.canChat ? @"聊工作" : model.canApply ? @"投简历" : @"已投递";
        [self.btn setTitle:title forState:UIControlStateNormal];
        self.btn.enabled = model.canChat || model.canApply;
        self.btn.layer.borderColor = self.btn.enabled ? HEX(@"ff8800", @"DD9504").CGColor : HEX(@"cccccc", @"3D3D41").CGColor;
    }];
    [[RACObserve(model, hasTap) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        @strongify(self);
        self.title.textColor = [x boolValue] ? HEX(@"808080", @"AFAFB0") : HEX(@"404040", @"dddddd");
    }];
    [_merIcon setImageWithURL:[NSURL URLWithString:model.merchant.logo] placeholderImage:[UIImage imageNamed:@"rc_default_portrait"]];
    [_image setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:IMAGE(@"home_holder")];

    
    [self updateTag:model];
   
    [self updateFrames];
    [self addTags:model.welfareTags];
}

- (void)updateTag:(DMHListItem *)model {
    _tagLabel.hidden = !model.isJipin && !model.isZiyin && !model.isToutiao;
    if (_tagLabel.hidden) return;
    
    if (model.isToutiao) {
        _tagLabel.text = @"头条";
        _tagLabel.textColor = HEX(@"404040");
        _tagLabel.backgroundColor = HEX(@"FFEB8A");
    } else if (model.isZiyin) {
        _tagLabel.text = @"自营";
        _tagLabel.textColor = HEX(@"FF7F0F");
        _tagLabel.backgroundColor = HEX(@"FFEEE0");
    } else if (model.isJipin) {
        _tagLabel.text = @"急聘";
        _tagLabel.textColor = HEX(@"FF8066");
        _tagLabel.backgroundColor = HEX(@"FFECEC");
    }
}

#pragma mark - Instance
///=============================================================================
/// @name Instance
///=============================================================================

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addViews];
    }
    return self;
}

- (void)addViews {
    self.postArea   = [self lightLabel];
    self.jobStr     = [self lightLabel];
    self.jobStr.textAlignment = NSTextAlignmentRight;
    self.tagsView   = [UIView new];
    self.image      = [UIImageView new];
    self.merVip     = [[UIImageView alloc] initWithImage:IMAGE(@"home_v")];
    self.postNote   = [self lightLabel];
    _postNote.numberOfLines = 2;
    self.merName    = [self createLabel];
    self.merManager = [self createLabel];
    self.merLine    = [self createLine:HEX(@"cccccc", @"3D3D41")];
    self.line       = [self createLine:HEX(@"e5e5e5", @"303033")];
    [self.contentView addSubview:self.tagLabel];
    [self.contentView addSubview:self.postArea];
    [self.contentView addSubview:self.jobStr];
    [self.contentView addSubview:self.title];
    [self.contentView addSubview:self.salaryUnit];
    [self.contentView addSubview:self.salary];
    [self.contentView addSubview:self.imgShadow];
    [self.contentView addSubview:self.image];
    [self.contentView addSubview:self.postNote];
    [self.contentView addSubview:self.tagsView];
    [self.contentView addSubview:self.merIcon];
    [self.contentView addSubview:self.merVip];
    [self.contentView addSubview:self.merName];
    [self.contentView addSubview:self.merLine];
    [self.contentView addSubview:self.merManager];
    [self.contentView addSubview:self.btn];
    [self.contentView addSubview:self.line];
    [self initFrames];
    [self initTags];
}

- (void)initFrames {
    _tagLabel.frame   = CGRectMake(16, 19, 30, 14);
    _image.frame      = CGRectMake(SCREEN_WIDTH-86, 72, 70, 70);
    _imgShadow.frame  = CGRectMake(SCREEN_WIDTH-79, 72, 56, 70);
    _jobStr.frame     = CGRectMake(SCREEN_WIDTH-216, 20, 200, 12);
}

- (void)updateFrames {
    [_salary sizeToFit];
    [_salaryUnit sizeToFit];
    [_merName sizeToFit];
    CGFloat height = self.model.height;
    CGFloat noteW  = SCREEN_WIDTH-(self.model.showImg?118:32);
    BOOL hasPad = self.model.welfareTags.count && self.model.postNote.length;
    _title.frame      = CGRectMake(16, 40, SCREEN_WIDTH-156, self.model.titleH);
    _postNote.frame   = CGRectMake(16, _title.bottom+16, noteW, self.model.noteH+1);
    _tagsView.frame   = CGRectMake(16, _postNote.bottom+(hasPad?12:0), SCREEN_WIDTH-32, self.model.tagsH);
    _salaryUnit.frame = CGRectMake(SCREEN_WIDTH-16-_salaryUnit.width, 42, _salaryUnit.width, _salaryUnit.height);
    _salary.frame     = CGRectMake(SCREEN_WIDTH- 16 -_salaryUnit.width - _salary.width, 42, _salary.width, 14);
    _postArea.frame   = CGRectMake(self.tagLabel.hidden ? 16 : 50, 20, 200, 12);
    _merName.frame    = CGRectMake(48, height-39, MIN(_merName.width, 140.0), _merName.height);
    _merLine.frame    = CGRectMake(_merName.right+5, height-36, 1, 8);
    _merManager.frame = CGRectMake(_merLine.right+5, height-39, SCREEN_WIDTH-107-_merLine.right, _merName.height);
    _merIcon.frame    = CGRectMake(16, height-43, 20, 20);
    _merVip.frame     = CGRectMake(28, height-33, 10, 10);
    _line.frame       = CGRectMake(16, height-0.5, SCREEN_WIDTH-32, HALFPixal);
    _btn.frame        = CGRectMake(SCREEN_WIDTH-82, height-46, 66, 26);
}

- (void)initTags {
    for (NSInteger i=0; i<5; i++) {
        [self createTagLabel];
    }
}

- (UILabel *)createTagLabel {
    UILabel *label = [self lightLabel];
    label.layer.borderColor = HEX(@"cccccc", @"3D3D41").CGColor;
    label.layer.borderWidth = 0.5;
    label.layer.cornerRadius = 1;
    label.clipsToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.hidden = YES;
    [self.tagsView addSubview:label];
    return label;
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (UIView *)imgShadow {
    if (!_imgShadow) {
        _imgShadow = [UIView new];
        _imgShadow.layer.shadowColor = HEX(@"000000").CGColor;
        _imgShadow.layer.shadowOffset = CGSizeMake(0, 4);
        _imgShadow.layer.shadowOpacity = 0.2;
        _imgShadow.layer.shadowRadius = 6;
        _imgShadow.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    }
    return _imgShadow;
}

- (UILabel *)lightLabel {
    UILabel *label = [UILabel new];
    label.font = FONT(12);
    label.textColor = HEX(@"808080", @"AFAFB0");
    label.backgroundColor = [UIColor whiteColor];
    return label;
}

- (UILabel *)createLabel {
    UILabel *label = [UILabel new];
    label.font = FONT(12);
    label.textColor = HEX(@"404040", @"dddddd");
    label.backgroundColor = [UIColor whiteColor];
    return label;
}

- (UIView *)createLine:(UIColor *)color {
    UIView *view = [UIView new];
    view.backgroundColor = color;
    return view;
}

- (UILabel *)title {
    if (!_title) {
        _title = [UILabel new];
        _title.font = FONT_BOLD(16);
        _title.textColor = HEX(@"404040", @"dddddd");
        _title.numberOfLines = 2;
        _title.backgroundColor = [UIColor whiteColor];
    }
    return _title;
}

- (UILabel *)salary {
    if (!_salary) {
        _salary = [UILabel new];
        _salary.font = FONT_BOLD(14);
        _salary.textColor = HEX(@"ff8800", @"DD9504");
        _salary.textAlignment = NSTextAlignmentRight;
        _salary.backgroundColor = [UIColor whiteColor];
    }
    return _salary;
}

- (UILabel *)salaryUnit {
    if (!_salaryUnit) {
        _salaryUnit = [UILabel new];
        _salaryUnit.font = FONT_BOLD(12);
        _salaryUnit.textColor = HEX(@"ff8800", @"DD9504");
        _salaryUnit.textAlignment = NSTextAlignmentRight;
        _salaryUnit.backgroundColor = [UIColor whiteColor];

    }
    return _salaryUnit;
}

- (UIImageView *)merIcon {
    if (!_merIcon) {
        _merIcon = [UIImageView new];
        _merIcon.layer.cornerRadius =  10;
        _merIcon.clipsToBounds = YES;
        _merIcon.contentMode = UIViewContentModeScaleAspectFill;
        _merIcon.backgroundColor = [UIColor whiteColor];
    }
    return _merIcon;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    self.btn.layer.borderColor = self.btn.enabled ? HEX(@"ff8800", @"DD9504").CGColor : HEX(@"cccccc", @"3D3D41").CGColor;
}

- (UIButton *)btn {
    if (!_btn) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.layer.cornerRadius = 2;
        _btn.clipsToBounds = YES;
        _btn.layer.borderColor = HEX(@"ff8800", @"DD9504").CGColor;
        _btn.layer.borderWidth = HALFPixal;
        _btn.titleLabel.font = FONT(14);
        _btn.titleLabel.backgroundColor = [UIColor whiteColor];
        [_btn setTitleColor:HEX(@"ff8800", @"DD9504") forState:UIControlStateNormal];
        [_btn setTitleColor:HEX(@"ff8800", @"DD9504") forState:UIControlStateSelected];
        [_btn setTitleColor:HEX(@"999999", @"989899") forState:UIControlStateDisabled];
        @weakify(self);
        [_btn addEvents:UIControlEventTouchUpInside action:^{
            @strongify(self);
            if (self.action) self.action(RACTuplePack(@"listBtn", self.model));
            
             //点击的时候如果有下面的弹窗,则要隐藏当前的下弹窗
//             [[DMActivityViewManager sharedManager] dissmissBottomPopupView];
        }];
    }
    return _btn;
}

- (void)addTags:(NSArray<NSString *> *)array {
    __block NSInteger row = 1;
    CGFloat h = 18;
    @weakify(self);
    [array enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        UILabel *pre = idx > 0 ? self.tagsView.subviews[idx-1] : nil;
        UILabel *cur = idx<self.tagsView.subviews.count ? self.tagsView.subviews[idx] : [self createTagLabel];
        cur.text = obj;
        cur.hidden = NO;
        [cur sizeToFit];
        
        CGFloat space = idx == 0 ? 0 : 8;
        CGFloat w = cur.width + 8;
        CGFloat x = pre.x+pre.width+space;
        CGFloat maxW = x + w;
        CGFloat y = pre.y;
        CGFloat dis = self.model.showImg ? 86 : 0;
        if (maxW > (SCREEN_WIDTH - 32 - dis)) {
            row += 1;
            y = (row - 1) * (h + 8);
            x = 0;
        }
        cur.frame = CGRectMake(x, y, w, h);
    }];
    for (NSInteger i=array.count; i<self.tagsView.subviews.count; i++) {
        self.tagsView.subviews[i].hidden = YES;
    }
}

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [UILabel new];
        _tagLabel.layer.cornerRadius = 2;
        _tagLabel.clipsToBounds = YES;
        _tagLabel.font = FONT(10);
        _tagLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tagLabel;
}

@end
