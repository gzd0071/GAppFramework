//
//  DMHCity.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/21.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMHCity.h"
#import "DMHFilterModel.h"
#import "DMHCityModel.h"
#import <GProtocol/ViewProtocol.h>
#import <GHttpRequest/HttpRequest.h>
#import <GLocation/GLocation.h>
#import <ReactiveObjC/RACSignal.h>
#import <ReactiveObjC/NSObject+RACPropertySubscribing.h>

#pragma mark - DMHAreaCell
///=============================================================================
/// @name DMHAreaCell
///=============================================================================

@interface DMHCityCell: UITableViewCell
@end

@implementation DMHCityCell
- (void)viewModel:(DMHCityModel *)model action:(nullable AActionBlock)action {
    self.textLabel.text = model.name;
    [RACObserve(model, select) subscribeNext:^(id x) {
        self.contentView.backgroundColor = !model.select ? HEX(@"fffffff") : HEX(@"f7f7f7", @"000000");
        self.textLabel.textColor = !model.select ? HEX(@"404040", @"dddddd") : HEX(@"FFAA00");
    }];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = FONT(14);
        self.textLabel.textColor = HEX(@"404040", @"dddddd");
    }
    return self;
}
@end

#pragma mark - DMHAreaCell
///=============================================================================
/// @name DMHAreaCell
///=============================================================================

@interface DMHAreaCell: UITableViewCell
@end

@implementation DMHAreaCell
- (void)viewModel:(DMHCityModel *)model action:(nullable AActionBlock)action {
    self.textLabel.text = model.name;
    [RACObserve(model, select) subscribeNext:^(id x) {
        self.textLabel.textColor = !model.select ? HEX(@"404040", @"dddddd") : HEX(@"FFAA00", @"ff8800");
    }];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = HEX(@"f7f7f7", @"000000");
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = FONT(14);
        self.textLabel.textColor = HEX(@"404040", @"dddddd");
    }
    return self;
}
@end

#pragma mark - DMHCityInstance
///=============================================================================
/// @name DMHCityInstance
///=============================================================================

@interface DMHCityInstance : NSObject
///>  
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<DMHCityModel *> *> *keyList;
@end

@implementation DMHCityInstance
+ (instancetype)share {
    static DMHCityInstance *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DMHCityInstance new];
        instance.keyList = @{}.mutableCopy;
    });
    return instance;
}

@end


@interface DMHCity ()<UITableViewDelegate, UITableViewDataSource>
#pragma mark - inherent
///>  
@property (nonatomic, copy) AActionBlock actionBlock;

///> 城市列表 
@property (nonatomic, strong) UITableView *cityTB;
///> 区域别表 
@property (nonatomic, strong) UITableView *areaTB;
///> 黑色背景 
@property (nonatomic, strong) UIView *line;

///>  
@property (nonatomic, strong) NSArray<DMHCityModel *> *data;
///>  
@property (nonatomic, assign) NSInteger cityTemp;
///>  
@property (nonatomic, assign) NSInteger citySelect;
///>  
@property (nonatomic, assign) NSInteger streetSelect;
///>  
@property (nonatomic, strong) FilterItem *model;
///>  
@property (nonatomic, strong) RACTuple *selectInfo;
@end

@implementation DMHCity

///> DMHDropDelegate
- (void)dismiss:(BOOL)animated {
    if (_cityTemp != _citySelect) {
        self.data[_citySelect].select = YES;
        self.data[_cityTemp].select = NO;
    }
}

#pragma mark - ViewDelegate
///=============================================================================
/// @name ViewDelegate
///=============================================================================

+ (id)viewWithFrame:(CGRect)frame model:(id)model action:(AActionBlock)action {
    return [[self alloc] initWithFrame:frame model:model action:action];
}

#pragma mark - Delegate
///=============================================================================
/// @name Delegate
///=============================================================================

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.cityTB == tableView) return self.data.count;
    return self.data[self.cityTemp].streets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DMHCityModel *item = (self.cityTB == tableView) ? self.data[indexPath.row] : self.data[self.cityTemp].streets[indexPath.row];
    id cellID = self.cityTB == tableView ? @"cityCell" : @"areaCell";
    UITableViewCell<ViewDelegate> *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell viewModel:item action:nil];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cityTB == tableView) {
        self.data[_cityTemp].select = NO;
        self.cityTemp = indexPath.row;
        self.data[_cityTemp].select = YES;
        [_areaTB reloadData];
    } else {
        self.data[_citySelect].select = NO;
        self.data[_citySelect].streets[_streetSelect].select = NO;
        self.citySelect = _cityTemp;
        self.streetSelect = indexPath.row;
        self.data[_citySelect].select = YES;
        self.data[_citySelect].streets[_streetSelect].select = YES;
        if (_citySelect == 0 && indexPath.row == 0) {
            _model.sname = @"";
        } else if (indexPath.row == 0) {
            _model.sname = self.data[_citySelect].name;
        } else {
            _model.sname = self.data[_citySelect].streets[indexPath.row].name;
        }
        [self dismiss:YES];
        if (_actionBlock) _actionBlock(RACTuplePack(@"citySelect", self.data[_citySelect], self.data[_citySelect].streets[indexPath.row]));
    }
}

#pragma mark - View
///=============================================================================
/// @name View
///=============================================================================

- (instancetype)initWithFrame:(CGRect)frame model:(RACTuple *)model action:(AActionBlock)action {
    CGRect rect = CGRectMake(100, 0, SCREEN_WIDTH-100, kMENUHEIGHT);
    if (self = [super initWithFrame:rect]) {
        _actionBlock = action;
        _model = model.first;
        _selectInfo = model;
        [self requestData];
        [self addViews];
    }
    return self;
}

- (void)updateLocalData {
    @weakify(self);
    [_data enumerateObjectsUsingBlock:^(DMHCityModel *obj, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        BOOL isCur = [obj.id isEqualToString:self.selectInfo.second] || (!self.selectInfo.second && idx == 0);
        if (isCur) self.cityTemp = self.citySelect = idx;
        obj.select = isCur;
        [obj.streets enumerateObjectsUsingBlock:^(DMHCityModel *sobj, NSUInteger sidx, BOOL *sstop) {
            BOOL isSCur = isCur && ([sobj.id isEqualToString:self.selectInfo.third] || (!self.selectInfo.third && sidx == 0));
            if (isSCur) self.streetSelect = sidx;
            sobj.select = isSCur;
        }];
    }];
}

- (void)requestData {
    NSString *cityID = [GLocation location].smodel.cityID;
    if (cityID) _data = [DMHCityInstance share].keyList[cityID];
    if (_data) {
        [self updateLocalData];
        return;
    }
    id url = FORMAT(@"%@/%@", @"/api/v2/client/districts", cityID);
    GTask *dis = [HttpRequest jsonRequest].urlString(url).task;
    dis.then(^id(HttpResult<NSArray *, id> *t) {
        if (t.code == 200 && [t.data isKindOfClass:NSArray.class]) {
            NSMutableArray *mut = @[].mutableCopy;
            [t.data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                DMHCityModel *model = [DMHCityModel modelWithJSON:obj];
                if (idx == 0) {
                    model.select = YES;
                    if (model.streets.count) model.streets[0].select = YES;
                }
                [mut addObject:model];
            }];
            [DMHCityInstance share].keyList[cityID] = mut;
            self.data = mut;
            [self.cityTB reloadData];
            [self.areaTB reloadData];
        }
        return nil;
    });
}

- (void)addViews {
    _cityTB = [self createTableView];
    _areaTB = [self createTableView];
    _line   = [UIView new];
    _line.backgroundColor = HEX(@"e5e5e5", @"3d3d41");
    _line.frame = CGRectMake(self.width/2, 0, HALFPixal, self.height);
    _cityTB.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    _cityTB.frame = CGRectMake(0, 0, self.width/2, kMENUHEIGHT);
    _areaTB.frame = CGRectMake(self.width/2, 0, self.width/2, kMENUHEIGHT);
    [self addSubview:_cityTB];
    [self addSubview:_areaTB];
    [self addSubview:_line];
}

- (UITableView *)createTableView {
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.showsVerticalScrollIndicator = NO;
    table.showsHorizontalScrollIndicator = NO;
    [table registerClass:NSClassFromString(@"DMHCityCell") forCellReuseIdentifier:@"cityCell"];
    [table registerClass:NSClassFromString(@"DMHAreaCell") forCellReuseIdentifier:@"areaCell"];
    return table;
}

+ (void)loadCityData:(NSString *)cityID {
    id url = FORMAT(@"%@/%@", @"/api/v2/client/districts", cityID);
    GTask *dis = [HttpRequest jsonRequest].urlString(url).task;
    dis.then(^id(HttpResult<NSArray *, id> *t) {
        if (t.code == 200 && [t.data isKindOfClass:NSArray.class]) {
            NSMutableArray *mut = @[].mutableCopy;
            NSMutableArray *omut = @[].mutableCopy;
            [t.data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                DMHCityModel *model = [DMHCityModel modelWithJSON:obj];
                if (idx == 0) {
                    model.select = YES;
                    if (model.streets.count) model.streets[0].select = YES;
                }
                if (model) {
                    [mut addObject:model];
                }
            }];
            [DMHCityInstance share].keyList[cityID] = mut;
        }
        return nil;
    });
}

@end
