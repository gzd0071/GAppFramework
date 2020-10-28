//
//  DMHMerchantCell.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/20.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMHMerchantCell.h"
#import "DMHListModel.h"
#import <GProtocol/ViewProtocol.h>

#define kMER_WIDTH 120
#define kMER_PAD   12

@interface MerchantCell:UITableViewCell
///>  
@property (nonatomic, copy) AActionBlock actionBlock;
///> 
@property (nonatomic, strong) DMHListMerchant *model;
///>  
@property (nonatomic, strong) NSIndexPath *path;

///> 视图: 标题 
@property (nonatomic, strong) UIImageView *img;
///> 视图: 关闭 
@property (nonatomic, strong) UIImageView *imgV;
///> 视图: 滚动视图 
@property (nonatomic, strong) UILabel *title;
///> 视图: 底线 
@property (nonatomic, strong) UILabel *sub;
///> 视图: 底线 
@property (nonatomic, strong) UIButton *btn;
///> 视图:  
@property (nonatomic, strong) UIView *contain;
@end

@implementation MerchantCell

#pragma mark - DATA
///=============================================================================
/// @name DATA
///=============================================================================

- (void)viewModel:(RACTuple *)x action:(nullable AActionBlock)action {
    DMHListMerchant *model = x.first;
    _title.text = model.name;
    _model = model;
    _actionBlock = action;
    [_img setImageWithURL:[NSURL URLWithString:model.logo] placeholderImage:[UIImage imageNamed:@"rc_default_portrait"]];
    _sub.text = model.jobName;
    _imgV.hidden = !model.isAuth;
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
        self.contentView.transform = CGAffineTransformMakeRotation(M_PI/2);
        [self addViews];
    }
    return self;
}

- (void)addViews {
    [self initView];
    [self.contentView addSubview:self.contain];
    [self.contain addSubview:self.title];
    [self.contain addSubview:self.img];
    [self.contain addSubview:self.imgV];
    [self.contain addSubview:self.sub];
    [self.contain addSubview:self.btn];
    _img.frame   = CGRectMake(35, 11, 50, 50);
    _imgV.frame  = CGRectMake(71, 48, 10, 10);
    _title.frame = CGRectMake(10, 74, 100, 14);
    _sub.frame   = CGRectMake(10, 94, 100, 14);
    _btn.frame   = CGRectMake(27, 118, 66, 26);
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (UIView *)contain {
    if (!_contain) {
        _contain = [UIView new];
        _contain.backgroundColor = HEX(@"ffffff", @"2c2c2e");
        _contain.frame = CGRectMake(6, 6, kMER_WIDTH, 156);
        _contain.layer.cornerRadius = 4;
        
        _contain.layer.shadowColor = [HEX(@"000000") colorWithAlphaComponent:0.08].CGColor;
        _contain.layer.shadowOffset = CGSizeMake(0, 2);
        _contain.layer.shadowOpacity = 1;
        @weakify(self);
        [_contain addTapGesture:^{
            @strongify(self);
            if (self.actionBlock) self.actionBlock(RACTuplePack(@"merchant", self.model, self.path));
        }];
    }
    return _contain;
}

- (UILabel *)createLabel {
    UILabel *label = [UILabel new];
    label.font = FONT(16);
    label.textColor = HEX(@"404040", @"dddddd");
    return label;
}

- (void)initView {
    UIImageView *image = [UIImageView new];
    image.layer.cornerRadius = 25;
    image.clipsToBounds = YES;
    image.contentMode = UIViewContentModeScaleAspectFill;
    self.img = image;
    
    UILabel *title = [self createLabel];
    title.font = FONT(14);
    title.textAlignment = NSTextAlignmentCenter;
    self.title = title;
    
    UILabel *sub = [UILabel new];
    sub.font = FONT(12);
    sub.textColor = HEX(@"999999", @"989899");
    sub.textAlignment = NSTextAlignmentCenter;
    self.sub = sub;
    
    UIImageView *imgv = [[UIImageView alloc] initWithImage:IMAGE(@"home_v")];;
    self.imgV = imgv;
    self.btn = [self createBtn];
}

- (UIButton *)createBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = 2;
    btn.clipsToBounds = YES;
    btn.layer.borderColor = HEX(@"ff8800", @"DD9504").CGColor;
    btn.layer.borderWidth = 0.5;
    btn.titleLabel.font = FONT(14);
    [btn setTitle:@"聊工作" forState:UIControlStateNormal];
    [btn setTitleColor:HEX(@"ff8800", @"DD9504") forState:UIControlStateNormal];
    [btn setTitleColor:HEX(@"ff8800", @"DD9504") forState:UIControlStateSelected];
    @weakify(self);
    [btn addEvents:UIControlEventTouchUpInside action:^{
        @strongify(self);
        if (self.actionBlock) self.actionBlock(RACTuplePack(@"merchantChat", self.model, self.path));
    }];
    return btn;
}

@end

@interface DMHMerchantCell()<UITableViewDelegate, UITableViewDataSource>
///>  
@property (nonatomic, copy) AActionBlock actionBlock;
///> 
@property (nonatomic, strong) DMHPanelModel *model;
///>  
@property (nonatomic, strong) NSIndexPath *path;

///> 视图: 标题 
@property (nonatomic, strong) UILabel *title;
///> 视图: 关闭 
@property (nonatomic, strong) UIImageView *close;
///> 视图: 滚动视图 
@property (nonatomic, strong) UITableView *scroll;
///> 视图: 底线 
@property (nonatomic, strong) UIView *line;
///> 视图:  
@property (nonatomic, strong) UIView *aniBotLine;
///> 视图:  
@property (nonatomic, strong) UIView *aniTopLine;
@end

@implementation DMHMerchantCell

#pragma mark - DATA
///=============================================================================
/// @name DATA
///=============================================================================

- (void)viewModel:(RACTuple *)x action:(nullable AActionBlock)action {
    DMHPanelModel *model = x.first;
    _path = x.second;
    _model = model;
    _actionBlock = action;
    
    _line.hidden = (_path.row == REFRESH_POSITION);
    _title.text = model.title;
    [self.scroll reloadData];
    _line.frame = CGRectMake(16, model.cellHeight-0.5, SCREEN_WIDTH-32, HALFPixal);
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
        self.clipsToBounds = NO;
        self.contentView.clipsToBounds = NO;
        [self addViews];
    }
    return self;
}

- (void)addViews {
    self.title = [self createLabel];
    self.line  = [self createLine:HEX(@"e5e5e5", @"303033")];
    self.close = [[UIImageView alloc] initWithImage:IMAGE(@"home_close")];
    @weakify(self);
    [self.close addTapGesture:^(id x) {
        @strongify(self);
        if (self.actionBlock) self.actionBlock(RACTuplePack(@"interest", self.path, @42, self.model));
    }];
    [self.contentView addSubview:self.title];
    [self.contentView addSubview:self.close];
    [self.contentView addSubview:self.scroll];
    [self.contentView addSubview:self.line];
    
    _title.frame = CGRectMake(16, 20, SCREEN_WIDTH-68, 18);
    _close.frame = CGRectMake(SCREEN_WIDTH-36, 22, 20, 14);
}

#pragma mark - DataSource
///=============================================================================
/// @name DataSource
///=============================================================================

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = self.model.list[indexPath.row];
    UITableViewCell<ViewDelegate> *cell = [tableView dequeueReusableCellWithIdentifier:@"MerchantCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    @weakify(self);
    [cell viewModel:RACTuplePack(item, indexPath) action:^(RACTuple *x){
        @strongify(self);
        if (self.actionBlock) self.actionBlock([x tupleByAddingObject:self.model]);
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kMER_WIDTH+12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.actionBlock) self.actionBlock(RACTuplePack(@"exposure", self.model, self.path, self.model.list[indexPath.row], @(indexPath.row)));
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (UITableView *)scroll {
    if (!_scroll) {
        _scroll = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-84, 136-SCREEN_WIDTH/2, 168, SCREEN_WIDTH) style:UITableViewStyleGrouped];
        _scroll.showsVerticalScrollIndicator = NO;
        _scroll.showsHorizontalScrollIndicator = NO;
        _scroll.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
        _scroll.clipsToBounds = NO;
        _scroll.delegate = self;
        _scroll.dataSource = self;
        _scroll.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        _scroll.separatorStyle = UITableViewCellSeparatorStyleNone;
        _scroll.transform = CGAffineTransformMakeRotation(-M_PI/2);
        [_scroll registerClass:NSClassFromString(@"MerchantCell") forCellReuseIdentifier:@"MerchantCell"];
    }
    return _scroll;
}

- (UILabel *)createLabel {
    UILabel *label = [UILabel new];
    label.font = FONT_BOLD(16);
    label.textColor = HEX(@"404040", @"dddddd");
    return label;
}

- (UIView *)createLine:(UIColor *)color {
    UIView *view = [UIView new];
    view.backgroundColor = color;
    return view;
}

@end
