//
//  DMHListModel.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/19.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMHListModel.h"
#import <GBaseLib/GConvenient.h>
#import <GLocation/GLocation.h>

#pragma mark - EXPORTS
///=============================================================================
/// @name EXPORTS
///=============================================================================
///> 商家信息
NSString * const HCI_MERCHANT = @"sjbk";
///> 运营位
NSString * const HCI_ZONE     = @"zwzq";
///> 全职职位
NSString * const HCI_JOB      = @"HCI_JOB";
///> 兼职职位
NSString * const HCI_JOB_PT   = @"HCI_JOB_PT";
///> 热门标签
NSString * const HCI_HOT      = @"rmzq";
///> 刷新
NSString * const HCI_REFRESH  = @"HCI_REFRESH";
///> Banner
NSString * const HCI_BANNER   = @"banner";
///> 空白
NSString * const HCI_EMPTY  = @"HCI_EMPTY";
///> 求职顾问模板
NSString * const HCI_CONUSELOR = @"qzgw";
///> 订阅模板
NSString * const HCI_DINGYUE = @"HCI_DINGYUE";

///> 从0开始
NSInteger const REFRESH_POSITION = 15;


#pragma mark - MERCHANT
///=============================================================================
/// @name MERCHANT
///=============================================================================

@implementation DMHListMerchant
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"name"  : @[@"real_name", @"user_name"],
             @"isAuth": @"is_auth",
             @"jobName": @"job_name",
             @"companyName" : @"company_name",
             @"companyId" : @"company_id",
             @"userId" : @"user_id",
             @"jobTypeName" : @"job_type_str",
             };
}
@end

#pragma mark - LIST_ITEM
///=============================================================================
/// @name LIST_ITEM
///=============================================================================

@implementation DMHListItem
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"isJipin"    : @"is_jipin",
             @"isZiyin"    : @"is_ziying",
             @"isToutiao"  : @"is_toutiao",
             @"postArea"   : @"post_area",
             @"jobTypeStr" : @"job_type_str",
             @"jobType"    : @"job_type",
             @"salaryUnit" : @"salary_unit_str",
             @"salaryType" : @"salary_type_str",
             @"welfareTags": @[@"welfare_tag", @"post_tags"],
             @"merchant"   : @"merchant_info",
             @"jobID"      : @"id",
             @"postNote"   : @"post_note",
             @"postImage"  : @"post_image",
             @"canChat"    : @"is_can_chat",
             @"canApply"   : @"is_can_apply",
             @"workType"   : @"work_type",
             @"userId"     : @"user_id",
             @"adType"     : @"ad_types",
             @"isSalaryNego":@"is_salary_nego",
             @"templateType":@"template_type",
             @"paymentTypeStr":@"payment_type_str",
             @"auditAt"    : @"audit_at",
             @"imagesNum"  : @"work_images_num",
             @"companyName": @"company_name"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"welfareTags" : [NSString class],
             @"merchant"    : [DMHListMerchant class]
             };
}

- (BOOL)modelSetWithDictionary:(NSDictionary *)dic {
    BOOL isSuc = [super modelSetWithDictionary:dic];
    _salaryUnitStr = FORMAT(@"%@/%@", _salaryUnit, _salaryType);
    _image = _postImage.length ? _postImage : _image;
    if ([[GLocation location].smodel.domain isEqualToString:[GLocation location].model.domain]) {
        _disArea = FORMAT(@"%@%@%@", _distance, _distance.length ? @"·" : @"", _postArea);
    } else {
        _disArea = _postArea;
    }
    _showImg = _postImage.length;
    if (_workType == 2) _postAttri = [self creatPostAttri];
    [self updateHeight];
    self.oriWelfareTags = self.welfareTags;
    if (_workType == 1 && _paymentTypeStr.length) {
        NSMutableArray *mut = @[_paymentTypeStr].mutableCopy;
        [mut addObjectsFromArray:_welfareTags];
        _welfareTags = mut;
    }
    return isSuc;
}

///> 牺牲便利获取性能 
- (void)updateHeight {
    if (_workType == 1) {
        _height = 116;//兼职
        return;
    }
    if (_showImg) {
        // 左高:
        CGFloat left = 40+[self titleHeight]+16+[self noteHeight]+(self.postNote.length?12:0)+[self tagsHeight];
        // 右度: (图片顶部高度 + 图片高度)
        CGFloat right = 142;
        _height = MAX(left, right) + 62;
    } else {
        // 高度: 标题顶部高度 + 标题高度 + 底部商家信息
        _height =  40 + [self titleHeight] + 62;
        if (_postNote.length || _welfareTags.count) _height += 16;
        if (_postNote.length && _welfareTags.count) _height += 12;
        // 高度: 亮点高度
        if (_postNote.length) _height += [self noteHeight];
        // 高度: 标签高度
        if (_welfareTags.count) _height += [self tagsHeight];
    }
}

///> 计算Title Height 
- (CGFloat)titleHeight {
    CGRect rect = [_title boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-156, 50)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:FONT_BOLD(16)}
                                       context:nil];
    _titleH = rect.size.height;
    return rect.size.height;
}

- (NSAttributedString *)creatPostAttri {
    if (!_postNote) return nil;
    NSString *note = [_postNote stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (!_postNote.length) return nil;
    NSTextAttachment *attach = [NSTextAttachment new];
    attach.image = IMAGE(@"home_yin");
    attach.bounds = CGRectMake(-4.5, -2, 12, 12);
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = 4;
    NSMutableAttributedString *abs = [[NSMutableAttributedString alloc] initWithString:note attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f],NSParagraphStyleAttributeName:style}];
    [abs appendAttributedString:[[NSAttributedString alloc] initWithString:@"  "]];
    [abs appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
    return [self handleParam:abs isFirst:YES];
}

- (NSMutableAttributedString *)handleParam:(NSMutableAttributedString *)mut isFirst:(BOOL)isFirst {
    CGFloat w = SCREEN_WIDTH - (_showImg ? 119:33);
    CGRect rect = [mut boundingRectWithSize:CGSizeMake(w, 50) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    if (rect.size.height > 35) {
        [mut deleteCharactersInRange:NSMakeRange(mut.length-2, 1)];
        [self handleParam:mut isFirst:NO];
    } else if (!isFirst) {
        [mut replaceCharactersInRange:NSMakeRange(mut.length-3, 2) withString:@"...  "];
        return mut;
    } else if (rect.size.height > 20) {
        [mut deleteCharactersInRange:NSMakeRange(mut.length-2, 1)];
    }
    return mut;
}

- (CGFloat)noteHeight {
    if (!self.postNote.length) return 0;
    CGFloat w = SCREEN_WIDTH - (_showImg ? 118:32);
    CGRect rect = [_postAttri boundingRectWithSize:CGSizeMake(w, 50) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    _noteH = rect.size.height>20 ? 33 : 13;
    return _noteH;
}

///> 计算TagsHeight 
- (CGFloat)tagsHeight {
    if (!_welfareTags.count) return _tagsH = 0;
    CGFloat space = 8;
    __block NSInteger row = 1;
    __block CGFloat maxW = 0;
    UILabel *label = [UILabel new];
    label.font = FONT(12);
    @weakify(self);
    [_welfareTags enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        label.text = obj;
        [label sizeToFit];
        CGFloat pad = idx == 0 ? 0 : space;
        CGFloat w = label.width + space;
        maxW += (w+pad);
        CGFloat dis = self.showImg ? 86 : 0;
        if (maxW > (SCREEN_WIDTH - 32 - dis)) {
            row += 1;
            maxW = w+pad;
        }
    }];
    _tagsH = row * 18 + (row - 1) * space;
    return _tagsH;
}

- (NSString *)cellIndentifier {
    if (_workType == 1) return HCI_JOB_PT;
    return HCI_JOB;
}
- (CGFloat)cellHeight {
    return self.height;
}

#pragma mark - BApplyModelDelegate
///=============================================================================
/// @name BApplyModelDelegate
///=============================================================================

- (NSString *)applyJobId {
    return _jobID;
}
- (NSString *)applyLng {
    return [GLocation location].model.lng;
}
- (NSString *)applyLat {
    return [GLocation location].model.lat;
}
- (NSString *)applyJobStr {
    return _jobTypeStr;
}
- (NSString *)applyJobType {
    return self.jobType;
}
- (NSString *)applyUserId {
    return self.userId;
}
- (NSString *)applyTitle {
    return _title;
}
- (NSString *)applyCaCampaign {
    return @"";
}
- (NSString *)applyReqId {
    return @"";
}
@end

#pragma mark - PANEL_ITEM
///=============================================================================
/// @name PANEL_ITEM
///=============================================================================

@implementation DMHHot
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"isHot" : @"is_hot"};
}
@end

@implementation DMHZone
@end

@implementation DMHBannerItem
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"type" : @"banner_type",
             @"brandName" : @"brand_name"
             };
}
@end

@implementation DMDingYueModel
- (CGFloat)cellHeight {
    return (SCREEN_WIDTH - 32) * 0.1 + 24;
}
- (NSString *)cellIndentifier {
    return HCI_DINGYUE;
}
@end

#pragma mark - PANEL_ITEM
///=============================================================================
/// @name PANEL_ITEM
///=============================================================================

@implementation DMHPanelModel

- (NSString *)panelId {
    if ([self.type isEqualToString:HCI_ZONE]) {
        return @"1";
    } else if ([self.type isEqualToString:HCI_HOT]) {
        return @"2";
    } else if ([self.type isEqualToString:HCI_MERCHANT]) {
        return @"3";
    } else if ([self.type isEqualToString:HCI_BANNER]) {
        return @"4";
    }
    return @"0";
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : [DMHListMerchant class]};
}

- (NSString *)cellIndentifier {
    return self.type;
}

- (CGFloat)cellHeight {
    if ([self.type isEqualToString:HCI_MERCHANT]) {
        return 234;
    } else if ([self.type isEqualToString:HCI_ZONE]) {
        return 156;
    } else if ([self.type isEqualToString:HCI_HOT]) {
        return (self.list.count / 4 + 1) * 56 - 16 + 50;
    } else if ([self.type isEqualToString:HCI_REFRESH]) {
        return 68;
    } else if ([self.type isEqualToString:HCI_BANNER]) {
        BOOL isBrand = [(DMHBannerItem *)self.list[0] type] == 2;
        return (SCREEN_WIDTH-32)*133.0/343 + 72 + (isBrand ? 26 : 0);
    } else if ([self.type isEqualToString:HCI_EMPTY]) {
        return 100;
    } else if ([self.type isEqualToString:HCI_CONUSELOR]) {
        return 110;
    }
    return 0;
}

///> 滚动曝光埋点字符串 

@end

@implementation DMHPanel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"merchant" : [DMHPanelModel class],
             @"zone"     : [DMHZone class],
             @"hot"      : [DMHHot class],
             @"banner1"  : [DMHBannerItem class]
             };
}
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"banner1" : @"banner_no1"};
}

- (BOOL)modelSetWithDictionary:(NSDictionary *)dic {
    BOOL isSuc = [super modelSetWithDictionary:dic];
    if (!isSuc) return NO;
    NSMutableArray *mut = @[].mutableCopy;
    if (self.zone.count) {
        DMHPanelModel *model = [DMHPanelModel modelWithJSON:@{@"type":HCI_ZONE}];
        model.list = self.zone;
        [mut addObject:model];
    }
    if (self.hot.count) {
        DMHPanelModel *model = [DMHPanelModel modelWithJSON:@{@"type":HCI_HOT}];
        model.list = self.hot;
        [mut addObject:model];
    }
    if (self.banner1.count) {
        DMHPanelModel *model = [DMHPanelModel modelWithJSON:@{@"type":HCI_BANNER}];
        model.list = self.banner1;
        [mut addObject:model];
    }
    self.merchant.type = HCI_MERCHANT;
    [mut addObject:self.merchant];
    self.arr = mut;
    return YES;
}
@end

@implementation DMHPanelPosition
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"banner" : @"banner_no1"};
}
- (BOOL)modelSetWithDictionary:(NSDictionary *)dic {
    BOOL isSuc = [super modelSetWithDictionary:dic];
    return isSuc;
}
@end

@implementation DMHDefaultMore
@end

#pragma mark - HOME_DATA
///=============================================================================
/// @name HOME_DATA
///=============================================================================

@implementation DMHListModel

+ (BOOL)needShowDingyue {
    return NO;
}

+ (BOOL)needShowDingyueCell {
    if (![self needShowDingyue]) return NO;
    return ![[NSUserDefaults standardUserDefaults] boolForKey:@"dingyue"];
}

+ (void)updateShowDingyueCell:(BOOL)show {
    [[NSUserDefaults standardUserDefaults] setValue:@(show) forKey:@"dingyue"];
}

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"panelPosition" : @"panel_position",
             @"curPage"  : @"current_page",
             @"lastPage" : @"last_page",
             @"defaultMore" : @"default",
             @"fetchNum" : @"show_fetch_num"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"data" : [DMHListItem class],
             @"panelPosition" : [DMHPanelPosition class],
             @"panel" : [DMHPanel class],
             @"defaultMore" : [DMHDefaultMore class]
             };
}

- (BOOL)modelSetWithDictionary:(NSDictionary *)dic {
    BOOL isSuc = [super modelSetWithDictionary:dic];
    if (dic[@"panel_position"]) self.panelPosition = [DMHPanelPosition modelWithJSON:dic[@"panel_position"]];
    if (dic[@"current_page"]) self.isLast = _curPage == _lastPage;
    if (dic[@"dingyue"]) self.isDingyue = [dic[@"dingyue"] boolValue];
    if (dic[@"nopanel"]) self.nopanel = [dic[@"nopanel"] boolValue];
    if (!self.isDingyue && !self.nopanel) {
        if (dic[@"data"]) [self updatePanelData];
        if (self.isLast) [self addConuselor];
    } else if (self.isDingyue) {
        if (dic[@"data"]) [self updateDingyue];
    }
    return isSuc;
}

- (void)addConuselor {
//    DMCounselorEntrance *ent = [DMCounselorEntrance sharedInstance];
//    DMCounselorBehavior *be = ent.counselorbehavior;
//    NSMutableArray *mut = self.data.mutableCopy;
//    if (mut.count > 0 && be.isHasCounselorByCity && !ent.isApply && mut.count < [be.filter.numbers integerValue]) {
//        DMHPanelModel *model = [DMHPanelModel modelWithJSON:@{@"type":HCI_CONUSELOR}];
//        [mut addObject:model];
//        self.data = mut.copy;
//        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"id":be.filter.id?:@"2",@"filter":ent.filterStr?:@""}];
//        [[DMServiceFactory getService:KCIMService_SERVICE] updataCounselorMessageWith:dict successBlock:nil failBlock:nil];
//    } else if (mut.count == 0 && be.isHasCounselorByCity && be.filter.id && !ent.isApply) {
//        DMHPanelModel *model = [DMHPanelModel modelWithJSON:@{@"type":HCI_EMPTY}];
//        [mut addObject:model];
//        DMHPanelModel *model1 = [DMHPanelModel modelWithJSON:@{@"type":HCI_CONUSELOR}];
//        [mut addObject:model1];
//        self.data = mut.copy;
//        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"id":be.filter.id?:@"2",@"filter":ent.filterStr?:@""}];
//        [[DMServiceFactory getService:KCIMService_SERVICE] updataCounselorMessageWith:dict successBlock:nil failBlock:nil];
//    }
}

- (void)updateDingyue {
    if (!self.data.count || ![self.class needShowDingyueCell]) return;
    
    NSMutableArray *mut = self.data.mutableCopy;
    [mut insertObject:[DMDingYueModel new] atIndex:0];
    self.data = mut.copy;
    [self.class updateShowDingyueCell:YES];
}

- (void)updatePanelData {
    if (!self.data.count || self.isDingyue || self.nopanel) return;
    // 插入列表逻辑
    @weakify(self);
    NSMutableArray *mut = self.data.mutableCopy;
    NSMutableArray *temp = @[].mutableCopy;
    __block NSInteger isEqual = 0;
    [self.panel.arr enumerateObjectsUsingBlock:^(DMHPanelModel *obj, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        if ([obj.type isEqualToString:HCI_ZONE] && self.panelPosition.zone) {
            obj.position = [self.panelPosition.zone integerValue];
            [temp addObject:obj];
        } else if ([obj.type isEqualToString:HCI_MERCHANT] && self.panelPosition.merchant && self.workType == 2) {
            obj.position = [self.panelPosition.merchant integerValue];
            [temp addObject:obj];
        } else if ([obj.type isEqualToString:HCI_BANNER] && self.panelPosition.banner) {
            obj.position = [self.panelPosition.banner integerValue];
            [temp addObject:obj];
        } else if ([obj.type isEqualToString:HCI_HOT] && self.panelPosition.hot) {
            obj.position = [self.panelPosition.hot integerValue];
            [temp addObject:obj];
        }
        isEqual = isEqual | (obj.position == REFRESH_POSITION+1);
    }];
    // 添加
    if (self.data.count > REFRESH_POSITION && !self.isLast) {
        DMHPanelModel *model = [DMHPanelModel new];
        model.type = HCI_REFRESH;
        model.position = isEqual == 1 ? REFRESH_POSITION+2 : REFRESH_POSITION+1;
        model.title = @"点击刷新更多好职位";
        model.list = @[@""];
        [temp addObject:model];
    }
    self.panel.arr = temp;
    self.panel.arr = [self.panel.arr sortedArrayUsingComparator:^NSComparisonResult(DMHPanelModel *obj1, DMHPanelModel *obj2) {
        return [@(obj1.position) compare:@(obj2.position)];
    }];
    [self.panel.arr enumerateObjectsUsingBlock:^(DMHPanelModel *obj, NSUInteger idx, BOOL *stop) {
        obj.idx = (obj.position<=REFRESH_POSITION+1) ? idx+1 : idx;
        if (obj.list.count == 0 || obj.position-1 > mut.count) return;
        [mut insertObject:obj atIndex:obj.position-1];
    }];
    self.data = mut;
}

- (NSArray<NSIndexPath *> *)addNextPage:(NSDictionary *)dict {
    NSArray *arr = dict[@"data"];
    if (![arr isKindOfClass:NSArray.class]) return @[];
    NSMutableArray *mut = self.data.mutableCopy;
    NSInteger count = mut.count;
    NSMutableArray *smut = @[].mutableCopy;
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [mut addObject:[DMHListItem modelWithJSON:obj]];
    }];
    self.data = mut;
    if (!self.isDingyue && !self.nopanel) {
        [self.panel.arr enumerateObjectsUsingBlock:^(DMHPanelModel *obj, NSUInteger idx, BOOL *stop) {
            if (obj.position <= count || obj.list.count == 0 || obj.position-1 > mut.count) return;
            [mut insertObject:obj atIndex:obj.position-1];
        }];
    }
    for (NSInteger i=count; i<mut.count; i++) {
        [smut addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    NSMutableDictionary *md = dict.mutableCopy;
    md[@"data"] = nil;
    DMHListModel *model = [DMHListModel modelWithJSON:md];
    self.isLast = model.isLast;
    self.curPage = model.curPage;
    return smut;
}

@end
