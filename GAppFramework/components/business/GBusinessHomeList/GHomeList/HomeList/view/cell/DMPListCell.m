//
//  DMPListCell.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/29.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMPListCell.h"
#import "DMHListModel.h"
#import <GBaseLib/GConvenient.h>
#import <ReactiveObjC/RACSignal.h>
#import <ReactiveObjC/RACSignal+Operations.h>
#import <ReactiveObjC/NSObject+RACPropertySubscribing.h>
#import <ReactiveObjC/UITableViewCell+RACSignalSupport.h>

@interface DMPListCell()
///> 标签 
@property (nonatomic, strong) UILabel *tagLabel;
///> 职位标题 
@property (nonatomic, strong) UILabel *title;
///> 工资信息 
@property (nonatomic, strong) UILabel *salary;
///> 工资单位 
@property (nonatomic, strong) UILabel *salaryUnit;
///> 位置信息 
@property (nonatomic, strong) UILabel *postArea;
///> 按钮    
@property (nonatomic, strong) UIButton *btn;
///> 底线    
@property (nonatomic, strong) UIView *line;
///> 标签列表 
@property (nonatomic, strong) UIView *tagsView;

///> 数据 
@property (nonatomic, strong) DMHListItem *model;
///>  
@property (nonatomic, strong) AActionBlock action;
@end

@implementation DMPListCell

#pragma mark - Data
- (void)viewModel:(RACTuple *)x action:(nullable AActionBlock)action {
    RACTupleUnpack(DMHListItem *model, NSIndexPath *path, NSNumber *count, NSNumber *isLast) = x;
    _model = model;
    _action = action;
    
    _line.hidden = (path.row == REFRESH_POSITION-1 && ![isLast boolValue]) || (path.row == [count intValue]-1 && [isLast boolValue]);
    _title.text = model.title;
    _postArea.text = FORMAT(@"%@ %@", model.postArea, model.companyName);
    _salary.text = model.salary;
    _salaryUnit.text = model.isSalaryNego ? @"" : model.salaryUnitStr;
    
    @weakify(self);
    [[RACObserve(model, canApply) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        @strongify(self);
        NSString *title = model.canChat ? @"聊工作" : model.canApply ? @"投简历" : @"已投递";
        [self.btn setTitle:title forState:UIControlStateNormal];
        self.btn.enabled = model.canChat || model.canApply;
        self.btn.layer.borderColor = self.btn.enabled ? HEX(@"ff8800", @"DD9504").CGColor : HEX(@"808080", @"AFAFB0").CGColor;
    }];
    [[RACObserve(model, hasTap) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        @strongify(self);
        self.title.textColor = [x boolValue] ? HEX(@"808080", @"AFAFB0") : HEX(@"404040", @"dddddd");
    }];
    [self addTags:model.welfareTags];
    
    [self updateTag:model];
    [self updateFrames];
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
        self.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        [self addViews];
    }
    return self;
}

- (void)addViews {
    self.postArea   = [self lightLabel];
    self.tagsView   = [UIView new];
    self.line       = [self createLine:HEX(@"e5e5e5", @"303033")];
    [self.contentView addSubview:self.tagLabel];
    [self.contentView addSubview:self.postArea];
    [self.contentView addSubview:self.title];
    [self.contentView addSubview:self.salaryUnit];
    [self.contentView addSubview:self.salary];
    [self.contentView addSubview:self.tagsView];
    [self.contentView addSubview:self.btn];
    [self.contentView addSubview:self.line];
    [self initFrames];
}

- (void)initFrames {
    _tagLabel.frame = CGRectMake(16, 21, 30, 14);
    _postArea.frame = CGRectMake(16, 46, SCREEN_WIDTH-126, 12);
    _tagsView.frame = CGRectMake(16, 77.5, SCREEN_WIDTH-114, 19);
    _btn.frame      = CGRectMake(SCREEN_WIDTH-82, 70, 66, 26);
}

- (void)updateFrames {
    BOOL hasTag = _tagLabel.hidden == NO;
    [_salaryUnit sizeToFit];
    _title.frame      = CGRectMake(hasTag?50:16, 20, SCREEN_WIDTH-(hasTag?157:123), 16);
    _salaryUnit.frame = CGRectMake(SCREEN_WIDTH-16-_salaryUnit.width, 22, _salaryUnit.width, _salaryUnit.height);
    _salary.frame     = CGRectMake(SCREEN_WIDTH-216-_salaryUnit.width, 22, 200, 14);
    _line.frame       = CGRectMake(16, self.model.cellHeight-0.5, SCREEN_WIDTH-32, HALFPixal);
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (UILabel *)lightLabel {
    UILabel *label = [UILabel new];
    label.font = FONT(12);
    label.textColor = HEX(@"808080", @"AFAFB0");
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
        _title.numberOfLines = 1;
    }
    return _title;
}

- (UILabel *)salary {
    if (!_salary) {
        _salary = [UILabel new];
        _salary.font = FONT_BOLD(14);
        _salary.textColor = HEX(@"ff8800", @"DD9504");
        _salary.textAlignment = NSTextAlignmentRight;
    }
    return _salary;
}

- (UILabel *)salaryUnit {
    if (!_salaryUnit) {
        _salaryUnit = [UILabel new];
        _salaryUnit.font = FONT_BOLD(12);
        _salaryUnit.textColor = HEX(@"ff8800", @"DD9504");
    }
    return _salaryUnit;
}

- (UIButton *)btn {
    if (!_btn) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.layer.cornerRadius = 2;
        _btn.clipsToBounds = YES;
        _btn.layer.borderColor = HEX(@"ff8800", @"DD9504").CGColor;
        _btn.layer.borderWidth = 0.5;
        _btn.titleLabel.font = FONT(14);
        [_btn setTitleColor:HEX(@"ff8800", @"DD9504") forState:UIControlStateNormal];
        [_btn setTitleColor:HEX(@"ff8800", @"DD9504") forState:UIControlStateSelected];
        [_btn setTitleColor:HEX(@"808080", @"AFAFB0") forState:UIControlStateDisabled];
        
        @weakify(self);
        [_btn addEvents:UIControlEventTouchUpInside action:^{
            @strongify(self);
            if (self.action) self.action(RACTuplePack(@"listBtn", self.model));
        }];
    }
    return _btn;
}

- (void)addTags:(NSArray<NSString *> *)array {
    for (UIView *view in self.tagsView.subviews) {
        [view removeFromSuperview];
    }
    if (!array || array.count == 0) return;
    CGFloat h = 18;
    
    @weakify(self);
    [array enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        CGFloat space = idx == 0 ? 0 : 8;
        UILabel *pre = idx > 0 ? self.tagsView.subviews[idx-1] : nil;
        UILabel *label = [self lightLabel];
        label.text = obj;
        [label sizeToFit];
        CGFloat w = label.width + 8;
        
        CGFloat x = pre.x+pre.width+space;
        CGFloat maxW = x + w;
        CGFloat y = pre.y;
        if (maxW > (SCREEN_WIDTH - 120)) {
            *stop = YES;
            label.text = @"...";
            [label sizeToFit];
            w = label.width + 8;
            x = pre.x+pre.width+space;
            y = pre.y;
            label.frame = CGRectMake(x, y, w, h);
            label.layer.borderColor = HEX(@"cccccc").CGColor;
            label.layer.borderWidth = 0.5;
            label.layer.cornerRadius = 1;
            label.clipsToBounds = YES;
            label.textAlignment = NSTextAlignmentCenter;
            [self.tagsView addSubview:label];
            return;
        }
        
        label.text = obj;
        label.frame = CGRectMake(x, y, w, h);
        label.layer.borderColor = HEX(@"cccccc", @"3D3D41").CGColor;
        label.layer.borderWidth = 0.5;
        label.layer.cornerRadius = 1;
        label.clipsToBounds = YES;
        label.textAlignment = NSTextAlignmentCenter;
        [self.tagsView addSubview:label];
    }];
}

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [UILabel new];
        _tagLabel.layer.cornerRadius = 2;
        _tagLabel.clipsToBounds = YES;
        _tagLabel.frame = CGRectMake(0, 0, 30, 14);
        _tagLabel.font = FONT(10);
        _tagLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tagLabel;
}

@end

